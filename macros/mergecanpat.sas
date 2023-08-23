/*
  #+NAME          :  %mergeCanPat
  #+TYPE          :  SAS
  #+DESCRIPTION   :  merging correct observations from DCR and Pat to a study dataset
  #+OUTPUT        :  output dataset from %reducerFC is merged to basedata
  #+AUTHOR        :  MJE
  #+CHANGELOG     :  Date        Initials Status
                  : 18-06-20    MJE      first tests
                  :
*/

%macro mergeCanPat(basedata, inlib, outlib, IndexDate, sets, ajour=today(), postfix=);
%put start mergeCanPat: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour);
%start_timer(mergeCanPat);
%local canpatdat nsets i var;
%let canpatdat=%NewDatasetName(canpatdattmp); /* temporært datasætnavn så data i work ikke overskrives */

%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets = %sysfunc(countw(&newsets));
%end;

%do i=1 %to &nsets;
  %let var=%sysfunc(compress(%qscan(&sets, &i)));

	 proc sql;
      create table &canpatdat as
      select a.*, b.&IndexDate.
	  from &inlib..CAN&var.ALL /*(drop=
	  %if %varexist(&inlib..&var.ALL, &IndexDate)=1 %then &IndexDate; %else &IndexDate; afterbase )*/ a,
      &basedata b
	  where a.pnr=b.pnr and &ajour between rec_in and rec_out
	  order by pnr, &IndexDate, indate;
	%SqlQuit;

	%reduceCanPat(&canpatdat, &outlib..CAN&var&postfix&Indexdate, &var&postfix, &IndexDate, ajour=&ajour);
%end;

  proc sort data=&basedata;
    by pnr &IndexDate;
  run;

  data &basedata;
    merge &basedata (in=A)
    %do i=1 %to &nsets;
	  %let var=%sysfunc(compress(%qscan(&sets,&i)));
	  &outlib..CAN&var&postfix&Indexdate
    %end;
    ;
    by pnr &IndexDate;
    if A;
  %RunQuit;
  %cleanup(&canpatdat);

 %end_timer(mergeCanPat, text=Measure time for getCancer macro);
%mend;

