


libname fmt '\\srvfsenas3\formater\SAS formater i Danmarks Statistik\FORMATKATALOG' access=readonly;
options fmtsearch=(fmt.times_personstatistik fmt.times_erhvervsstatistik fmt.times_bbr
                   fmt.statistikbank fmt.brancher fmt.uddannelser fmt.disced fmt.disco fmt.sundhed fmt.geokoder);

%macro mergeSocio(basedata,inlib,outlib,index,sets,ajour=today(),handlemissing=);
%local nsets i var;
%let nsets=%sysfunc(countw(&sets));
  %if &nsets gt 2 %then %do; /* reduce list */
    %nonrep(mvar=sets, outvar=newsets);
    %let sets = &newsets;
    %let nsets = %sysfunc(countw(&newsets));
  %end;

%do i=1 %to &nsets;
	%let var = %sysfunc(compress(%qscan(&sets,&i)));
	proc sql;
		create table &outlib..SOC&var.&index as
			select A.pnr,
					A.&index,
					%if &var eq udd %then B.&var as &var.LaBe&index, B.&var.kilde,;
					%if &var eq famindkom %then B.&var as &var.LaBe&index,;
					%if &var eq socialst %then B.&var.02 as &var.02LaBe&index, B.&var.13 as &var.13LaBe&index,;
					%if &var eq civilst %then B.&var as &var.LaBe&index, B.&var.date as &var.LaDateBe&index,;
					B.rec_in,
					B.rec_out,
					B.datavaliduntil %if &var ne famindkom %then,;
					%if &var eq udd %then put(&var.LaBe&index,AUDD_NIVEAU_L1L2_KT.) as &var.LaBeLab&index;
					%if &var eq socialst %then put(&var.02LaBe&index,SOCIO02_KT.) as &var.02LaBeLab&index,  put(&var.13LaBe&index, SOCIO13_KT.) as &var.13LaBeLab&index;
					%if &var eq civilst %then put(&var.LaBe&index,$CIVST_KT.) as &var.LaBeLab&index;
			from &basedata as A
			left join &inlib..SOC&var.all as B
			on A.pnr = b.pnr and year(A.&index) = B.year+1
			where &ajour between B.rec_in and B.rec_out;
		quit;
	run;

	proc sort data=&outlib..SOC&var.&index out =&outlib..SOC&var.&index ;
	by pnr &index;
	run;

	proc sort data=&basedata out=&basedata;
	by pnr &index;
	run;

	data &basedata;
	merge &basedata &outlib..SOC&var.&index;
	by pnr &index;
	run;

%end;
%mend;

