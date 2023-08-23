%macro riskSetMatch(outdata, controldata, migrationdata, casedata, casedate, nControls = 5);
    %start_timer(risksetmatch); /* and use the timestamp for unique dataset names */
    %local yr;
    %let dsname = %sysfunc(round(%qsysfunc(datetime()),1));
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
data ds1_&dsname;
    merge &casedata(keep=pnr &casedate) &controldata(where=(rec_in<=today()<rec_out) in=a);
    by pnr;
    byear = year(birthdate);
    if a;
run;
* All controls/cases + all relevant migration info (-> multiple rows per individual possible);
* Remember: 1=male, 2=female;
proc sql noprint inobs=&sqlmax;
    select min(byear), max(byear) into :fromyr, :toyr
      from ds1_&dsname where &casedate ne .;
    create table allcc_&dsname as
    select a.*,b.indv_dato, b.udv_dato from
      (select * from ds1_&dsname where &fromYr <= byear <= &toYr) a
      left join &migrationdata(where=(rec_in<=today()<rec_out)) b
      on a.pnr = b.pnr
      order by a.pnr;
quit;
%if &fromYr<1920 %then %let fromYr=1920;
%do yr = &fromYr %to &toYr;
    proc sql inobs=&sqlmax;
  * Table of all cases and, for each case, ALL possible controls;
        create table ds1_&dsname  as
            select distinct a.pnr as pnr_case, a.t as &casedate, b.pnr as pnr_control, b.birthdate, b.sex
            from
            (select pnr, sex, &casedate as t from allcc_&dsname
            where &casedate ne . and byear = &yr) a /* All study cases with given birth year */
            inner join
            (select pnr, sex, &casedate as t, udv_dato, indv_dato, birthdate, deathdate from allcc_&dsname where byear = &yr) b  /* All cases AND controls with given birth year */
            on             /* Inner join (-> cartesian product) so that... */
            a.pnr=b.pnr
            or ((b.t = . or a.t < b.t)           /* Controls are still at risk of event - or are equal to case ... */
            and a.sex = b.sex                /* ... have same sex */
            and not (b.udv_dato <= a.t < b.indv_dato   /* ... are NOT... out of DK */
            or ((b.deathdate ne .) and b.deathdate <= a.t)));  /* ... or dead,  before index date for case */
            create table _tempdistinct_  as
            select *, (pnr_case ne pnr_control) * (uniform(&yr) + 1) as ran /* add column of IID random variables > 1; set case value to 0 */
            from ds1_&dsname;
 /* Sort by random variables (<->randomize; note that case comes first, by construction) */
            create table ds2_&dsname as
                select a.*, b.nRisk
                from _tempdistinct_ a, (select pnr_case, &casedate, count(pnr_control) as nRisk
                from ds1_&dsname
                group by pnr_case, &casedate) b
                where a.pnr_case = b.pnr_case and a.&casedate = b.&casedate
                order by pnr_case, &casedate, ran;
    quit;
  * Pull out first 'nControls+1'  rows for each pnr_case - first row is the case, next 'nControls' rows are the controls;
  data match_&dsname(keep = pnr_case pnr_control birthdate sex &casedate nRisk);
      set ds2_&dsname;
      by pnr_case &casedate;
      retain m;
      m + 1;
      if first.&casedate then m = 1;
      if m <= &nControls + 1;
  run;
  * Create or append to &outname;
  %if &yr = &fromYr %then %do;
    data &outdata;
    set match_&dsname;
    run;
  %end;
  %else %do;
    proc append base = &outdata data = match_&dsname;
    run;
  %end;
%end;
proc datasets nolist;
    delete ds1_&dsname ds2_&dsname match_&dsname allcc_&dsname;
%runquit;
%end_timer(risksetmatch, text=full run of risksetmatch macro);
%mend;

