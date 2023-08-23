/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: subsetLMDB.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/*
  Purpose        : Create a copy of the LMDB master tables in work memory
  #+CHANGELOG
                   Date         Initials  Status
                   14.12.2016   JNK       Using MediInWork flag to test if tables are made. MediInWork is set in common.sas
*/
%MACRO subsetLMDB(outdata,basedata=,fromyear=1995, lastyear=&lastLMDB );
    %local yr;
  %start_timer(subsetLMDB);
  %if &MediInWork = TRUE %then %do;
    %end_timer(subsetLMDB, text='MEDI tables are already in work');
  %end;
  %if &MediInWork = FALSE %then %do;
    %do yr=&fromyear %to &lastyear;
    proc sql inobs=&sqlmax;
      create table &outdata&yr as
      select  a.*
      from Master.LMDB&yr a
      %if &basedata ne %then , (select distinct pnr from &basedata) b where a.pnr=b.pnr;
      order by pnr, atc;
    %sqlquit;
    proc sql;
      create index pnratc on &outdata&yr (pnr, atc);
    %sqlquit;
   %end;
    %let MediInWork = TRUE;
    %end_timer(subsetLMDB, text='LMDB tables from &fromyear to &lastyear copied to work, if &basedata then only the pnr in &basedata');
  %end;
%MEND;
