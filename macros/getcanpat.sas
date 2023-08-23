

%macro getCanPat(outlib, cancerlist, basedata, type, if);
  %local N nsets code morfo;

  %start_timer(getCancer); /* measure time for this macro */

  libname sqldata odbc datasrc=Forskerdatabase schema=FSEID00004674 READBUFF=32767; /* connect to the sqldatabase where the data is placed */

  %let nsets = %sysfunc(countw(&cancerlist));

  %if &nsets > 1 %then %do;
      %nonrep(mvar=cancerlist, outvar=newcancerlist);
      %let nsets = %sysfunc(countw(&newcancerlist));
      %let cancerlist = &newcancerlist;
  %end;

  %do N=1 %to &nsets;
      %let code = %lowcase(%scan(&cancerlist,&N));
	  %if %lowcase(&type) eq "cancer" %then %do;
      %findingCancer(outdata=work.&code.ALL, outcome=&code, basedata=&basedata,if=&if);
	  %findCancerStage(outdata=&outlib..CAN&code.ALL, outcome=&code);
	  proc sort data=&outlib..CAN&code.ALL;
	  by pnr indate;
	  run;

      %end;
	  %if %lowcase(&type) eq "PAT" %then %do;
	  %findingPat(outdata=&code.ALL, outcome=&code, basedata=&basedata,if=&if);
	  %end;
  %end;

  %end_timer(getCancer, text=Measure time for getCancer macro);
%mend;


%macro findingCancer(outdata, outcome, basedata, if);
%put &&DCR&outcome;
%let ncode = %sysfunc(countw(&&DCR&outcome));
proc sql;
	create table &outdata as
	select
		a.K_CPRNR_ENCRYPTED as pnr,
		a.D_DIAGNOSEDATO as indate,
		a.C_ICD10 as diag,
		a.C_TNM_M,
		a.C_TNM_N,
		a.C_TNM_T,
		a.c_udbred,
		a.c_morfo3 as morfo
	from
	%if &basedata ne %then &basedata b inner join ;
	sqldata.CAR_T_TUMOR as a
	%if &basedata ne %then on a.K_CPRNR_ENCRYPTED = b.pnr ;
	where
	%if &ncode > 1 %then (;
		%do I = 1 %to &ncode;
			%let icode = %upcase(%qscan(&&DCR&outcome,&I));
			%if &i>1 %then OR ;
		    upcase(diag) like "&icode.%"
		%end;
	%if &ncode >1 %then );
;
%runquit;
%mend;


%macro findCancerStage(outdata, outcome);

data &outdata (drop = C_TNM_M C_TNM_N C_TNM_T c_udbred);
set work.&code.ALL;

	stage_udbred =9;
		if c_udbred in: ('0','1','2','5') then stage_udbred = 1;
		if c_udbred in: ('3','6') then stage_udbred = 2;
		if c_udbred in: ('4','7') then stage_udbred = 3;
		if c_udbred in: ('A','B','9') then stage_udbred = 9;

	stage_tnm = 9;

	if ((C_TNM_N = "AZCD30") and (C_TNM_M = "AZCD40")) /*N0 og M0*/
	   then stage_tnm = 1;

	if ((C_TNM_N = "AZCD31" OR C_TNM_N = "AZCD32" OR C_TNM_N = "AZCD33") and (C_TNM_M = "AZCD40")) /*positiv N med M0 */
		then stage_tnm =2;

	if  ( C_TNM_M = "AZCD41") /*positiv M uanset hvad der ellers er kodet*/
	   then stage_tnm = 3;

	/*Fælles stage variabel*/
	if year(indate) <2004 then stage = stage_udbred;
	if 2004 <= year(indate) then stage = stage_tnm;

rec_in = mdy(1,1,1960);
format rec_in date.;
rec_out = mdy(1,1,2099);
format rec_out date.;

format stage_udbred cancerstage.;
format stage_tnm cancerstage.;
format stage cancerstage.;

outcome = "&outcome";
run;

%mend;
/*
%macro findingPat(outdata, outcome, basedata,if);

%mend;
*/
