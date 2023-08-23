/* baseDiag */

%macro baseDiag(IndexDate, sets, postfix=, censordate=&globalend, keepDiag=FALSE, keepPat=FALSE, keepDate=FALSE, keepBefore=TRUE, keepAfter=TRUE, keepStatus=TRUE);
%local N nsets var;
%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list only if larger than 2 */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets=%sysfunc(countw(&newsets));
%end;

%do N=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets,&N))))&postfix;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepBefore)=TRUE %then %do;
    &var.Be&IndexDate = (&var.FidateBe&IndexDate ne .);
	format &var.Be&IndexDate yesno.;
  %end;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepAfter)=TRUE %then %do;
    &var.fupDate&IndexDate = &var.dateAf&IndexDate;
	&var.fup&IndexDate =  (.< &var.fupDate&IndexDate<&censordate);
	if &var.fup&IndexDate=0 then &var.fupDate&IndexDate=.;
	format &var.fup&IndexDate yesno.;
	format &var.fupDate&IndexDate date7.;
  %end;
%end;
void=.;
%do N=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets, &N))))&postfix;
  drop void
  %if %upcase(&keepDate) = FALSE or %upcase(&keepBefore)=FALSE  %then &var.FidateBe&IndexDate      &var.LadateBe&IndexDate
                                                                      &var.FiOutdateBe&IndexDate   &var.LaOutdateBe&IndexDate;
  %if %upcase(&keepDate) = FALSE or %upcase(&keepAfter) =FALSE  %then &var.dateAf&IndexDate        &var.OutdateAf&IndexDate;
  %if %upcase(&keepDiag) = FALSE or %upcase(&keepBefore)=FALSE  %then &var.FidiagBe&IndexDate      &var.LadiagBe&IndexDate
                                                                      &var.FiDiagtypeBe&IndexDate  &var.LaDiagtypeBe&IndexDate;
  %if %upcase(&keepDiag) = FALSE or %upcase(&keepAfter) =FALSE  %then &var.diagAf&IndexDate        &var.DiagtypeAf&IndexDate;
  %if %upcase(&keepPat)  = FALSE or %upcase(&keepBefore)=FALSE  %then &var.FipattypeBe&IndexDate   &var.LapattypeBe&IndexDate;
  %if %upcase(&keepPat)  = FALSE or %upcase(&keepAfter) =FALSE  %then &var.pattypeAf&IndexDate;
  %if %upcase(&keepAfter)= FALSE                                %then &var.EventsAf&IndexDate;
  ;
  %end;
  %mend;
