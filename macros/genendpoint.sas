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
