/* SVN header
$Date:  $
$Revision:  $
$Author: $
$Id:  $
*/
%macro riskSetMatch(outdata, basedata, basedate, pop=master.population, nControls = 5,difbirthyear=0,ajour=today(),crit=,concritvar=);
    %start_timer(risksetmatch);
    %local yr fromyr toyr ds;
    %let ds = %sysfunc(round(%qsysfunc(datetime()),1));

/*
Takes data set of pnr and &casedate and finds age (whole year) and
sex-matched controls by random sampling in a control data set fx a nationwide material; i.e. for each subject
in casedata, controls are sampled among those still at risk of the event at the date of case event; of the same age; of the same sex
Outputs data set of pnr_case and pnr_control; cases are those where pnr_case=pnr_control
*/
/*
%let outdata=mydata.diabetesCase_CaseControl;
%let controldata=Master.pop_hist;
%let migrationdata=Master.vandringer_hist;
%let casedata=mydata.diabATCLPR;
%let casedate=inclusionDate;
%let nControls=5;
%let sqlmax=max;
%put &fromYr &toYr;
%let yr=2008;
%put &yr;
proc contents data = allcc; run;
data mydata.foo;
set allcc;
if byear < 1900;
run;
%let fromYr=1900;
*/
* Cases w/case date and birth year;
%if "&crit" ne "" %then %do;
    %let crit = %sysfunc(tranwrd(&crit,&basedate,a.t));
    %let concritvarx = %commas(&concritvar);
  %end;
    proc sql;
	     create table _con_&ds as
                 select distinct pnr
                 %if "&crit" ne "" %then , &concritvarx;
             from &pop
  	     /* union
	     select distinct pnr from &basedata */;
	quit;
*	hent populationsdata for case materialet;
    %MergePop(_cas_&ds,&basedata, &basedate,  ajour=&ajour);
*   dan populationsdata for control materialet;
proc sql noprint inobs=&sqlmax;
	select min(year(birthdate)), max(year(birthdate)) into :fromyr, :toyr
		from _cas_&ds;

create table _con_&ds as
	select a.*, b.sex, b.birthdate, b.deathdate from
	_con_&ds a, master.population b
	where a.pnr=b.pnr and b.rec_in<=&ajour<b.rec_out;

/* ekstra DS trin for at håndtere migration og begrænse til relevante controller */
    create table _con_&ds as
    select a.*,b.indv_dato, b.udv_dato from
      (select * from _con_&ds where &fromYr-&difbirthyear <= year(birthdate) <= &toYr+&difbirthyear) a
      left join master.vandringer(where=(rec_in<=&ajour<rec_out)) b
      on a.pnr = b.pnr
      order by a.pnr;

	quit;

/* hvis basedate er oplyst så er det også en case */
data _con_&ds;
    merge &basedata(keep=pnr &basedate) _con_&ds;
    by pnr;
run;

* All controls/cases + all relevant migration info (-> multiple rows per individual possible);
* Remember: 1=male, 2=female;
%if &fromYr<1920 %then %let fromYr=1920;
%do yr = &fromYr %to &toYr;
    proc sql inobs=&sqlmax;
  * Table of all cases and, for each case, ALL possible controls;
        create table _temp_&ds  as
            select distinct a.pnr as pnr_case,  b.pnr as pnr_control, a.sex, a.t as &basedate, (a.pnr ne b.pnr)*(uniform(&yr)+1) as ran
            %if "&crit" ne "" %then , &concritvarx;
            from
            (select pnr, sex, birthdate as casebirth, &basedate as t from _cas_&ds
            where &basedate ne . and year(birthdate) = &yr ) a /* All study cases with given birth year plus/minus difbirthyear */
            inner join
            (select * /*pnr, sex*/, birthdate as controlbirth, &basedate as t /*, udv_dato, indv_dato, birthdate, deathdate*/ from _con_&ds
               where abs(year(birthdate)- &yr)<=&difbirthyear) b  /* All cases AND controls with given birth year */
            on             /* Inner join (-> cartesian product) so that... */
            a.pnr ne b.pnr
            and ((b.t = . or (a.t-a.casebirth) < (b.t-b.controlbirth))           /* Controls are still at risk of event - or are equal to case ... */
            and a.sex = b.sex                /* ... have same sex */
            %if "&crit" ne "" %then and (&crit);
            and not ((b.udv_dato ne . and (b.udv_dato-b.controlbirth) <= (a.t-a.casebirth) < (b.indv_dato-b.controlbirth))   /* ... are NOT... out of DK */
            or ((b.deathdate ne .) and (b.deathdate-b.controlbirth) <= (a.t-a.casebirth))))  /* ... or dead,  before index date for case */
			order by a.pnr, ran;
            create table _tempcas_&ds as
			select pnr as pnr_case, pnr as pnr_control, sex, &basedate, 1 as ran  from _cas_&ds
            where &basedate ne . and year(birthdate) = &yr;
*			order by a.pnr_case, ran;
            %runquit;
            data _temp_&ds; set _temp_&ds _tempcas_&ds; run;
           /* Sort by random variables (<->randomize; note that case comes first, by construction) */
	proc sort data=_temp_&ds; by pnr_case ran; run;
  	data _temp_&ds(keep=pnr_case pnr_control   &basedate &concritvar) _tempN_&ds(keep=pnr_case nRisk);
		  set _temp_&ds;
		  nRisk+1;
		  by pnr_case;
		  if first.pnr_case then nRisk=0;
		  if nRisk<&ncontrols+1 then output _temp_&ds;
		  if last.pnr_case then output _tempN_&ds;
		  run;
		  data _temp_&ds;
		  merge _temp_&ds _tempN_&ds;
		  by pnr_case;
		  run;

  * Create or append to &outname;
  %if &yr = &fromYr %then %do;
    data &outdata;
    set _temp_&ds;
    run;
  %end;
  %else %do;
    proc append base = &outdata data = _temp_&ds;
    run;
  %end;
%end;

proc datasets nolist;
    delete _con_&ds _cas_&ds _temp_&ds _tempcas_&ds;
    %runquit;
%end_timer(risksetmatch, text=full run of risksetmatch macro);
%mend;
