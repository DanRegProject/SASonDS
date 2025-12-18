%macro getCAR(outlib, diaglist, indata=, outdata=, fromyear=);
%local N nsets car;
%if %sysfunc(exist(master.tumor_aarlig))=0 %then %do;
			%put getCAR WARNING: master.tumor_aarlig data not available.;
			%let returncode0=1;
		%end;
%else %do;
	%let nsets=%sysfunc(countw(&diaglist));

	%if &nsets gt 2 %then %do;
		%nonrep(mvar=diaglist, outvar=newsets);
		%let diaglist = &newsets;
		%let nsets = %sysfunc(countw(&newsets));
	%end;

	%do N=1 %to &nsets;
		%let car=%lowcase(%scan(&diaglist,&N));
		%findingcar(&outlib..car&car.all, &car, &&car&car, indata=&indata, fromyear=&fromyear);

		%if &outdata ne %then %do;
			proc sql inobs=&sqlmax;
			%if &N=1 %then create table &outlib..&outdata as;
			%else  insert into &outlib..&outdata;
				select pnr, carinfo, diagnosedato, diagnose_kode_icd10
				from &outlib..car&car.ALL;
			%sqlquit;
		%end;
	%end;

	%if &outdata ne %then %do;
		proc sort data=&outlib..&outdata;
			by pnr carinfo diagnosedato diagnose_kode_icd10 ;
		%runquit;
	%end;
%end;
%mend;

%macro findingcar(outdata, carinfo, carcode, indata=, fromyear=);
%local sqlrc I dval dlstcnt ;
%let sqlrc=0;

%let dlstcnt=%sysfunc(countw(&carcode));

%put start findingcar: %qsysfunc(datetime(),datetime20.3);
/*
%let lastyr=%sysfunc(exist(raw.car_dm_forsker&lastyr))=0 and &lastyr>2005);
*/
proc sql inobs=&sqlmax;
	create table &outdata as
	select a.*, "&carinfo" as carinfo length=10
	from
	%if &indata ne %then &indata c inner join;
    MASTER.tumor_aarlig a
	%if &indata ne %then on a.pnr=c.pnr;
	where
	%if &dlstcnt>1 %then (;
	%do I=1 %to &dlstcnt;
		%let dval=%upcase(%qscan(&carcode,&I));
	 	%if &i>1 %then OR;
 		upcase(a.diagnose_kode_icd10) like "&dval.%"
 	%end;
 	%if &dlstcnt>1 %then );
    %if &fromyear ne %then and year(a.diagnosedato)>=&fromyear;;
 %sqlquit;

 proc sort data=&outdata;
 	by pnr diagnose_kode_icd10 diagnosedato ;
 %runquit;

%mend;
