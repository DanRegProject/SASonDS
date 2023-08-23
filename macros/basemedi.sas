/* SVN header
$Date: 2019-11-14 15:10:49 +0100 (to, 14 nov 2019) $
$Revision: 210 $
$Author: wnm6683 $
$Id: baseMedi.sas 210 2019-11-14 14:10:49Z wnm6683 $
*/
/*
  #+NAME
    %baseMedi
  #+TYPE
    SAS
  #+DESCRIPTION
    Utility to rename and restrict which variables to keep within a
    studydataset. It is assumed that data are prepared with %mergeMedi.
    The macro is called inside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %baseMedi(
      IndexDate,          Event date variable
      sets                Medications, list refering to standard names
      censordate=censordate,    Date variable, time to stop
      keepDrug=FALSE,     Keep Drug information, last before and first after
      keepPS=FALSE,       Keep package size information, last before and first after
      keepVol=FALSE,      Keep volume information, last before and first after
      keepVTT=FALSE,      Keep volume text information, last before and first after
      keepStr=FALSE,      Keep strength information, last before and first after
      keepUnit=FALSE,     Keep strength unit information, last before and first after
      keepDate=FALSE      Keep prescription date information, last before and first after
      keepBefore=TRUE,    Keep information beforeIndexDate
      keepAfter=TRUE,     Keep information after IndexDate
      keepStatus=TRUE     Keep status variables (&var.Be,&var.fup,and &var.fupDate)
      StatusType=1,       How to calculate baseline status?
                            0: last package DDD reach until IndexDate
                            1: last prescription less than StatusCrit days beforeIndexDate
      StatusCrit=365      Criteria for StatusType
    );
    See t017../code/makedata.sas for an example.
  #+OUTPUT
    without changed options, &var.baseline, &var.fup as indicators are
    produced. baseline flag is 1 if last expedition date is less than
    standard daily doses beforeIndexDate. fupDate is first expeditiondate
    after ter IndexDate.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials    Status
    21-01-2013  FLS     Macro added
    16-12-2014  FLS     For some reason keepBefore and keepAfter was not coded correctly
    07-01-2015  FLS     Variable selection finally correct
    10-10-2016  JNK     Remamed Last=La, First=Fi, Before=Be, After=Af
    18-05-2017  JNK     using Prefix everywhere.
*/
%macro baseMedi(IndexDate,sets,censordate=&globalend,keepDrug=FALSE,keepPS=FALSE,keepVol=FALSE,
	                keepVTT=FALSE,keepStr=FALSE,keepUnit=FALSE,keepNPack=FALSE,keepDate=FALSE,
	                keepBefore=TRUE,keepAfter=TRUE,keepStatus=TRUE,StatusType=1,StatusCrit=365,postfix=);
%nonrep(mvar=sets, outvar=newsets);
%local I nsets var;
%let nsets=%sysfunc(countw(&newsets));
%do I=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&newsets,&I))));
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepBefore)=TRUE %then %do;
    if &var.&postfix.LaEksdBe&IndexDate ne . then do; /* avoid calculations on non-existing values */
      &var.&postfix.baseline&IndexDate=(&var.&postfix.LaEksdBe&IndexDate ne . and &IndexDate- &var.&postfix.LaEksdBe&IndexDate lt
      %if &StatusType=0 %then &var.&postfix.LaVolBe&IndexDate;
	  %if &StatusType=1 %then &StatusCrit;
      );
	end;
	else do;
	  &var.&postfix.baseline&IndexDate = 0; /* if &var.&postfix.LaEksdBe&IndexDate is not available, then set baseline to NO (0) */
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
