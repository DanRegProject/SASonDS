/* basedata    = input basedataset with at least pnr and dDate
   outlib      = output library where charlson table is placed
   MCSDate   = dDate, target date for each patient.
   PeriodStart = if not set, period will be from birth to MCSDate. Else period is from PeriodStart-MCSDate
   ajour       = ajour
   output: charlson table placed in outlib.
*/
/*add to this list if providing new scores - is used in create_datalist (move to common.sas) */

%macro multicoscore (score, basedata, outlib, MCSDate, PeriodStart=, ajour=today(), mergebase=TRUE);
  /* merge the two tables - maybe some of the variables from &basedata= is used when calculating &score, e.g. date=dDate or indate=dDate-356 */;
  %local I stop sets score basedata outlib MCSDate PeriodStart ajour mergebase;
  %let sets=;
  proc sql;
/* Check if data are available for the score */
  /* Diagnoses */
  %if %sysfunc(exist(mcolib.LPR&score)) %then %do;
    create table work._LPRtmp_&score as
    select a.pnr, a.&MCSDate, %if &PeriodStart ne %then a.&PeriodStart,; b.outcome, b.label, b.indate as &score.date, b.weight, b.wdays
    from &basedata a
    join mcolib.LPR&score b on a.pnr=b.pnr
    where &ajour between b.rec_in and b.rec_out and b.indate<=a.&MCSDate
        order by a.pnr, a.&MCSDate, b.outcome, b.indate;
    %let sets = &sets work._LPRtmp_&score;
    %end;

/* Prescriptions */
  %if %sysfunc(exist(mcolib.LMDB&score)) %then %do;
    create table work._LMDBtmp_&score as
    select a.pnr, a.&MCSDate, %if &PeriodStart ne %then a.&PeriodStart,; b.outcome, b.label, b.eksd as &score.date, b.weight, b.wdays
    from &basedata a
    join mcolib.LMDB&score b on a.pnr=b.pnr
    where &ajour between b.rec_in and b.rec_out and b.eksd<=a.&MCSDate
        order by a.pnr, a.&MCSDate, b.outcome, b.eksd;
    %let sets = &sets work._LMDBtmp_&score;
    %end;
%sqlquit;
/* are other data needed ? This part is individual to each OTH component */
   %let I=1;
   %if %symexist(OTHL&score.&I) %then %do;
        data work._OTHtmp_&score;
            set &basedata;
            keep pnr &MCSDate %if &PeriodStart ne %then &PeriodStart;;
            %runquit;
        /* Loop through OTHER definitions to establish necesary data */
            %do %while(%symexist(OTHL&score.&I));
/* charlson needed in Segal, start */
                %if %index(%upcase(&&OTHL&score.&I),CHARLSON)>0  %then
                    %multicoscore(charlson, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);;
/* charlson needed in Segal, end */
/* Admission needed in Segal, start */
                %if %index(%upcase(&&OTHL&score.&I),ADMISSION)>0  %then %do;
                    %getHosp (work._tmphosp_,basedata=work._OTHtmp_&score);
                    proc sql;
                        create table work._OTHtmp2_ as
                            select a.*, b.indate
                            from work._OTHtmp_&score a left join work._tmphosp_ b
                            on a.pnr=b.pnr and b.indate<=a.&MCSDate
                            where &ajour between b.rec_in and b.rec_out
                            order a.pnr, a.&MCSDate, b.indate;
                    quit;
                    data work._OTHtmp_&score;
                        set work._OTHtmp2_;
                        by pnr &MCSDate;
                        if last.&MCSDate;
                        %runquit;
                %end;
