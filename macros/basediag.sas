/* SVN header
$Date: 2019-11-14 15:10:49 +0100 (to, 14 nov 2019) $
$Revision: 210 $
$Author: wnm6683 $
$Id: baseDiag.sas 210 2019-11-14 14:10:49Z wnm6683 $
*/
/*
  #+NAME
    %baseDiag
  #+TYPE
    SAS
  #+DESCRIPTION
    Utility to rename and restrict which variables to keep within a
    studydataset. It is assumed that data are prepared with %mergeLPR.
    The macro is called inside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %baseLPR(
      IndexDate,             Event date variable
      sets                   Diagnoses, list refering to standard names
      postfix=,              Short string if used i call to %mergeLPR()
      censordate=censordate, Date variable, time to stop
      keepDiag=FALSE,        Keep Diagnose information, First and last before, and first after
      keepPat=FALSE,         Keep Patient type information, First and last before, and first after
      keepDate=FALSE,        Keep Date information, First and last before, and first after
      keepBefore=TRUE,       Keep information before IndexDate
      keepAfter=TRUE,        Keep information after IndexDate
      keepStatus=TRUE        Keep status variables (&var.before, &var.fup,and &var.fupDate)
  );
  See t017../code/makedata.sas for an example.
  #+OUTPUT
    without changed options, &var.baseline, &var.fup as indicators are produced.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials    Status
    21-01-2013  FLS     Macro added
    16-12-2014  FLS     For some reason keepBefore and keepAfter was not coded correctly
    07-01-2015  FLS     Variable selection finally correct
    10-10-2016  JNK     Remamed Last=La, First=Fi, Before=Be, After=Af
*/
%macro baseDiag(IndexDate, sets, postfix=, censordate=&globalend, keepDiag=FALSE, keepPat=FALSE, keepDate=FALSE, keepBefore=TRUE, keepAfter=TRUE, keepStatus=TRUE);
%local N nsets var;
%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list only if larger than 2 */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets =  %sysfunc(countw(&newsets));
%end;

%do N=1 %to &nsets;
  %let var=%lowcase(%sysfunc(compress(%qscan(&sets,&N))))&postfix;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepBefore)=TRUE %then %do;
    &var.Be&IndexDate = (&var.FidateBe&IndexDate ne .);
	format &var.Be&IndexDate yesno.;
  %end;
  %if %upcase(&keepStatus)=TRUE and %upcase(&keepAfter)=TRUE %then %do;
    &var.fupDate&IndexDate = &var.dateAf&IndexDate;
	&var.fup&IndexDate =  (.< &var.fupDate&IndexDate < &censordate);
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
