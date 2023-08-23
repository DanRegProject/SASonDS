/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: subsetLPR.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/*
  Purpose        : Create a copy of the LPR master tables in work memory
  #+CHANGELOG
                   Date         Initials  Status
                   14.12.2016   JNK       Using DIAGInWork flag to test if tables are made. DiagInWork is set in common.sas
*/
%MACRO subsetLPR(outdata,basedata=,fromyear=1977, lastyear=&lastLPR);
    %local yr;
  %start_timer(subsetLPR);
  %if &DiagInWork = TRUE %then %do;
    %end_timer(subsetLPR, text='LPR tables are already in work');
  %end;
  %if &DiagInWork = FALSE %then %do;
    %do yr=&fromyear %to &lastyear;
    proc sql inobs=&sqlmax;
      create table &outdata&yr as
      select  a.*
      from Master.vwLPR&yr a
      %if &basedata ne %then , (select distinct pnr from &basedata) b where a.pnr=b.pnr;
      order by diagnose;
    %sqlquit;
    proc sql;
      create index pnr on &outdata&yr (pnr);
    %sqlquit;
    %end;
    %let DiagInWork = TRUE;
    %end_timer(subsetLPR, text='LPR tables from &fromyear to &lastyear copied to work, if &basedata then only the pnr in &basedata');
  %end;
%MEND;
