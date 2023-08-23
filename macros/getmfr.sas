/* changed order: basedata= at the end */
%macro getMfr(outlib=work, focus=m, basedata=,info=basis, fromyear=1997);

    %let info = %sysfunc(substr(&info,1,5));
	%findingmfr(&outlib..mfr&info.all, &focus, &info, fromyear=&fromyear, basedata=&basedata);

%mend;


/*
findingmfr();
extract data from the medicinal birth register.
the macro is called outside a datastep.
*/

%macro findingmfr(outdata, focus, info=basis, fromyear=, basedata=);
	%let sqlrc=0;
	%put "extract based on population in &basedata";
        %if &info ne basis %then %do; %put "Only basis info type available"; %let info=basis; %end;
	%local i;

	/* log speed */
	%put start findingmfr: %qsysfunc(datetime(), datetime20.3);
	%let startmfrtime = %qsysfunc(datetime());
	%let lastyr=%sysfunc(today(),year4.);

	%do %while (%sysfunc(exist(raw.mfr_mfr&lastyr))=0);
		%let lastyr=%eval(&lastyr - 1);
	%end;

	proc sql inobs=&sqlmax;
		%if &sqlrc=0 %then %do;
			proc sql inobs=&sqlmax;
				%do yr=&fromyear %to &lastyr;
				%if &yr=&fromyear %then
					create table &outdata as;
				%else insert into &outdata;
					select
						%if &info=basis %then %do;
							%if &focus=m %then a.mcpr as pnr, ;
							%if &focus=c %then a.bcpr as pnr, ;
							a.*
						%end;
						%if &info ne basis %then a.mcpr, a.bcpr, a.birthday as foedselsdato,  b.kodetype as &info.kodetype, b.skskode as &info.skskode, a.rec_in as pk_rec_in, a.rec_out as pk_rec_out, b.rec_in as fk_rec_in, b.rec_out as fk_rec_out;
						from
						%if &basedata ne %then (select distinct pnr from &basedata) c inner join;
						raw.mfr&yr a
						%if &basedata ne %then %do;
				        on
							%if &focus=m %then a.mcpr=c.pnr ;
							%if &focus=c %then a.bcpr=c.pnr ;
						%end;
						%if &info ne basis %then %do;
						join

						%if &info = andre %then raw.mfr_andre_foedselskomplikat&yr;
						%if &info = cardi %then raw.mfr_cardiomyopati&yr;
						%if &info = gravi %then raw.mfr_graviditetskomplikation&yr;
						%if &info = igang %then raw.mfr_igangsaettelse&yr;
						%if &info = infek %then raw.mfr_infektioner&yr;
						%if &info = kejse %then raw.mfr_kejsersnit&yr;
						%if &info = medic %then raw.mfr_medicinske_sygdomme&yr;
						%if &info = misda %then raw.mfr_misdannelser&yr;
						%if &info = vesti %then raw.mfr_vestimulation&yr;

						b on a.pk_mfr=b.fk_mfr and a.rec_out>b.rec_in and a.rec_out<=b.rec_out;
						%end;
						;
				%end;
			%end;
	%sqlquit;

proc sort data=&outdata;
	by mcpr %if &info=basis & %varexist(&outdata,foedselsdaTo) %then foedselsdato; bcpr;
run;

data _null_;
	endmfrtime=datetime();
	timeMfrdif=endmfRtime - &startmfrtime;
	put 'execution time findingmfr ' timemfrdif:time20.6;
run;
%mend;
