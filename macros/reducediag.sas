/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: reduceDiag.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/*
  #+NAME
    %reduceDiag
  #+TYPE
    SAS
  #+DESCRIPTION
    Output data from %getDiag is reduced to a status at
    a specified time. Is packed within getDiag.sas.
    The macro is called outside a datastep.
  #+SYNTAX
    %reduceDiag(
      indata,    Input dataset name, should be output from %findingLPRcases. Required.
      outdata,   Output dataset name. Required.
      outcome,   Short text string to label the outcome. Required.
      IndexDate,  Date variable in indata or basedata= or date constant, defining
                   the date of required disease status. Optional.
      basedata=, Input dataset with required population. Optional.
      ajour=,    Date for dataset, defaults to today.
  );
  #+OUTPUT:
      pnr
    &IndexDate
      &outcome.FiDateBe&IndexDate "First date for &outcome diagnose before inclusion event, &IndexDate";
      &outcome.LaDateBe&IndexDate "Last date for &outcome diagnose before inclusion event, &IndexDate";
      &outcome.FiDiagBe&IndexDate "First &outcome code before inclusion event, &IndexDate";
      &outcome.LaDiagBe&IndexDate "Last &outcome code before inclusion event, &IndexDate";
      &outcome.FiPattypeBe&IndexDate "First pattype for &outcome diagnose before inclusion event, &IndexDate";
      &outcome.LaPattypeBe&IndexDate "Last pattype for &outcome diagnose before inclusion event, &IndexDate";
      &outcome.DateAf&IndexDate "Date for &outcome diagnose after inclusion event, &IndexDate";
      &outcome.DiagAf&IndexDate "&outcome code after inclusion event, &IndexDate";
      &outcome.OutDateAf&IndexDate "Discharge date for &outcome diagnose after inclusion event, &IndexDate";
      &outcome.PattypeAf&IndexDate " Pattype after inclusion event, &IndexDate";
      &outcome.EventsAf&IndexDate "Number of events after inclusion event, &IndexDate";
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date        Initials  Status
    17-02-2013  FLS       Added &outcome.Events counting up number of events after inclusion.
    20-05-2015  FLS       Updated to SQL version
    31-07-2015  JNK       Updated to hist version
    10-08-2015  JNK       Changed variablename afterbase to afterbase_local.
                          replaced quit with %sqlquit.
    18-08-2015  FLS       changed IndexDate argument from optional to positional
    21-08-2015  JNK       Using a temp-table as an intermediate step
    10-10-2016  JNK       Remamed Last=La, First=Fi, Before=Be, After=Af
      */
