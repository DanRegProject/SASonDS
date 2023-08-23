/* SVN header
$Date: 2020-09-24 09:39:57 +0200 (to, 24 sep 2020) $
$Revision: 241 $
$Author: fflb6683 $
$Id: getMedi.sas 241 2020-09-24 07:39:57Z fflb6683 $
*/
/*
  #+CHANGELOG
    Date      Initials  Status
    13.08.2015  JNK     Added LMDBdata as input.
    06.09.2016  JNK     Changing basedate to IndexDate, removing option of reduction and keeping history as a default
    11.10.2016  JNK     Adding basepop option, will create a combined table with basepopulation named &basepop
    15.11.2015  JNK     New masterfiles without *hist
	18.09.2020 	MJE		Add table prefix 
*/
%macro getMedi(outlib, medlist, basedata=, fromyear=1995, LMDBdata=Master.LMDB, basepop=);
  %local N nsets;
  %if "&fromyear" eq "" %then %let fromyear=1995;
  %if &fromyear<1995 %then %let fromyear=1995;
  %let nsets = %sysfunc(countw(&medlist));
  %if &nsets > 1 %then %do;
    %nonrep(mvar=medlist, outvar=newlist);
    %let nsets = %sysfunc(countw(&newlist));
    %let medlist = &newlist;
  %end;
  %do N=1 %to &nsets;
    %let medi = %lowcase(%scan(&medlist, &N));
    %findingMedi(&outlib..LMDB&medi.ALL, &medi, &&ATC&Medi, basedata=&basedata, fromyear=&fromyear,LMDBdata=&LMDBdata);
    %if &basepop ne %then %do;
      proc sql inobs=&sqlmax;
        %if &N=1 %then create table &outlib..&basepop as ;
        %else insert into &outlib..&basepop;
        select pnr, eksd as IDate length=8, &medi as drug length=10, rec_in, rec_out
        from &outlib..LMDB&medi.ALL;
      %sqlquit;
    %end;
  %end;
  %if &basepop ne %then %do;
    proc sort data = &outlib..&basepop; /* do not reduce to one list now, because the ajourdate is not specified */
      by pnr idate drug rec_out;
    %runquit;
  %end;
%mend;
/*
  #+NAME
    %getMedi
  #+TYPE
    SAS
  #+DESCRIPTION
    Extract prescription data on specific ATC codes for a
    population. Output dataset can optionally be reduced to a status at a
    specified time, using ''%reducerFA''. Other reduction macro's are also
    available.
    The macro is called outside a datastep.
  #+SYNTAX
    %findingATCperiods(
    outdata:       output datasætnavn
    drug:          string drug label, should be short
    atc:           ATC codes for drugs adskilles med mellemrum
    basedata:      input datasæt med identer og skæringsdato
    leapdays:      days needed to achive a break in medication
    leapdaysratio: ratio of achieve a break in medication
    LMDBdata:      points to master.lmdb, can be changed to using a specific directory in work.
  );
  #+OUTPUT
   if reduce=FALSE:
   pnr eksd &drug NPack packsize volume voltypetxt strnum struni
   additionally if IndexDate is specified:
   IndexDate afterbase
   if reduce=TRUE:
   see %reducerFA documentation.
  %findingATCperiods(dabi1,dabi,B01AE07,basedata=AFptred1,IndexDate=AFDate,reduce=FALSE);
  %reducerFA(dabi1,dabi1red,dabi,AFDate);
    is the same as
  %findingATCperiods(dabi2,dabi,B01AE07,basedata=AFptred1,IndexDate=AFDate,reduce=TRUE);
    is the same as
  %findingATCperiods(dabi2,dabi,B01AE07,basedata=AFptred1,IndexDate=AFDate);
    is not the same as
  %findingATCperiods(dabi3,dabi,B01AE07);
  #+AUTHOR
    Flemming Skjøth
*/
%MACRO findingMedi(outdata,drug,atc,basedata=, fromyear=,LMDBdata=);
  %local I sqlrc yr dval dlstcnt;
  %let sqlrc=0;
  %put "extract based on population in &basedata";

  /* log speed */
  /* print linie med aktuelt udtrækstidspunkt */
  %put start findingMedi: %qsysfunc(datetime(), datetime20.3);
  %let startMeditime = %qsysfunc(datetime());
  %let dlstcnt = %sysfunc(countw(&atc));
  proc sql inobs=&sqlmax;
    %if &sqlrc=0 %then %do;
      %do yr=&fromyear %to &lastLMDB;
          create table _temp_ as
          select  a.pnr, a.eksd, a.atc as &drug, a.apk as NPack, a.packsize, a.volume, a.voltypetxt, a.strnum,
          a.strunit, a.rec_in, a.rec_out, today() as udtrkdate format=date., a.DataValidUntil format=date.
          from &LMDBdata&yr a
          where
          %if &dlstcnt>1 %then (;
          %DO I=1 %to &dlstcnt;
            %let dval = %qscan(&atc,&i);
            %if &i>1 %then OR ;
            substr(a.atc,1,%length(&dval)) = "&dval"
          %END;
          %if &dlstcnt>1 %then );
          order by a.pnr ;
          %if &sqlrc=0 %then %do;
            %if &yr=&fromyear  %then create table &outdata as ;
            %else insert into &outdata ;
            select  a.*
            from _temp_ a
            %if &basedata ne %then , &basedata b where a.pnr=b.pnr
            ;;
          %END;
        %end;
    %sqlquit;
    %end;
    PROC SORT DATA=&outdata;
      BY pnr &drug eksd;
    RUN;
  data _null_;
      endMeditime=datetime();
      timeMedidif=endMeditime - &startMeditime;
      put 'execution time FindingMedi ' timeMedidif:time20.6;
  run;
%MEND;
