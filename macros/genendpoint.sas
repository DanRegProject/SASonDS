/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: genEndpoint.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*//*
  #+NAME
    %genEndpoint
  #+TYPE
   SAS
  #+DESCRIPTION
    Combine endpoints information with death and sensoring information
    into standardized variables used for endpoint analyses.
  #+SYNTAX
    %genEndpoint(
      name,		      Endpoint variable name.
      endpoints,	  Existing date variables to build endpoint. Can be empty if only Death is considered.
      deadDate,	      Existing date variable with date of death.
      deadCode,	 	  String of condition indicating death eg status=90,
      studyEndDate,   Existing date variable with date of end of study or date constant eg '23dec1993'd
      combined=FALSE, Boolian. create a combined endpoint with death if TRUE. optional.
    );
  ex:
    data test;
	merge Master.pop Master.charlson;
	by pnr;
	vital=(doddato>.);
        %genEndpoint(Death,,doddato,deadcode=vital=1,studyenddate='01jan2000'd);
        %genEndpoint(s12,S1date S2date,doddato,deadcode=vital=1,studyenddate='01jan2000'd);
        %genEndpoint(s12d,S1date S2date,doddato,deadcode=vital=1,studyenddate='01jan2000'd,combined=TRUE);
        keep pnr s1date s2date s12EndDate s12Status s12dEndDate s12dStatus DeathEndDate DeathStatus ;
    run;
  #+OUTPUT
    Generates new variables:
	  &name.EndDate
	  &name.Status
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date		Initials	Status
    09-01-2014	FLS		Bug corrected, if deaddate was
				specified in endpoints then deadCode
				was not accounted for correctly.
*/
%macro genEndpoint(name, endpoints, deadDate, deadCode, studyEndDate, combined=FALSE);
  &name.EndDate = min(%if &endpoints ne %then %commas(&endpoints),;&deadDate, &studyEndDate);
  format &name.EndDate date.;
  label  &name.EndDate="Date of the end of period at risk for endpoint &name";
  &name.Status=0;
  %if &endpoints = OR %upcase(&endpoints)=%upcase(&deadDate) OR &combined= TRUE %then if %NRBQUOTE(&deadcode) AND &deadDate=&name.EndDate then &name.Status=1;;
  %if &endpoints ne %then %do;
    %let elstcnt = %sysfunc(countw(&endpoints));
	%do I=1 %to &elstcnt;
  	  %let eval = %sysfunc(compress(%qscan(&endpoints, &i)));
	  if &eval=&name.EndDate then &name.Status=1;
	%end;
  %end;
  label &name.Status="Status of endpoint &name";
%mend;
