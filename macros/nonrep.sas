
/* check and remove reoccurring events in the list */
%macro nonrep(mvar=, outvar=);
%global numvar;
%local I J long;
%let numvar =  %sysfunc(countw(&&&mvar));
%put Number of Variables = &numvar;
%global &outvar;
%do i=1 %to &numvar;
  %let j=%eval(&i-1);
  %if %symexist(%scan(&&&mvar, &i))=0 %then
  %do;
    %let %scan(&&&mvar,&i)=1;
    %local name&i;
    %let name&i=%scan(&&&mvar,&i);
    %put Number &i : &&name&i;
    %if &i=1 %then %let long = &name1;
    %else %let long = &long &&name&i;
  %end;
%end;
%let &outvar=&long;
%mend;