%MACRO reduceDiag(indata,outdata,outcome,IndexDate,basedata=, ajour=);
  %local temp;
  %if "&ajour" eq ""  %then %let ajour=today(); /* jnk added */
  %put start reduceDiag: %qsysfunc(datetime(), datetime20.3), udtræksdato = &ajour;
  %let temp=%NewDatasetName(temp);
  proc sql;
    create table &temp as
      select a.* %if &IndexDate ne %then , &IndexDate, (&IndexDate<indate) as afterbase_local;
      %if &IndexDate = %then , 1 as afterbase_local;
      from &indata a   %if &basedata ne %then , &basedata b ;
      where
      %if &basedata ne %then a.pnr=b.pnr and ;
      &ajour between a.rec_in and a.rec_out
      order by pnr,  %if &IndexDate ne %then  &IndexDate,;
      indate, outdate, diagnose desc, diagtype;
  %sqlquit;
  data &outdata ; set &temp;
    by pnr %if &IndexDate ne %then &IndexDate; afterbase_local;
    length %if &IndexDate ne %then
    &outcome.FiDiagBe&IndexDate
    &outcome.LaDiagBe&IndexDate
    ;
    &outcome.DiagAf&IndexDate $6;
    retain
    %if &IndexDate ne %then
      &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
      &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate
      &outcome.FiDiagBe&IndexDate     &outcome.LaDiagBe&IndexDate
      &outcome.FiDiagtypeBe&IndexDate &outcome.LaDiagtypeBe&IndexDate
      &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate;
    &outcome.DateAf&IndexDate       &outcome.OutDateAf&IndexDate
    &outcome.DiagAf&IndexDate       &outcome.PattypeAf&IndexDate
    &outcome.DiagtypeAf&IndexDate   &outcome.EventsAf&IndexDate;
    format
    %if &IndexDate ne %then
      &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
      &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate;
    &outcome.DateAf&IndexDate       &outcome.OutDateAf&IndexDate date.;
    if %if &IndexDate ne %then first.&IndexDate; %if &IndexDate = %then first.pnr; then do;
      %if &IndexDate ne %then %do;
	      &outcome.FiDateBe&IndexDate     =.;
	      &outcome.LaDateBe&IndexDate     =.;
	      &outcome.FiOutDateBe&IndexDate  =.;
	      &outcome.LaOutDateBe&IndexDate  =.;
	      &outcome.FiDiagBe&IndexDate     ="";
	      &outcome.FiDiagtypeBe&IndexDate ="";
	      &outcome.LaDiagBe&IndexDate     ="";
	      &outcome.LaDiagTypeBe&IndexDate ="";
	      &outcome.FiPattypeBe&IndexDate  =.;
	      &outcome.LaPattypeBe&IndexDate  =.;
      %end;
      &outcome.DateAf&IndexDate    =.;
	    &outcome.OutDateAf&IndexDate =.;
	    &outcome.PattypeAf&IndexDate =.;
	    &outcome.DiagtypeAf&IndexDate="";
	    &outcome.DiagAf&IndexDate    ="";
	    &outcome.EventsAf&IndexDate  =0;
    end;
    %if &IndexDate ne %then %do;
      if first.afterbase_local and afterbase_local=0 then do;
	      &outcome.FiDateBe&IndexDate     = indate;
        &outcome.FiOutDateBe&IndexDate  = outdate;
	      &outcome.FiDiagBe&IndexDate     = diagnose;
	      &outcome.FiDiagtypeBe&IndexDate = diagtype;
	      &outcome.FiPattypeBe&IndexDate  = pattype;
      end;
      if last.afterbase_local and afterbase_local=0 then do;
	      &outcome.LaDateBe&IndexDate     = indate;
        &outcome.LaOutDateBe&IndexDate  = outdate;
	      &outcome.LaDiagBe&IndexDate     = diagnose;
	      &outcome.LaDiagtypeBe&IndexDate = diagtype;
	      &outcome.LaPattypeBe&IndexDate  = pattype;
      end;
    %end;
    if first.afterbase_local and afterbase_local=1 then do;
      &outcome.DateAf&IndexDate=indate;
      &outcome.DiagAf&IndexDate=diagnose;
	    &outcome.OutDateAf&IndexDate  = outdate;
      &outcome.PattypeAf&IndexDate=pattype;
      &outcome.DiagtypeAf&IndexDate=diagtype;
    end;
    if afterbase_local=1 then &outcome.EventsAf&IndexDate +1;
    if %if &IndexDate ne %then last.&IndexDate; %if &IndexDate = %then last.pnr; then output;
    keep pnr
    %if &IndexDate ne %then &IndexDate
      &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
      &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate
      &outcome.FiDiagBe&IndexDate     &outcome.LaDiagBe&IndexDate
	    &outcome.FiDiagtypeBe&IndexDate &outcome.LaDiagTypeBe&IndexDate
	    &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate;
	  &outcome.DateAf&IndexDate       &outcome.DiagAf&IndexDate
	  &outcome.OutDateAf&IndexDate    &outcome.DiagtypeAf&IndexDate
	  &outcome.PattypeAf&IndexDate    &outcome.EventsAf&IndexDate;
    %if &IndexDate ne %then %do;
      label &outcome.FiDateBe&IndexDate     = "First date for &outcome diagnose Before inclusion event, &IndexDate";
      label &outcome.LaDateBe&IndexDate     = "Last  date for &outcome diagnose Before inclusion event, &IndexDate";
      label &outcome.FiOutDateBe&IndexDate  = "First outdate for &outcome diagnose Before inclusion event, &IndexDate";
      label &outcome.LaOutDateBe&IndexDate  = "Last  outdate for &outcome diagnose Before inclusion event, &IndexDate";
      label &outcome.FiDiagBe&IndexDate     = "First &outcome code Before inclusion event, &IndexDate";
      label &outcome.LaDiagBe&IndexDate     = "Last  &outcome code Before inclusion event, &IndexDate";
      label &outcome.FiDiagtypeBe&IndexDate = "First &outcome code type Before inclusion event, &IndexDate";
      label &outcome.LaDiagtypeBe&IndexDate = "Last  &outcome code type Before inclusion event, &IndexDate";
      label &outcome.FiPattypeBe&IndexDate  = "First pattype for &outcome diagnose Before inclusion event, &IndexDate";
      label &outcome.LaPattypeBe&IndexDate  = "Last  pattype for &outcome diagnose Before inclusion event, &IndexDate";
    %end;
    label &outcome.DiagAf&IndexDate         = "&outcome code After inclusion event, &IndexDate";
    label &outcome.PattypeAf&IndexDate      = "Pattype After inclusion event, &IndexDate";
    label &outcome.DiagtypeAf&IndexDate     = "&outcome code type After inclusion event, &IndexDate";
    label &outcome.DateAf&IndexDate         = "Date for &outcome diagnose After inclusion event, &IndexDate";
    label &outcome.OutDateAf&IndexDate      = "OutDate for &outcome diagnose After inclusion event, &IndexDate";
    label &outcome.EventsAf&IndexDate       = "Number of events After inclusion event";
    %if &IndexDate = %then %do;
      rename &outcome.DiagAf&IndexDate     = &outcome.Diag;
      rename &outcome.DateAf&IndexDate     = &outcome.Date;
      rename &outcome.PattypeAf&IndexDate  = &outcome.Pattype;
      rename &outcome.DiagtypeAf&IndexDate = &outcome.Diagtype;
	    rename &outcome.OutDateAf&IndexDate   = &outcome.OutDate;
      rename &outcome.EventsAf&IndexDate   = &outcome.Events;
    %end;
    %RunQuit;
    %cleanup(&temp); /* ryd op i work */
  %mend;
