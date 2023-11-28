/* SVN header
$Date: 2021-12-01 11:22:42 +0100 (on, 01 dec 2021) $
$Revision: 309 $
$Author: wnm6683 $
$Id: getOPR.sas 309 2021-12-01 10:22:42Z wnm6683 $
*/
/*    #+CHANGELOG
    Date    Initials  Status
    31.07.2016  JNK   Renamed to getOPR and changed variable names
    21.11.2016  JNK   Removed hospitalunit
	18.09.2020	MJE	  Add table prefix
*/
%macro GetOPR(outlib, oprlist, fromyear=1997, type=opr, pattype=0 1 2, oprart="" "V" "P" "D", basedata=,LPRdata=, basepop=, tilopr=FALSE /* tillægsdiagnose */, UAF=FALSE /* uafsluttede */ );
  %start_timer(getopr); /* measure time for this macro */
  %if %UPCASE(&type)=UBE and &fromyear<1999 %then %let fromyear=1999;
  %if %UPCASE(&type)=OPR and &fromyear<1997 %then %let fromyear=1997;
  %local N nofOPR name code;
  %let nofOPR = %sysfunc(countw(&oprlist));
  %if &tilopr= TRUE %then %do;
      %let name = _til;
      %let oprart="+";
  %end;

  %do N=1 %to &nofOPR;
    %let code = %lowcase(%scan(&OPRlist, &N)); /* go through oprlist */
	%if &UAF=TRUE %then %do;
	  /* get the UAF tables  */
      %findingOPR(&code._uaf, &code, &&&type&code, pattype=&pattype, oprart=&oprart, basedata=&basedata, fromyear=&lastLPR, LPRdata=Master.vwLPRuafsks&type, tilopr=&tilopr);
	  /* repeat with UAF = FALSE  */
      %findingOPR(&code, &code, &&&type&code, pattype=&pattype, oprart=&oprart, basedata=&basedata, fromyear=&fromyear, LPRdata=Master.vwLPRsks&type, tilopr=&tilopr);
	  /* combine the two tables, exclude lines from UAF that are ended now */
	  /* tables are in work, and named &code and &code_uaf */
	  %combineOPRTables(&outlib, &code);

		proc datasets library=&outlib noprint nowarn;
  			delete &type.&code.ALL;
			change &code.ALL = &type.&code.ALL;
		run;

	%end;
	%if &UAF=FALSE %then %do;
	  /* normal case */
      %findingOPR(&outlib..&type.&code.ALL, &code, &&&type&code, pattype=&pattype, oprart=&oprart, basedata=&basedata,fromyear=&fromyear, LPRdata=Master.vwLPRsks&type, tilopr=&tilopr,type=&type);
	%end;
    /* create a combined table for the base population */
    %if &basepop ne %then %do;
    proc sql inobs=&sqlmax;
      %if &N=1 %then create table &outlib..&basepop as ;
      %else insert into &outlib..&basepop ;
      select pnr, indate as indate length=8, oprdate as oprdate length=8, outdate as outdate length=8, opr, oprdiag, outcome, rec_in, rec_out
      from &outlib..&type.&code.ALL;
     %sqlquit; /* fix size of outcome before using %sqlquit */
    %end;
  %end;
  %if &basepop ne %then %do;
    proc sort data = &outlib..&basepop; /* do not reduce to one list now, because the ajourdate is not specified */
      by pnr indate oprdate outdate opr outcome rec_out;
    %runquit;
  %end;
  %end_timer(getOPR, text=Measure time for GetOPR macro);

%mend;
/*
  #+NAME
    %findingOPR
  #+TYPE
    SAS
  #+DESCRIPTION
    Extract hospital operation data on specific operations for a
    population. Output dataset can optionally be reduced to a status at a
    specified time, using ''%reducerFO''. The macro is called outside a datastep.
  #+SYNTAX
    %findingOPR(
      outdata,         Output dataset name. Required.
      outcome,         Short text string to label the outcome. Required.
      opr,             List of Operation codes version 10?, without prefix K. Separated with spaces. Required.
      oprart,          List of the operations importance (V, P, D, +).
                         V = vigtigste operation i afsluttet kontakt,
                         P = vigtigste operation i operativt indgreb,
                         D = deloperation. Anden/andre operationer i operativt indgreb.
                         + = Tillægskode.
      pattype=,        List of patient types (0 1 2 3). Separated with spaces.
      basedata=,       Input dataset with required population. Optional.
      fromyear=1977,   Constant. First year to look for diagnoses.
                        Normally not used.
      LPRdata=MasterData.vwLPRsksopr
                       Dataset name. Identify the dataset to be used for
                         extracting discharge data. Normally not used.
  );
  #+OUTPUT
     pnr outcome opr oprart pattype hospital hospitalunit indate outdate oprdate
  #+AUTHOR
    Flemming Skjøth
*/
%MACRO findingOPR(outdata,outcome,opr,pattype=,oprart=, basedata=, fromyear=,LPRdata=, tilopr=,type=,uaf=);
  %local localoutdata dlstcnt startOPRtime yr I;
  %let dlstcnt = %sysfunc(countw(&opr));
  /* print linie med aktuelt udtrækstidspunkt */
  %put start findingOPRcases: %qsysfunc(datetime(), datetime20.3);
  %let startOPRtime = %qsysfunc(datetime());

  %let localoutdata=%NewDataSetName(localoutdatatemp); /* fortsæt arbejdet i work */
  proc sql inobs=&sqlmax;
    %do yr=&fromyear %to &lastLPR;
      %if &yr=&fromyear %then create table &localoutdata as ;
      %else insert into &localoutdata ;
        select  a.pnr,  "&outcome" as outcome  length=10,
        a.indate, a.outdate, a.odto as oprdate, a.adiag as oprdiag,
        a.pattype, %if &tilopr=TRUE %then a.tilopr as opr; %else a.OPR ;, a.OPRART, a.hospital,
        a.rec_in, a.rec_out, today() as udtrkdate format=date.
        from &LPRdata&yr a
      %if &basedata ne %then , &basedata b ;
        where
      %if &basedata ne %then a.pnr=b.pnr and ;
      %if &dlstcnt>1 %then (;
      %DO I=1 %to &dlstcnt;
        %let dval = %qscan(&opr,&i);
        %if &i>1 %then OR ;
          substr(%if &tilopr=TRUE %then a.tilopr; %else a.OPR;,1,%length(&dval)) = "&dval"
      %END;
      %if &dlstcnt>1 %then );
        and
        a.pattype in (%commas(&pattype)) and
		a.oprart in (%commas(&oprart))
        ;
    %END;
  %sqlquit;
  proc sort data=&localoutdata out=&outdata;
    by pnr opr indate oprdate;
  run;
  %cleanup(&localoutdata);
  data _null_;
    endOPRtime = datetime();
    timeOPRdif=endOPRtime-&startOPRtime;
    put 'executiontime FindingOPR ' timeOPRdif:time20.6;
  run;
%MEND;
%macro combineOPRTables(outlib, name);
  data temp;
    set &name &name._uaf;
	by pnr;
	/* create a compareid - makes it easier to reduce lines */
	sp ="_";
	compareid = catx(sp, of pnr opr indate oprdate pattype oprart hospital);
  %runquit;
  proc sort data=temp nodupkey;
    by compareid pnr opr indate outdate oprdate pattype oprart hospital rec_in rec_out;
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
