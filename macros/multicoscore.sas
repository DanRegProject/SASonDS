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
  %local I stop;
  proc sql;
/* Check if data are available for the score */
  %if %sysfunc(exist(mcolib.LPR&score)) %then %do;
    create table work._LPRtmp_&score as
    select a.pnr, a.&MCSDate, %if &PeriodStart ne %then a.&PeriodStart,; b.outcome, b.label, b.indate as &score.indate, b.weight
    from &basedata a
    join mcolib.LPR&score b on a.pnr=b.pnr
    where &ajour between b.rec_in and b.rec_out and b.indate<=a.&MCSDate
    order by a.pnr, a.&MCSDate, b.outcome, b.indate;
    %end;
   %sqlquit;
/* are other data needed ?*/
   %if %symexist(OTH&score.N) %then %do;
        data work._OTHtmp_&score;
            set &basedata;
            keep pnr &MCSDate %if &PeriodStart ne %then &PeriodStart;;
            %runquit;
        /* Loop through OTHER defitions to establish necesary data */
            %do I = 1 %to &&OTH&score.N;
/* charlson needed in Segal */
                %if %index(%upcase(&&OTHL&score.&I),CHARLSON)>0  %then
                    %multicoscore(charlson, work._OTHtmp_&score, work, &MCSDate, PeriodStart=&PeriodStart, ajour=&ajour,mergebase=TRUE);;
/* admission needed in Segal */
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
           %end; /* end loop */
        data work._OTHtmp_&score;
            set work._OTHtmp_&score;
            length outcome $20. label $50.;
            %do I = 1 %to &&OTH&score.N;
                outcome=upcase("OTH&score.&I");
                label=&&OTHL&score.&I;
               crit=&&OTH&score&I.C;
               weight=&&OTH&score&I.W;
               output;
           %end;
       keep pnr &MCSDate outcome label crit weight;
       %runquit;
   %end;
   %if %symexist(CPR&score.N) %then %do;
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
            %do I = 1 %to &&CPR&score.N;
                outcome=upcase("CPR&score.&I");
                label=&&CPRL&score.&I;
               crit=&&CPR&score&I.C;
               weight=&&CPR&score&I.W;
               output;
           %end;
              keep pnr &MCSDate outcome label crit weight;
       %runquit;
   %end;
%let stop=FALSE;
%if %symexist(CPR&score.N) and  %sysfunc(exist(work._CPRtmp_&score))=0 %then %let stop=TRUE;
%if %symexist(LPR&score.N) and  %sysfunc(exist(work._LPRtmp_&score))=0 %then %let stop=TRUE;
%if %symexist(OTH&score.N) and  %sysfunc(exist(work._OTHtmp_&score))=0 %then %let stop=TRUE;

%if &stop=FALSE %then %do;
    data work.&score&MCSDate;
        set
            %if %symexist(CPR&score.N) %then work._CPRtmp_&score;
            %if %symexist(OTH&score.N) %then work._OTHtmp_&score;
            %if %symexist(LPR&score.N) %then work._LPRtmp_&score;;
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
          %if "&PeriodStart" != "" %then if &score.indate<&periodStart and &score.indate>. then delete;
*		  if &score.indate>&MCSDate then delete;

        if crit=. then crit=1;
        if first.&MCSDate=0 and outcome=lag(outcome) then crit=0;
*        if scoreentry ^= outcome then do;
            scoreentry = outcome;
          %if "&PeriodStart"="" %then %do;
          /* count &score index from birth until &MCSDate */;
              &score.Date&MCSDate=&MCSDate;
              format &score.Date&MCSDate date.;
              &score&MCSDate = &score&MCSDate+weight*crit;
              label &score&MCSDate = "&SCORE index at &MCSDate";
              keep pnr &score&MCSDate &score.Date&MCSDate &MCSDate scoreentry label  weight crit &score.indate;
              retain &score.Date&MCSDate;
              %end;
          %else %do;
          /* count &score index in the period from &periodStart to &MCSDate */;
              &score.DateStart&MCSDate=&PeriodStart;
              &score.DateEnd&MCSDate = &MCSDate;
              format  &score.DateStart&MCSDate &score.DateEnd&MCSDate date.;
              &score&MCSDate = &score&MCSDate+weight*crit;
              label &score&MCSDate = "&SCORE index measured between &PeriodStart and &MCSDate";
              keep pnr &score&MCSDate &score.DateStart&MCSDate &score.DateEnd&MCSDate &MCSDate scoreentry label weight crit &score.indate;
              retain &score.DateStart&MCSDate &score.DateEnd&MCSDate;
              %end;
*          end;
      %runquit;

    data &outlib..&score&MCSDate;
        set work.&score&MCSDate;
        by pnr &MCSDate;
      if last.&MCSDate;
      keep pnr &MCSDate &score&MCSDate %if &PeriodStart= %then &score.Date&MCSDate; %else &score.DateStart&MCSDate &score.DateEnd&MCSDate;;
      %runquit;

	  data &outlib..&score&MCSDate;
	    merge &basedata (in=a keep=pnr &MCSDate) &outlib..&score&MCSDate (in=b);
		by pnr &MCSDate;
		%if %symexist(OTH&score.N)=0 and %symexist(CPR&score.N)=0 %then if a and not b then &score&MCSDate = 0; /* fill out with zeroes if pnr not in mcolib.&score if only rely on LPR */;
                %if %symexist(LINK&score) %then &score&MCSDate = &&LINK&score;;

                if a;
	  %runquit;
%if %UPCASE(&mergebase)=TRUE %then %do;
	data &basedata;
	    merge &basedata (in=a) &outlib..&score&MCSDate (in=b);
		by pnr &MCSDate;
		if a; /* fill out with zeroes if pnr not in mcolib.&score */
	  %runquit;
	  %end;
        %end;
    %else %put &score tables not found or mcolib not available;
    %mend;




