/*
  #+NAME          :  %mergeLab
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Repeatedly calling %reduceLabStatus for a list of labdoces and merge on
                     study dataset. Input material to %reduceLabStatus may be restricted by
                     optional parameters.
                     The macro is called outside a datastep
  #+OUTPUT        :  output dataset from %reduceLab is merged to basedata
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  : 29-09-15    JNK      ported from DS
                  :
*/

%macro mergeLab(basedata, inlib, outlib, IndexDate, sets, ajour=today(), postfix=);
%put start mergeLab: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour);

%local Labdat nsets i var;
%let Labdat=%NewDatasetName(Labdattmp); /* temporært datasætnavn så data i work ikke overskrives */

%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets = %sysfunc(countw(&newsets));
%end;

%do i=1 %to &nsets;
  %let var=%sysfunc(compress(%qscan(&sets, &i)));

  proc sql;
    create table &Labdat as
	select a.*, b.&IndexDate.
	from &inlib..LAB&var.ALL  a,
      &basedata b
	where a.pnr=b.pnr and &ajour between rec_in and rec_out
	order by pnr, &IndexDate, samplingdate;
	/* klargør til at lave en fra/til liste over lab numre */
	create table test as
	  select analysiscode, count(pnr) as N from &Labdat
	  group by analysiscode
	  order by N;
	%RunQuit;
        %let npu = ;
	data _null_;
	  set test end=end;
	  retain fnpu;
	  if _N_=1 and end then call symput("npu", substr(analysiscode,1,6));
	  else do;
	  if _N_=1 then fnpu=analysiscode;
	  if end then call symput("npu", compress(cat(substr(analysiscode,1,6), "-", substr(fnpu,1,6))));
	  end;
    %runquit;

	%prereduceLabStatus(&Labdat, &outlib..&var&postfix&IndexDate, &var&postfix, &npu, &IndexDate, ajour=&ajour);
	%end;
	  proc sort data=&basedata;
	    by pnr &IndexDate;
      run;

	  data &basedata;
	    merge &basedata (in=A)
		%do i=1 %to &nsets;
		%let var=%sysfunc(compress(%qscan(&sets,&i)));
		&outlib..&var&postfix&Indexdate
		%end;
		;
		by pnr &IndexDate;
		if A;
	%runquit;

  %cleanup(&Labdat);

%mend;

