/* SVN header
$Date: 2023-03-24 12:40:40 +0100 (fr, 24 mar 2023) $
$Revision: 341 $
$Author: wnm6683 $
$Id: getDiag.sas 341 2023-03-24 11:40:40Z wnm6683 $
*/
/*
   #+CHANGELOG
    Date    Initials  Status
    31.07.2015  JNK     Updated to hist-version.
    11.08.2015  FLS     noduplicates ændret til nodupkey i proc sort
    19.08.2015  FLS     ekstra anførselstegn i afslutningsreplik fjernet
    14.06.2016  JNK     Renamed to get Diag
    25.08.2016  JNK     Removing outcome
    06.09.2016  JNK     Changing basedate to IndexDate, removing option of reduction and keeping history as a default
    11.10.2016  JNK     Adding basepop option, will create a combined table with basepopulation named &basepop
    19.11.2016  JNK     Removing *hist from master table names
	18.09.2020 	MJE		Adding table prefix LPR to tables
*/
%macro GetDiag(outlib, diaglist, diagtype="A" "B",pattype=0 1 2 3,ICD8=FALSE, basedata=,fromyear=1977,LPRdata=, basepop=, tildiag=FALSE, UAF=FALSE, prioritet=1 2);
  %local N  nsets diag;
  %start_timer(getdiag);
  %if &LPRdata = %then %let LPRdata=master.vwLPR;
  %if &tildiag=TRUE %then %let fromyear=%sysfunc(max(&fromyear,1995));;; /* tillægsdiagnoser først fra 1995 */
  %let nsets = %sysfunc(countw(&diaglist));
  %if &nsets > 1 %then %do;
    %nonrep(mvar=diaglist, outvar=newdiaglist);
    %let nsets = %sysfunc(countw(&newdiaglist));
    %let diaglist = &newdiaglist;
  %end;
  %do N=1 %to &nsets;
    %let diag = %lowcase(%scan(&diaglist, &N));
	  %if &UAF=TRUE %then %do; /* uafsluttede  kontakter */
	    /* get the UAF tables */
        %findingDiag(&diag._uaf, &diag,  %if &ICD8=TRUE and %symexist(LPR&diag._ICD8)=1 %then &&LPR&diag._ICD8; &&LPR&diag, diagtype=&diagtype, pattype=&pattype, basedata=&basedata, fromyear=&lastLPR,LPRdata=master.vwLPRuaf, tildiag=&tildiag, prioritet=&prioritet);
	    /* repeat findingDiag with UAF=FALSE - get the tables that has an end date */
        %findingDiag(&diag, &diag,  %if &ICD8=TRUE and %symexist(LPR&diag._ICD8)=1 %then &&LPR&diag._ICD8; &&LPR&diag, diagtype=&diagtype, pattype=&pattype, basedata=&basedata, fromyear=&fromyear,LPRdata=&LPRdata, tildiag=&tildiag, prioritet=&prioritet);
	    /* combine the two tables, exclude lines from UAF that are ended by now */
	    /* tables are in work, and named &diag and &diag_uaf */
	    %combineDiagTables(&outlib, &diag);

		proc datasets library = &outlib noprint nowarn;
		delete LPR&diag.all;
		change &diag.ALL = LPR&diag.ALL;
		run;

	  %end;
	  %if &UAF=FALSE %then %do;
	    /* normal case */
        %findingDiag(&outlib..LPR&diag.ALL, &diag,  %if &ICD8=TRUE and %symexist(LPR&diag._ICD8)=1 %then &&LPR&diag._ICD8; &&LPR&diag, diagtype=&diagtype, pattype=&pattype, basedata=&basedata, fromyear=&fromyear,LPRdata=&LPRdata, tildiag=&tildiag, prioritet=&prioritet);
	  %end;
      %end_timer(getdiag, text='Run &N of FindingDiag complete');
    data  &outlib..LPR&diag.ALL;
        set  &outlib..LPR&diag.ALL;
        if priority="1" and pattype=2 then pattype=3;
        %if &pattype ne %then %do;
           if  pattype not in (%commas(&pattype)) then delete;
            %end;
        %runquit;
    %if &basepop ne %then %do;
      proc sql inobs=&sqlmax;
      %if &N=1 %then create table &outlib..&basepop as ;
      %else insert into &outlib..&basepop ;
      select pnr, indate as IDate length=8, diagnose, outcome, rec_in, rec_out
      from &outlib..LPR&diag.ALL;
      %sqlquit;
    %end;
  %end;
  %if &basepop ne %then %do;
    proc sort data = &outlib..&basepop noduplicates; /* do not reduce to one list now, because the ajourdate is not specified */
      by pnr idate diagnose outcome rec_out;
    %runquit;
  %end;
  %end_timer(getdiag, text=GetDiag complete);
