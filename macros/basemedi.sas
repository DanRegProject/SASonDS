/* baseatc */

%macro basemedi(IndexDate, sets, censordate=&globalend, keepDrug=FALSE,
               keepPS=FALSE, keepVol=FALSE, keepVTT=FALSE, keepStr=FALSE, keepUnit=FALSE, keepNPack=FALSE, keepDate=FALSE,
			   keepBefore=TRUE, keepAfter=TRUE, keepStatus=TRUE, StatusType=1, StatusCrit=365, postfix=);

%nonrep(mvar=sets, outvar=newsets);
%local I nsets var;
%let nsets=%sysfunc(countw(&newsets));

%do I=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&newsets,&I))));
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepBefore)=TRUE %then %do;
    if &var.&postfix.LaEksdBe&IndexDate ne . then do ; /* avoid calculation on non-existing values */
      &var.&postfix.baseline&IndexDate=(&var.&postfix.LaEksdBe&IndexDate ne . and &IndexDate- &var.&postfix.LaEksdBe&IndexDate lt
      %if &StatusType=0 %then &var.&postfix.LaVolBe&IndexDate;
  	  %if &StatusType=1 %then &StatusCrit;
      );
	end;
	else do;
      &var.&postfix.baseline&IndexDate=0; /* set to false if &var.&postfix.LaEksdBe&IndexDate does not exist */
	end;
    format &var.&postfix.baseline&IndexDate yesno.;
  %end;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepAfter)=TRUE %then %do;
	&var.&postfix.fupDate&IndexDate=&var.&postfix.FiEksdAf&IndexDate;
	&var.&postfix.fup&IndexDate=(.< &var.&postfix.fupDate&IndexDate < &censordate);
	if &var.&postfix.fup&IndexDate=0 then &var.&postfix.fupDate&IndexDate=.;
	format &var.&postfix.fup&IndexDate yesno.;
	format &var.&postfix.fupDate&IndexDate date7.;
  %end;
%end;
void=.;
%do I=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&newsets, &I))));
  drop void
  %if %upcase(&keepDrug) =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiDrugBe&IndexDate  &var.&postfix.LaDrugBe&IndexDate;
  %if %upcase(&keepDrug) =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiDrugAf&IndexDate;

  %if %upcase(&keepPS)   =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiPSBe&IndexDate    &var.&postfix.LaPSBe&IndexDate;
  %if %upcase(&keepPS)   =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiPSAf&IndexDate;

  %if %upcase(&keepVol)  =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiVolBe&IndexDate   &var.&postfix.LaVolBe&IndexDate;
  %if %upcase(&keepVol)  =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiVolAf&IndexDate;

  %if %upcase(&keepVTT)  =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiVTTBe&IndexDate   &var.&postfix.LaVTTBe&IndexDate;
  %if %upcase(&keepVTT)  =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiVTTAf&IndexDate;

  %if %upcase(&keepStr)  =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiStrBe&IndexDate   &var.&postfix.LaStrBe&IndexDate;
  %if %upcase(&keepStr)  =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiStrAf&IndexDate;

  %if %upcase(&keepUnit) =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiUnitBe&IndexDate  &var.&postfix.LaUnitBe&IndexDate;
  %if %upcase(&keepUnit) =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiUnitAf&IndexDate;

  %if %upcase(&keepNPack)=FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiNPackBe&IndexDate &var.&postfix.LaNPackBe&IndexDate;
  %if %upcase(&keepNPack)=FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiNPackAf&IndexDate;

  %if %upcase(&keepDate) =FALSE or %upcase(&keepBefore)=FALSE %then &var.&postfix.FiEksdBe&IndexDate  &var.&postfix.LaEksdBe&IndexDate;
  %if %upcase(&keepDate) =FALSE or %upcase(&keepAfter) =FALSE %then &var.&postfix.FiEksdAf&IndexDate;

;
%end;
%mend;

