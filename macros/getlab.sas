
%macro getLab(outlib, lablist, basedata=, basepop=,fromyear=2008);
%local N nsets;

%let nsets =  %sysfunc(countw(&lablist));
%if &nsets gt 2 %then %do; /* reduce list */
  %nonrep(mvar=lablist, outvar=newsets);
  %let lablist = &newsets;
  %let nsets = %sysfunc(countw(&newsets));
%end;

  %do N=1 %to &nsets;
    %let lab = %lowcase(%scan(&lablist,&N));
    %findingLab(work.LAB&lab.ALL, &lab, &&LAB&lab, basedata=&basedata, fromyear=&fromyear);
    data &outlib..LAB&lab.ALL; set work.LAB&lab.ALL;
        new = tranwrd(compress(value,"<"),",",".");
        referenceinterval_lowerlimit = tranwrd(referenceinterval_lowerlimit,",",".");
        referenceinterval_upperlimit = tranwrd(referenceinterval_upperlimit,",",".");
        valuenum = input(new,12.);
        drop new;
        unit=upcase(unit);

        rename patient_cpr_encrypted=pnr
            laboratorium_idcode=labID
            referenceinterval_lowerlimit=ref_lower
            referenceinterval_upperlimit=ref_upper;
        %runquit;
    %if &basepop ne %then %do;
	  proc sql inobs=&sqlmax;
	  %if &N=1 %then create table &outlib..&basepop as ;
	  %else insert into &outlib..&basepop;
	  select *, &lab as labinfo length=10
	  from &outlib..LAB&lab.ALL;
	  %sqlquit;
	%end;
  %end; /* end of do */

  %if &basepop ne %then %do;
    proc sort data = &outlib..&basepop; /* do not reduce before &ajour is set */
	  by pnr samplingdate labinfo rec_out;
	%runquit;
  %end;
%mend;


/*
  findingLab();
  Extract prescription data on specific LAB codes for a population.
  Output dataset can optionally be reduced to at status at a specified time,
  using ''%reducerFA''. Other reduction macros are also available.
  The macro is called outside a datastep.

*/

%macro findingLab(outdata, labinfo, labcode, basedata=,fromyear=);
  %let sqlrc=0;
  %put "extract based on population in &basedata";

  %local I lastyr;

		/* hack */
		  %let isrecthere=;
		  proc sql noprint;
		  select name into : isrecthere
			from dictionary.columns
			where upcase(libname)="RAW" and upcase(memname) like "LAB_LAB_DM%" and upcase(name)="REC_IN";
		  quit;
		  	/* slut på hack */
  /* log speed */
  %put start findingLab: %qsysfunc(datetime(), datetime20.3);
  %let startLabtime = %qsysfunc(datetime());

  %let dlstcnt = %sysfunc(countw(&labcode));
  %let lastyr=%sysfunc(year("&sysdate"d)); /* will use the date / year of the sas-session */

  %do %while (%sysfunc(exist(raw.lab_lab_dm_forsker&lastyr))=0 and &lastyr>2005);
      %let lastyr=%eval(&lastyr - 1);
      %end;

  proc sql inobs=&sqlmax;
	%if &sqlrc=0 %then %do;
	  proc sql inobs=&sqlmax;
          %do y=&fromyear %to &lastyr;
          %if &y=&fromyear %then
              create table &outdata as;
          %else insert into &outdata;
	  select
       a.*
          %if &isrecthere eq  %then , mdy(01,01,1994) as rec_in format=date.,  mdy(12,31,2099) as rec_out format=date.;
      from
      %if &basedata ne %then &basedata c inner join ;
      raw.lab_lab_dm_forsker&y as a
	  %if &basedata ne %then on a.patient_cpr_encrypted=c.pnr ;
      where
        %if &dlstcnt > 1 %then (;
      %do I=1 %to &dlstcnt;
        %let dval = %upcase(%qscan(&labcode,&I));
	    %if &i>1 %then OR ;
	    upcase(a.analysiscode) like "&dval.%"
      %end;
      %if &dlstcnt >1 %then );
	  ;
	%end;
    %end;
	%sqlquit;

   proc sort data=&outdata;
	  by patient_cpr_encrypted analysiscode samplingdate rec_in;
	run;
    data _null_;
      endLabtime=datetime();
      timeLabdif=endLabtime - &startLabtime;
      put 'execution time FindingLab ' timeLabdif:time20.6;
    run;
  %mend;