%mend;
/*
  #+NAME
    %getDiag
  #+TYPE
    SAS
  #+DESCRIPTION
    Extract hospital discharge data on specific diagnoses for a
    population. Output dataset can optionally be reduced to a status at a
    specified time, using ''%reducerFC''. The macro is called outside a datastep.
  #+SYNTAX
    %findingDiag(
      outdata,      Output dataset name. Required.
      outcome,      Short text string to label the outcome. Required.
      icd,          List of ICD codes version 8 or 10, without prefix D or
                      '.'s. Separated with spaces. Required.
      diagtype=,     List of diagnosis types ("A" "B" "C" "G" "H" "+").
                      Separated with spaces. Defaults til "A" and "B".
      pattype=,      List of patient types (0 1 2 3). Separated with
                      spaces. Defaults to 0 1 2
      basedata=,    Input dataset with required population. Optional.
      fromyear=,    Defaults to 1977. First year to look for diagnoses.
                      Normally not used.
      LPRdata=MasterData.vwLPR
                    Dataset name. Identify the dataset to be used for
                      extracting discharge data. Normally not used.
     );
  #+OUTPUT
    if reduce=FALSE:
     pnr outcome diagnose diagtype pattype hospital hospitalunit indate outdate
    additionally if IndexDate is specified:
     IndexDate afterbase
    if reduce=TRUE:
    see %reducerFC documentation.
  #+AUTHOR
    Flemming Skjøth
  */
%MACRO FindingDiag(outdata,outcome, icd, diagtype=,pattype=,basedata=,fromyear=,LPRdata=, tildiag=,prioritet=);
  %local dlstcnt localoutdata yr I dval;
  %let dlstcnt = %sysfunc(countw(&icd));
  %let localoutdata = %NewDatasetName(localoutdatatmp); /* temporært datasæt så der arbejdes i work */
  %do yr=&fromyear %to &lastLPR;
    proc sql inobs=&sqlmax;
      %if &yr=&fromyear %then create table &localoutdata as ;
      %else insert into &localoutdata ;
        select  a.pnr,  "&outcome" as outcome length=10,
        a.indate, a.outdate,
		dhms(a.indate,case a.indtime when . then 11 else a.indtime end, case a.indminut when . then 59 else a.indminut end,0)
        as starttime,
		dhms(a.indate, case a.udtime when . then 11 else a.udtime end, 59,0) as endtime,
        a.pattype, a.priority, a.adiag as adiagnose length=10 label="adiagnose",
        %if &tildiag=TRUE %then a.tildiag; %else a.diagnose; as diagnose length=10 label="diagnose",
        a.diagtype, a.hospital,
		%if &yr < 1997 %then put(a.hospitalunit,3.);
		%if &yr >= 1997 and &yr<2004 %then a.hospitalunit;
		%if &yr >= 2004 and &yr<2008 %then put(a.hospitalunit,3.);
		%if &yr >= 2008 %then a.hospitalunit; as hospitalunit,
		/* ICD8 and IDC10 formats in seperate coloumns - be aware, the text only corresponds to the A diagnosis! */
        %if &yr <1994  %then a.Adiagtxt as Adiagicd8txt format=$ICD8_L1L1_T.  label="A diagnosis description" length=20 informat=$61.; %else "" as Adiagicd8txt;,
        %if &yr >=1994 %then a.Adiagtxt as Adiagtxt format=$ICD10_L1L1_T. label="A diagnosis description" length=20 informat=$61.; %else "" as Adiagtxt format=$ICD10_L1L1_T. label="A diagnosis description" length=20 informat=$61.;,
        a.rec_in, a.rec_out, today() as udtrkdate format=date.
        from
        &LPRdata&yr a
      %if &basedata ne %then , &basedata b ;
        where
      %if &basedata ne %then a.pnr=b.pnr and;
      %if &dlstcnt>1 %then (;
        %DO I=1 %to &dlstcnt;
          %let dval = %upcase(%qscan(&icd,&i));
          %if &i>1 %then OR ;
		    %if &tildiag = TRUE %then  %upcase(substr(a.tildiag,1,%length(&dval))) = "&dval";
            %if &tildiag = FALSE %then %upcase(substr(a.diagnose,1,%length(&dval))) = "&dval";
        %END;
      %if &dlstcnt>1 %then );
      and
        a.diagtype in (%commas(&diagtype)) and
        (missing(a.priority) or a.priority in (".",%quotelst(&prioritet,delim=%str(, ))));
    quit;
  %END;
  proc sort data=&localoutdata out=&outdata;
    by pnr diagnose indate outdate;
  %RunQuit;
  %cleanup(&localoutdata);
%MEND;
%macro combineDiagTables(outlib, name);
  data temp;
    set &name &name._uaf;
	by pnr;
	/* create a compareid - makes it easier to reduce lines */
	sp ="_";
	compareid = catx(sp, of pnr diagnose indate /* outdate */ diagtype pattype hospital );
  %runquit;
  proc sort data=temp nodupkey;
    by compareid pnr diagnose indate outdate diagtype pattype hospital rec_in rec_out;
  %runquit;
  /* remove dublicate lines - UAF are not updated quite as fast as LPR resulting in double lines */
  data temp1;
    set temp;
	by compareid pnr;
	retain out_old; /* store information about previous outdate */
	if first.compareid then out_old = outdate;
	if last.compareid then do;
	  if out_old ne . then do; /* outdate = . is from UAF table - if comparid is the same then it is no longer UAF */
		 if outdate ne out_old then output; /* if outdate != . and out_old != outdate then this is two independent lines - output both */
		 outdate = out_old; /* replace with new previous outdate */
	   end;
	end;
	if last.compareid then output;
	drop compareid sp out_old;
  %runquit;
  data &outlib..&name.ALL;
    set temp1;
	by pnr;
  %runquit;
%mend;
