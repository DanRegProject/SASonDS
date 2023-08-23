/* SVN header
$Date: 2021-08-16 14:18:52 +0200 (ma, 16 aug 2021) $
$Revision: 302 $
$Author: wnm6683 $
$Id: reduceOPR.sas 302 2021-08-16 12:18:52Z wnm6683 $
*/
/*
  #+NAME
    %reduceOPR
  #+TYPE
    SAS
  #+DESCRIPTION
  Output data from %getOPR is reduced to a status with only one pnr at
  a specified time. Is packed within findingOPRcases.sas.
  The macro is called outside a datastep.
  #+SYNTAX
    %reduceOPR(
      indata, Input dataset name, should be output from %findingOPRcases. Required.
      outdata,  Output dataset name. Required.
      outcome,  Short text string to label the outcome. Required.
      IndexDate, Date variable in indata or basedata= or date constant, defining
              the date of required disease status. Optional.
      basedata= Input dataset with required population. Optional.
    );
  #+OUTPUT:
    pnr
  if IndexDate is given:
  &IndexDate
  outcome.FiDateBe&IndexDate "First date for &outcome operation Be inclusion event, &IndexDate";
  &outcome.LastDateBe&IndexDate "Last date for &outcome operation Be inclusion event, &IndexDate";
  &outcome.FiOprBe&IndexDate "First &outcome code Be inclusion event, &IndexDate";
  &outcome.LastOprBe&IndexDate "Last &outcome code Be inclusion event, &IndexDate";
  &outcome.FiPattypeBe&IndexDate "First pattype for &outcome operation Be inclusion event, &IndexDate";
  &outcome.LastPattypeBe&IndexDate "Last pattype for &outcome operation Be inclusion event, &IndexDate";
  &outcome.DateAf&IndexDate "Date for &outcome operation Af inclusion event, &IndexDate";
  &outcome.OprAf&IndexDate "&outcome code Af inclusion event, &IndexDate";
  &outcome.OutDateAf&IndexDate "Discharge date for &outcome operation Af inclusion event, &IndexDate";
  &outcome.PattypeAf&IndexDate " Pattype Af inclusion event, &IndexDate";
  &outcome.EventsAf&IndexDate "Number of events Af inclusion event, &IndexDate";
  if &IndexDate is not specified:
  &outcome.Opr "&outcome code"
    &outcome.Date  "Date for &outcome operation";
    &outcome.Pattype "Pattype";
    &outcome.OutDate "Discharge date";
  &outcome.Events "Number of events";
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials  Status
*/
%MACRO reduceOPR(indata,outdata,outcome,IndexDate,basedata=, ajour=);
  %put start reduceOPR: %qsysfunc(datetime(), datetime20.3), udtræksdato=&ajour;
  %local temp;
  %let temp=%NewDatasetName(tempopr);
  proc sql;
    create table &temp as
        select a.pnr, a.oprdate, a.indate, a.outdate, a.opr, a.pattype,
        a.oprart, a.oprdiag
    %if &IndexDate ne %then, &IndexDate, (&IndexDate<a.oprdate) as afterbase_local;
    %if &IndexDate = %then , 1 as afterbase_local;
    from &indata a %if &basedata ne %then , &basedata b;
    where

    %if &basedata ne %then a.pnr=b.pnr and;
    &ajour between a.rec_in and a.rec_out
    order by pnr, %if &IndexDate ne %then &IndexDate, ;
    oprdate, indate, outdate, opr desc, oprart;
    delete from &temp where oprdate=.;
  %sqlquit;
  data &outdata;
    set &temp;
    by pnr %if &IndexDate ne %then &IndexDate; afterbase_local;
    length %if &IndexDate ne %then %do;
      &outcome.FioprBe&IndexDate
      &outcome.LaOprBe&IndexDate
      &outcome.FioprDiagBe&IndexDate
      &outcome.LaOprDiagBe&IndexDate
    %end;
    &outcome.OprAf&IndexDate &outcome.OprDiagAf&IndexDate $8.;
    retain
    %if &IndexDate ne %then
        &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
        &outcome.FiIndateBe&IndexDate   &outcome.LaIndateBe&IndexDate
        &outcome.FiOutdateBe&IndexDate  &outcome.LaOutdateBe&IndexDate
        &outcome.FiOprBe&IndexDate      &outcome.LaOprBe&IndexDate
        &outcome.FiOprDiagBe&IndexDate  &outcome.LaOprDiagBe&IndexDate
        &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate
        ; /* end of %then */
        &outcome.DateAf&IndexDate
        &outcome.IndateAf&IndexDate     &outcome.OutdateAf&IndexDate
        &outcome.OprAf&IndexDate        &outcome.OprdiagAf&IndexDate
        &outcome.PattypeAf&IndexDate    &outcome.EventsAf&IndexDate;
    format
    %if &IndexDate ne %then
        &outcome.FiDateBe&IndexDate    &outcome.LaDateBe&IndexDate
        &outcome.FiIndateBe&IndexDate  &outcome.LaIndateBe&IndexDate
        &outcome.FiOutDateBe&IndexDate &outcome.LaOutdateBe&IndexDate;
    &outcome.DateAf&IndexDate  &outcome.IndateAf&IndexDate  &outcome.OutdateAf&IndexDate date.;
    if %if &IndexDate ne %then first.&IndexDate; %if &IndexDate = %then first.pnr; then do;
    %if &IndexDate ne %then %do;
        &outcome.FiDateBe&IndexDate=.;
        &outcome.LaDateBe&IndexDate=.;
        &outcome.FiIndateBe&IndexDate=.;
        &outcome.LaIndateBe&IndexDate=.;
        &outcome.FiOutdateBe&IndexDate=.;
        &outcome.LaOutdateBe&IndexDate=.;
        &outcome.FiOprBe&IndexDate="";
        &outcome.LaOprBe&IndexDate="";
        &outcome.FiOprDiagBe&IndexDate="";
        &outcome.LaOprDiagBe&IndexDate="";
        &outcome.FiPattypeBe&IndexDate=.;
        &outcome.LaPattypeBe&IndexDate=.;
      %end;
      &outcome.DateAf&IndexDate=.;
      &outcome.IndateAf&IndexDate=.;
      &outcome.OutDateAf&IndexDate=.;
      &outcome.PattypeAf&IndexDate=.;
      &outcome.OprAf&IndexDate="";
      &outcome.OprDiagAf&IndexDate="";
      &outcome.EventsAf&IndexDate=0;
    end;
    %if &IndexDate ne %then %do;
      if First.afterbase_local and afterbase_local=0 then do;
          &outcome.FiDateBe&IndexDate=Oprdate;
          &outcome.FiIndateBe&IndexDate=indate;
          &outcome.FiOutdateBe&IndexDate=outdate;
          &outcome.FiOprBe&IndexDate=Opr;
          &outcome.FiOprDiagBe&IndexDate=Oprdiag;
          &outcome.FiPattypeBe&IndexDate=pattype;
      end;
      if Last.afterbase_local and afterbase_local=0 then do;
          &outcome.LaDateBe&IndexDate=oprdate;
          &outcome.LaIndateBe&IndexDate=indate;
          &outcome.LaOutdateBe&IndexDate=outdate;
          &outcome.LaOprBe&IndexDate=Opr;
          &outcome.LaOprDiagBe&IndexDate=Oprdiag;
          &outcome.LaPattypeBe&IndexDate=pattype;
      end;
    %end;
    if First.afterbase_local and afterbase_local=1 then do;
        &outcome.DateAf&IndexDate=oprdate;
        &outcome.IndateAf&IndexDate=indate;
        &outcome.OutdateAf&IndexDate=outdate;
        &outcome.OprAf&IndexDate=Opr;
        &outcome.OprDiagAf&IndexDate=Oprdiag;
        &outcome.PattypeAf&IndexDate=pattype;
    end;
    if afterbase_local=1 then &outcome.EventsAf&IndexDate +1;
    if %if &IndexDate ne %then last.&IndexDate; %if &IndexDate = %then last.pnr; then output;
    keep pnr
    %if &IndexDate ne %then &IndexDate
        &outcome.FiDateBe&IndexDate    &outcome.LaDateBe&IndexDate
        &outcome.FiIndateBe&IndexDate  &outcome.LaIndateBe&IndexDate
        &outcome.FiOutdateBe&IndexDate &outcome.LaOutdateBe&IndexDate
        &outcome.FiOprBe&IndexDate     &outcome.LaOprBe&IndexDate
        &outcome.FiOprDiagBe&IndexDate &outcome.LaOprDiagBe&IndexDate
        &outcome.FiPattypeBe&IndexDate &outcome.LaPattypeBe&IndexDate;
    &outcome.DateAf&IndexDate      &outcome.OprAf&IndexDate        &outcome.OprDiagAf&IndexDate
    &outcome.IndateAf&IndexDate    &outcome.OutdateAf&IndexDate
    &outcome.PattypeAf&IndexDate   &outcome.EventsAf&IndexDate;
    %if &IndexDate ne %then %do;
    label &outcome.FiOprBe&IndexDate       = "First &outcome code before inclusion event, &IndexDate";
    label &outcome.LaOprBe&IndexDate       = "Last  &outcome code before inclusion event, &IndexDate";
    label &outcome.FiOprDiagBe&IndexDate   = "First diagnose for &outcome code before inclusion event, &IndexDate";
    label &outcome.LaOprDiagBe&IndexDate   = "Last diagnose for d&outcome code before inclusion event, &IndexDate";
    label &outcome.FiDateBe&IndexDate      = "First date for &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaDateBe&IndexDate      = "Last  date for &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiIndateBe&IndexDate      = "First start date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaIndateBe&IndexDate      = "Last start date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiOutdateBe&IndexDate      = "First discharge date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaOutdateBe&IndexDate      = "Last discharge date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiPattypeBe&IndexDate   = "First pattype for &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaPattypeBe&IndexDate   = "Last  pattype for &outcome operation before inclusion event, &IndexDate";
    %end;
  label &outcome.OprAf&IndexDate       = "&outcome code after inclusion event, &IndexDate";
  label &outcome.OprDiagAf&IndexDate   = "Diagnose for &outcome code after inclusion event, &IndexDate";
  label &outcome.PattypeAf&IndexDate   = "Pattype after inclusion event, &IndexDate";
  label &outcome.DateAf&IndexDate      = "Date for &outcome operation after inclusion event, &IndexDate";
  label &outcome.IndateAf&IndexDate      = "Start date for contact of &outcome operation after inclusion event, &IndexDate";
  label &outcome.OutdateAf&IndexDate   = "Discharge date for contact of &outcome operation after inclusion event, &IndexDate";
  label &outcome.EventsAf&IndexDate    = "Number of events after inclusion event";
    %if &IndexDate = %then %do;
      rename &outcome.OprAf&IndexDate     = &outcome.Opr;
      rename &outcome.OprDiagAf&IndexDate = &outcome.Oprdiag;
      rename &outcome.DateAf&IndexDate    = &outcome.Date;
      rename &outcome.PattypeAf&IndexDate = &outcome.Pattype;
      rename &outcome.IndateAf&IndexDate = &outcome.Indate;
      rename &outcome.OutDateAf&IndexDate = &outcome.OutDate;
      rename &outcome.EventsAf&IndexDate  = &outcome.Events;
    %end;
  %RunQuit;
  %cleanup(&temp); /* ryd op i work */
%MEND;
