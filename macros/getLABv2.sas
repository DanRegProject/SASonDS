%macro getLab(outlib, lablist, indata=, outdata=, fromyear=2008);
%local N nsets lab;

%let nsets=%sysfunc(countw(&lablist));

%if &nsets gt 2 %then %do;
	%nonrep(mvar=lablist, outvar=newsets);
	%let lablist = &newsets;
	%let nsets = %sysfunc(countw(&newsets));
%end;

%do N=1 %to &nsets;
	%let lab=%lowcase(%scan(&lablist,&N));
	%findinglab(work.LAB&lab.all, &lab, &&LAB&lab, indata=&indata, fromyear=&fromyear);

	data &outlib..LAB&lab.ALL;

		set work.LAB&lab.ALL;
		new=tranwrd(compress(value,"<"),",",".");
		new=tranwrd(compress(new,">"),",",".");

		valuenum=input(new,12.);
		drop new;
		referenceinterval_lowerlimit=tranwrd(referenceinterval_lowerlimit,",",".");
		referenceinterval_upperlimit=tranwrd(referenceinterval_upperlimit,",",".");
		unit=upcase(unit);

		rename
			laboratorium_idcode=labID
			referenceinterval_lowerlimit=ref_lower
			referenceinterval_upperlimit=ref_upper;
	%runquit;
	%if &outdata ne %then %do;
		proc sql inobs=&sqlmax;
		%if &N=1 %then create table &outlib..&outdata as;
		%else  insert into &outlib..&outdata;
			select pnr, samplingdate, labinfo, value, valuenum, unit
			from &outlib..LAB&lab.ALL;
		%sqlquit;
	%end;
%end;

%if &outdata ne %then %do;
	proc sort data=&outlib..&outdata;
		by pnr samplingdate labinfo ;
	%runquit;
%end;
%mend;

%macro findinglab(outdata, labinfo, labcode, indata=, fromyear=);
%local sqlrc I dval dlstcnt ;
%let sqlrc=0;

%let dlstcnt=%sysfunc(countw(&labcode));

%put start findingLab: %qsysfunc(datetime(),datetime20.3);
/*
%let lastyr=%sysfunc(exist(raw.lab_dm_forsker&lastyr))=0 and &lastyr>2005);
*/
proc sql inobs=&sqlmax;
	create table &outdata as
	select a.*, "&labinfo" as labinfo length=10
	from
	%if &indata ne %then &indata c inner join;
    MASTER.lab_dm_forsker a
	%if &indata ne %then on a.pnr=c.pnr;
	where
	%if &dlstcnt>1 %then (;
	%do I=1 %to &dlstcnt;
		%let dval=%upcase(%qscan(&labcode,&I));
	 	%if &i>1 %then OR;
 		upcase(a.analysiscode) like "&dval.%"
 	%end;
 	%if &dlstcnt>1 %then );
    and year(a.samplingdate)>=&fromyear;
 %sqlquit;

 proc sort data=&outdata;
 	by pnr analysiscode samplingdate ;
 %runquit;

%mend;
