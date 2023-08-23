/* SVN header
$Date: 2021-06-11 08:24:24 +0200 (fr, 11 jun 2021) $
$Revision: 298 $
$Author: wnm6683 $
$Id: baseOPR.sas 298 2021-06-11 06:24:24Z wnm6683 $
*/
/*
  #+NAME
    %baseOPR
  #+TYPE
    SAS
  #+DESCRIPTION
    Utility to rename and restrict which variables to keep within a
    studydataset. It is assumed that data are prepared with %mergeOPR.
    The macro is called inside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %baseOPR(
    IndexDate,        Event date variable
    sets              Diagnoses, list refering to standard names
                       censordate=censordate,  Date variable, time to stop
    keepOpr=FALSE,    Keep Operation information, First and last before, and first after
    keepPat=FALSE,    Keep Patient type information, First and last before, and first after
    keepDate=FALSE,   Keep Date information, First and last before, and first after
    keepBefore=TRUE,  Keep information before IndexDate
    keepAfter=TRUE,   Keep information after IndexDate
    keepStatus=TRUE   Keep status variables (&var.before, &var.fup,and &var.fupDate)
  );
  See t017../code/makedata.sas for an example.
  #+OUTPUT
    without changed options, &var.baseline, &var.fup as indicators are produced.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials  Status
    21-01-13  FLS     Macro added
    16-12-14  FLS     For some reason keepBefore and keepAfter was not coded correctly
    07-01-15  FLS     Variable selection finally correct
    10-05-17  JNK     Changed names to Fi=first La=last Be=before Af=after
*/
%macro baseOPR(IndexDate,sets,censordate=&globalend,keepOpr=FALSE,keepPat=FALSE, keepdiag=FALSE,
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
	  &var.&postfix.fup&IndexDate=(. < &var.&postfix.dateAf&IndexDate < &censordate);
  	  format &var.&postfix.fup&IndexDate yesno.;
	  format &var.&postfix.fupDate&IndexDate date7.;
  %end;
%end;
void=.;
%do I=1 %to &nsets;
  drop void
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets, &I))));
  %if %upcase(&keepDate) =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FidateBe&IndexDate
                                                                     &var.&postfix.LadateBe&IndexDate;
  %if %upcase(&keepDate) =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.dateAf&IndexDate;
  %if %upcase(&keepOpr)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FiOprBe&IndexDate
                                                                     &var.&postfix.LaOprBe&IndexDate;
  %if %upcase(&keepOpr)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.OprAf&IndexDate;
  %if %upcase(&keepDiag)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FiOprDiagBe&IndexDate
                                                                     &var.&postfix.LaOprDiagBe&IndexDate;
  %if %upcase(&keepDiag)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.OprDiagAf&IndexDate;
  %if %upcase(&keepPat)  =FALSE or %upcase(&keepBefore) =FALSE %then &var.&postfix.FipattypeBe&IndexDate
                                                                     &var.&postfix.lapattypeBe&IndexDate;
  %if %upcase(&keepPat)  =FALSE or %upcase(&keepAfter)  =FALSE %then &var.&postfix.pattypeAf&IndexDate;
;
%end;
%mend;
