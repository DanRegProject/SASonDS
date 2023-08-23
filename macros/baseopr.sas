/* baseOPR */

%macro baseOPR(IndexDate, sets, censordate=&globalend, keepOpr=FALSE, keepPat=FALSE, keepDiag=FALSE,
               keepDate=FALSE, keepBefore=TRUE, keepAfter=TRUE, keepStatus=TRUE, postfix=);

%local I nsets var;
%let nsets=%sysfunc(countw(&sets));

%do I=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets,&I))));
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepBefore)=TRUE %then %do;
    &var.&postfix.Be&IndexDate =(&var.&postfix.FidateBe&IndexDate ne .);
    format &var.&postfix.Be&IndexDate yesno.;
  %end;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepAfter)=TRUE %then %do;
	&var.&postfix.fupDate&IndexDate=&var.&postfix.dateAf&IndexDate;
	&var.&postfix.fup&IndexDate=(. < &var.&postfix.dateAf&IndexDate < &censordate );
	format &var.&postfix.fup&IndexDate yesno.;
	format &var.&postfix.fupDate&IndexDate date7.;
  %end;
%end;
void=.;
%do I=1 %to &nsets;
  drop void
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets, &I))));
  %if %upcase(&keepDate) =FALSE or %upcase(&keepBefore) =FALSE %then
      &var.&postfix.FiDateBe&IndexDate &var.&postfix.LaDateBe&IndexDate
      &var.&postfix.FiIndateBe&IndexDate &var.&postfix.LaIndateBe&IndexDate
      &var.&postfix.FiOutdateBe&IndexDate &var.&postfix.LaOutdateBe&IndexDate;
  %if %upcase(&keepDate) =FALSE or %upcase(&keepAfter)  =FALSE %then
      &var.&postfix.DateAf&IndexDate
      &var.&postfix.IndateAf&IndexDate
      &var.&postfix.OutdateAf&IndexDate;

  %if %upcase(&keepOpr)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FiOprBe&IndexDate  &var.&postfix.LaOprBe&IndexDate;
  %if %upcase(&keepOpr)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.OprAf&IndexDate;

  %if %upcase(&keepDiag)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FiOprDiagBe&IndexDate  &var.&postfix.LaOprDiagBe&IndexDate;
  %if %upcase(&keepDiag)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.OprDiagAf&IndexDate;

  %if %upcase(&keepPat)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FipattypeBe&IndexDate &var.&postfix.LapattypeBe&IndexDate;
  %if %upcase(&keepPat)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.PattypeAf&IndexDate;
;
%end;
%mend;