/* Admission needed in Segal, end */
/* Heart failure needed in CHA2DS2VASc, start */
                %if %index(%upcase(&&OTHL&score.&I),HEART FAILURE)>0 %then %do;
                    %multicoscore(HeartFailDiag, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                    %multicoscore(HeartFailMedi, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                %end;
/* Heart failure needed in CHA2DS2VASc, end */
/* Hypertension needed in CHA2DS2VASc, start */
                %if %index(%upcase(&&OTHL&score.&I),HYPERTENSION)>0 %then %do;
                    %multicoscore(HypertensionDiag, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                    %multicoscore(HypertensionMedi, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                    %multicoscore(CombHypertensionMedi, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                %end;
/* Hypertension needed in CHA2DS2VASc, end */
/* Diabetes needed in CHA2DS2VASc, start */
                %if %index(%upcase(&&OTHL&score.&I),DIABETES)>0 %then %do;
                    %multicoscore(DiabetesDiag, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                    %multicoscore(DiabetesMedi, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);
                %end;
/* Diabetes needed in CHA2DS2VASc, end */
                %let I=%eval(&I+1);
           %end; /* end loop */
        data work._OTHtmp_&score;
            set work._OTHtmp_&score;
            length outcome $20. label $50.;
            %let I=1;
            %do %while(%symexist(OTHL&score.&I));
                outcome=upcase("OTHL&score.&I");
                label=&&OTHL&score.&I;
                crit=&&OTH&score&I.C;
                weight=&&OTH&score&I.W;
                wdays=.;
                %if %symexist(OTH&score.&I.D) %then wdays = &&OTH&score.&I.D;
                output;
                %let I=%eval(&I+1);
            %end;
            keep pnr &MCSDate outcome label crit weight wdays;
       %runquit;
       %let sets = &sets work._OTHtmp_&score;
       %end;
   %let I=1;
   %if %symexist(CPRL&score.&I) %then %do;
       %if %sysfunc(exist(master.population)) and %sysmacexist(getPOP)=0 %then %do;
           %MergePop(work._CPRtmp_&score,&basedata, &MCSDate,  ajour=&ajour);
            data work._CPRtmp_&score;
                set work._CPRtmp_&score;
                keep pnr sex birthdate;
                %runquit;
       %end;
       %else %do;
           %getPOP(work._CPRtmp_&score,&basedata);
            data work._CPRtmp_&score;
                set work._CPRtmp_&score;
                where &ajour between rec_in and rec_out;
                keep pnr sex birthdate;
                %runquit;
       %end;
       proc sort data=work._CPRtmp_&score noduplicates;
           by pnr;
       data work._CPRtmp_&score;
            merge work._CPRtmp_&score &basedata(keep=pnr &MCSDate);
            by pnr;
            length outcome $20. label $50.;
            %do %while(%symexist(CPRL&score.&I));
			    *&score.&MCSDate=&MCSDate;
                outcome=upcase("CPRL&score.&I");
                label=&&CPRL&score.&I;
                crit=&&CPR&score&I.C;
                weight=&&CPR&score&I.W;
                wdays=.;
                %if %symexist(CPR&score.&I.D) %then wdays = &&CPR&score.&I.D;
                output;
                %let I=%eval(&I+1);
           %end;
           keep pnr &MCSDate /*&score.&MCSDate*/ outcome label crit weight wdays;
        %runquit;
        %let sets = &sets work._CPRtmp_&score;
   %end;
%let stop=FALSE;
%if %symexist(CPR&score.1) and  %sysfunc(exist(work._CPRtmp_&score))=0 %then %let stop=TRUE;
%if %symexist(LPR&score.1) and  %sysfunc(exist(work._LPRtmp_&score))=0 %then %let stop=TRUE;
%if %symexist(OTH&score.1) and  %sysfunc(exist(work._OTHtmp_&score))=0 %then %let stop=TRUE;
%if %symexist(ATC&score.1) and  %sysfunc(exist(work._LMDBtmp_&score))=0 %then %let stop=TRUE;

%if &stop=FALSE %then %do;
    data work.&score&MCSDate;
        set &sets;
    %runquit;
    proc sort data=work.&score&MCSDate;
                by pnr &MCSDate outcome;
    %runquit;
        data work.&score&MCSDate;
            set work.&score&MCSDate;
        by pnr &MCSDate;

        length scoreentry $20.;
        format &score&MCSDate 8.2;
   *     retain scoreentry; /* only count one time for each diag-group */;
        retain &score&MCSDate; /* index summary */;

        if first.&MCSDate then do;
            &score&MCSDate=0;
   *         scoreentry = ''; /* make sure scoreentry is not truncated when comparing to outcome */;
            end;
          %if "&PeriodStart" ne "" %then if &score.date<&periodStart and &score.date>. then delete; /* general days criteria set in call */
*		  if &score.indate>&MCSDate then delete;
        if wdays ne . and (&MCSDate-&score.date)>wdays then delete; /* specific days criteria set in definition ...D */
        if crit=. then crit=1;
        if first.&MCSDate=0 and outcome=lag(outcome) then crit=0;
*        if scoreentry ^= outcome then do;
            scoreentry = outcome;
          %if "&PeriodStart"="" %then %do;
          /* count &score index from birth until &MCSDate */;
              &score.Date&MCSDate=&score.date;
              format &score.Date&MCSDate date.;
              &score&MCSDate = &score&MCSDate+weight*crit;
              label &score&MCSDate = "&SCORE index at &MCSDate";
              keep pnr &score&MCSDate &score.Date&MCSDate &MCSDate scoreentry label  weight crit &score.date;
              retain &score.Date&MCSDate;
              %end;
          %else %do;
          /* count &score index in the period from &periodStart to &MCSDate */;
              &score.DateStart&MCSDate=&PeriodStart;
              &score.DateEnd&MCSDate = &score.date;
              format  &score.DateStart&MCSDate &score.DateEnd&MCSDate date.;
              &score&MCSDate = &score&MCSDate+weight*crit;
              label &score&MCSDate = "&SCORE index measured between &PeriodStart and &MCSDate";
              keep pnr &score&MCSDate &score.DateStart&MCSDate &score.DateEnd&MCSDate &MCSDate scoreentry label weight crit &score.date;
              retain &score.DateStart&MCSDate &score.DateEnd&MCSDate;
              %end;
*          end;
          %runquit;

        proc transpose data=work.&score&MCSDate out=&outlib..&score&MCSDate.Indi(drop=_NAME_);
            by pnr &MCSDate;
            where crit>0;
            var crit;
            id scoreentry;
            idlabel label;
        run;

    data &outlib..&score&MCSDate;
        set work.&score&MCSDate;
        by pnr &MCSDate;
        if last.&MCSDate;
        keep pnr &MCSDate &score&MCSDate /*%if &PeriodStart= %then &score.Date&MCSDate; %else &score.DateStart&MCSDate &score.DateEnd&MCSDate;*/;
        %runquit;

        data &outlib..&score&MCSDate;
	    merge &basedata (in=a keep=pnr &MCSDate) &outlib..&score&MCSDate (in=b);
		by pnr &MCSDate;
		%if %symexist(OTH&score.1)=0 and %symexist(CPR&score.1)=0 %then if a and not b then &score&MCSDate = 0; /* fill out with zeroes if pnr not in mcolib.&score if only rely on LPR */;
                %if %symexist(LINK&score) %then &score&MCSDate = &&LINK&score;;

                if a;
	  %runquit;
%if %UPCASE(&mergebase)=TRUE %then %do;
	data &basedata;
	    merge &basedata (in=a) &outlib..&score&MCSDate (in=b) &outlib..&score&MCSDate.Indi(in=c);
		by pnr &MCSDate;
		if a; 
	  %runquit;
	  %end;
        %end;
    %else %put &score tables not found or mcolib not available;
    %mend;




