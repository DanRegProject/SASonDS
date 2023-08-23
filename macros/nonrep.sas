/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: nonrep.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/* check and remove reocurring events in the list */
%macro nonrep (mvar=, outvar=);
  %global numvar;
  %local I J long;
  %let numvar = %sysfunc(countw(&&&mvar));
  %put Number of Variables = &numvar;
  %global &outvar;
  %do I=1 %to &numvar;
    %let J=%eval(&I-1);
    %if %symexist(%scan(&&&mvar, &I))=0 %then
    %do;
      %let %scan(&&&mvar,&I)=1;
      %local name&i;
      %let name&I=%scan(&&&mvar,&I);
      %put Number &I: &&name&I;
      %if &I=1 %then %let long = &name1;
      %else %let long = &long &&name&I;
    %end;
  %end;
  %let &outvar=&long;
%mend;
