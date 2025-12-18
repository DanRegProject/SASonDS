%macro getPATO(outlib, diaglist, indata=, outdata=, fromyear=);
%local N nsets PATO;
%if %sysfunc(exist(master.tumor_aarlig))=0 %then %do;
			%put getPATO WARNING: master.tumor_aarlig data not available.;
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
		%let PATO=%lowcase(%scan(&diaglist,&N));
		%findingPATO(&outlib..PATO&PATO.all, &PATO, &&PATO&PATO, indata=&indata, fromyear=&fromyear);

		%if &outdata ne %then %do;
			proc sql inobs=&sqlmax;
			%if &N=1 %then create table &outlib..&outdata as;
			%else  insert into &outlib..&outdata;
				select pnr, PATOinfo, dato_rekvirering, diagnose_snomed_kode
				from &outlib..PATO&PATO.ALL;
			%sqlquit;
		%end;
	%end;

	%if &outdata ne %then %do;
		proc sort data=&outlib..&outdata;
			by pnr PATOinfo dato_rekvirering diagnose_snomed_kode ;
		%runquit;
	%end;
%end;
%mend;

%macro findingPATO(outdata, PATOinfo, PATOcode, indata=, fromyear=);
%local sqlrc I dval dlstcnt ;
%let sqlrc=0;

%let dlstcnt=%sysfunc(countw(&PATOcode));

%put start findingPATO: %qsysfunc(datetime(),datetime20.3);
/*
%let lastyr=%sysfunc(exist(raw.PATO_dm_forsker&lastyr))=0 and &lastyr>2005);
*/
proc sql inobs=&sqlmax;
	create table &outdata as
	select  a.*,
			b.diagnose_snomed_kode,
			b.diagnose_snomed_sekvensnummer,
			b.instans_undersoegende,
			b.materialenummer,
			d.anden_specialprocedure,
			d.hasteprocedure,
			d.materiale_antal,
			d.materialetype,
			d.specielle_analyser,
			"&PATOinfo" as PATOinfo length=10
	from
	%if &indata ne %then &indata c inner join;
    master.fctrekvisition a
	%if &indata ne %then on a.pnr=c.pnr;
	left join
	MASTER.dimpatologiskdiagnose b
	on a.dw_ek_rekvisition=b.dw_ek_rekvisition
	left join
	MASTER.fctpatologiskprocedure d
	on a.dw_ek_rekvisition=d.dw_ek_rekvisition
	where
	%if &dlstcnt>1 %then (;
	%do I=1 %to &dlstcnt;
		%let dval=%upcase(%qscan(&PATOcode,&I));
	 	%if &i>1 %then OR;
 		upcase(b.diagnose_snomed_kode) like "&dval.%"
 	%end;
 	%if &dlstcnt>1 %then );
    %if &fromyear ne %then and year(a.dato_rekvirering)>=&fromyear;;
 %sqlquit;

 proc sort data=&outdata;
 	by pnr  dato_rekvirering diagnose_snomed_kode;
 %runquit;

%mend;
