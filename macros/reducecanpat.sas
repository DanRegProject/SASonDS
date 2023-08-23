%macro reduceCanPat(indata, outdata, outcome, IndexDate, basedata=, ajour=today());
/*
tager indexet lavet af FindingDiag og reducerer til en række pr pnr
inddata:  input datasæt
outdata:  retur datasæt
outcome:  prefix for variable
IndexDate: postfix for variable
basedata: optional datasæt at tage IndexDate fra
*/
%local temp;
%put start reduceCanPat: %qsysfunc(datetime(), datetime20.3), udtræksdato=&ajour;

%let temp=%NewDatasetName(temp);


proc sql;
  create table &temp as
  select a.* %if &IndexDate ne %then, (&IndexDate<indate) as afterbase_local;
  %if &IndexDate = %then , 1 as afterbase_local;
  from &indata a %if &basedata ne %then , &basedata b;
  where
  %if &basedata ne %then a.pnr=b.pnr and;
  &ajour between a.rec_in and a.rec_out
  order by pnr, %if &IndexDate ne %then &IndexDate, ;
  indate, diag, morfo, stage;
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
  &outcome.FiMorfoBe&IndexDate	  &outcome.LaMorfoBe&IndexDate
  &outcome.FiStagebe&IndexDate	  &outcome.LaStageBe&indexdate
  &outcome.FiDiagBe&IndexDate     &outcome.LaDiagBe&IndexDate;
  &outcome.DateAf&IndexDate       &outcome.MorfoAf&IndexDate
  &outcome.StageAf&IndexDate	  &outcome.DiagAf&IndexDate;

  format
  %if &IndexDate ne %then &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate;
                          &outcome.DateAf&IndexDate       date.;
  format
    %if &IndexDate ne %then
      &outcome.FiMorfoBe&IndexDate &outcome.LaMorfoBe&IndexDate;
	  &outcome.MorfoAf&IndexDate $6.0; /* char */
  if %if &IndexDate ne %then first.&IndexDate; %if &IndexDate = %then first.pnr; then do;
    %if &IndexDate ne %then %do;
	  &outcome.FiDateBe&IndexDate     =.;
	  &outcome.LaDateBe&IndexDate     =.;
	  &outcome.FiMorfoBe&IndexDate    ="";
	  &outcome.LaMorfoBe&IndexDate 	  ="";
	  &outcome.FiStageBe&IndexDate    =.;
	  &outcome.LaStageBe&IndexDate 	  =.;
	  &outcome.FiDiagBe&IndexDate     ="";
	  &outcome.LaDiagBe&IndexDate     ="";
	%end;
    &outcome.DateAf&IndexDate    =.;
	&outcome.MorfoAf&IndexDate   ="";
	&outcome.StageAf&IndexDate   =.;
	&outcome.DiagAf&IndexDate    ="";
  end;
  %if &IndexDate ne %then %do;
    if first.afterbase_local and afterbase_local=0 then do;
	  &outcome.FiDateBe&IndexDate     = indate;
	  &outcome.FiMorfoBe&IndexDate    = morfo;
	  &outcome.FiStageBe&IndexDate	  = stage;
	  &outcome.FiDiagBe&IndexDate     = diag;
	end;
    if last.afterbase_local and afterbase_local=0 then do;
	  &outcome.LaDateBe&IndexDate     = indate;
	  &outcome.LaMorfoBe&IndexDate	  = morfo;
	  &outcome.LaStageBe&IndexDate	  = stage;
	  &outcome.LaDiagBe&IndexDate     = diag;
	end;
  %end;
  if first.afterbase_local and afterbase_local=1 then do;
  	&outcome.DateAf&IndexDate     = indate;
	&outcome.MorfoAf&IndexDate	  = morfo;
	&outcome.StageAf&IndexDate	  = stage;
	&outcome.DiagAf&IndexDate     = diag;
  end;
  if %if &IndexDate ne %then last.&IndexDate; %if &IndexDate = %then last.pnr; then output;
  keep pnr
  %if &IndexDate ne %then &IndexDate
    &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
	&outcome.FiMorfoBe&IndexDate	&outcome.LaMorfoBe&IndexDate
	&outcome.FiStageBe&IndexDate	&outcome.LaStageBe&IndexDate
    &outcome.FiDiagBe&IndexDate 	&outcome.LaDiagBe&IndexDate;
	&outcome.DateAf&IndexDate       &outcome.MorfoAf&IndexDate
	&outcome.StageAf&IndexDate		&outcome.DiagAf&IndexDate;
  %if &IndexDate ne %then %do;
    label &outcome.FiDateBe&IndexDate     = "First date for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.LaDateBe&IndexDate     = "Last  date for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.FiDiagBe&IndexDate     = "First &outcome code Before inclusion event, &IndexDate";
    label &outcome.LaDiagBe&IndexDate     = "Last  &outcome code Before inclusion event, &IndexDate";
	label &outcome.FiMorfoBe&IndexDate    = "First morfo code Before inclusion event, &IndexDate";
	label &outcome.LaMorfoBe&IndexDate    = "Last morfo code Before inclusion event, &IndexDate";
	label &outcome.FiStageBe&IndexDate 	  = "First Cancer stage Before inclusion event, &IndexDate";
	label &outcome.LaStageBe&IndexDate	  = "Last Cancer stage Before inclusion event, &IndexDate";
  %end;
  label &outcome.DiagAf&IndexDate         = "&outcome code After inclusion event, &IndexDate";
  label &outcome.DateAf&IndexDate         = "Date for &outcome diagnose After inclusion event, &IndexDate";
  label &outcome.MorfoAf&IndexDate   	  = "Morfo code After inclusion event, &IndexDate";
  lable &outcome.StageAf&indexDate		  = "Cancer stage after inclusion event, &IndexDate";
  %if &IndexDate = %then %do;
    rename &outcome.DiagAf&IndexDate      = &outcome.Diag;
	rename &outcome.DateAf&IndexDate      = &outcome.Date;
	rename &outcome.MorfoAf&IndexDate     = &outcome.Morfo;
	rename &outcome.StageAf&IndexDate 	  = &outcome.Stage;
  %end;
%RunQuit;
%cleanup(&temp); /*  ryd op i work */
%mend;





