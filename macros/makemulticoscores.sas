/* macros to create datawarehouse to calculated riskscores in projects */

%macro makemulticotables(score);
    %start_log(&logdir, &score, option=new);
    %start_timer(&score);

    %makemulticotable(&score);

    %end_timer(&score, text=execution time getting all &score tables from scratch);
    %end_log;
%mend;


%macro makemulticotable(score);
    %local I name;
	
    %let I=1;
    %if %symexist(LPR&score.&I) %then %do;
        %do %while(%symexist(LPR&score.&I));
            %let name = &score.&I;

            %if &&LPR&score.&I ne %then %getDiag(work, &name, ICD8=TRUE
                %if %symexist(LPR&score.&I.C) %then , &&LPR&score.&I.C;);; 
            %let I=%eval(&I+1);
        %end;
        %reduceLPRmulticotables(&score);
    %end;

    %let I=1;
    %if %symexist(ATC&score.&I) %then %do;
        %do %while(%symexist(ATC&score.&I));
            %let name = &score.&I;

            %if &&ATC&score.&I ne %then %getMedi(work, &name);;
            %let I=%eval(&I+1);
        %end;
    %reduceMEDImulticotables(&score);
    %end;

%mend;

%macro reduceLPRmulticotables(score);
    %local I sets name recn;
    %let I=1;

    %if %symexist(LPR&score.&I) %then %do;
        %do %while(%symexist(LPR&score.&I));
           %let name = LPR&score.&I;
           %if &&LPR&score.&I ne %then %do;

            proc sort data=work.lpr&score.&I.all nodupkey out=work.&score.&I._red;
            where &projectdate between rec_in and rec_out;
            by pnr indate ;
            %runquit;

*            %smoothhosp(work.&score.&I._red, work.&score.&I._red, ajour=&projectdate); /* no need for corrected discharge date */

            data work.&score.&I._red;
                set work.&score.&I._red;
                wdays=.;
                %if %symexist(LPR&score.&I.D) %then wdays = &&LPR&score.&I.D;;

                weight = &&LPR&score.&I.W;

                length outcome $20. label $50.;
                outcome="&name";
                label=&&LPRL&score.&I;

                %let recn=;
                %if &update=TRUE %then %let recn=1;;
                rec_in&recn=&projectdate;
                rec_out&recn=&globalend;
                format rec_in&recn rec_out&recn date.;
               * rename hosp_in=indate hosp_out=outdate;
                %if &update=TRUE %then id = catx(" ",of outcome hosp_in hosp_out weight);;
                keep pnr outcome label indate weight rec_in&recn rec_out&recn wdays %if &update=TRUE %then id;;
           %runquit;

           %if &update=TRUE %then %do;
                data work.base&score.&I._red;
                    set mcolib.LPR&score;
                    where outcome="&name";
                    id=catx(" ", of outcome indate weight);
                %runquit;

                proc sort data=work.base&score.&I._red;
                    by pnr %if &update=TRUE %then id; outcome indate ;
                %runquit;

                data work.&score.&I._red;
                    merge work.&score.&I._red(in=a) work.base&score.&I._red(in=b);
                    by pnr id;
                    if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
                    if a and not b then to; rec_out=rec_out1; rec_in=rec_in1; end;
                    drop rec_in1 rec_out1 id;
                %runquit;

                proc sort data=work.&score.&I.red;
                    by pnr outcome indate  rec_in rec_out;
                %runquit;
          %end;

          %let sets = &sets work.&score.&I._red;
          %let I=%eval(&I+1);
          %end;
       %end;
    %end;

    data mcolib.LPR&score;
        set &sets;
        by pnr outcome;
        if pnr ne "";
    %runquit;

    proc sort data=mcolib.LPR&score;
        by pnr outcome indate rec_in rec_out weight;
    %runquit;

%mend;


%macro reduceMEDImulticotables(score);
    %local I sets name recn;
    %let I=1;
    %if %symexist(ATC&score.&I) %then %do;
       %do %while(%symexist(ATC&score.&I));
           %let name = ATC&score.&I;
           %if &&ATC&score.&I ne %then %do;

            proc sort data=work.LMDB&score.&I.all nodupkey out=work.&score.&I._red;
            where &projectdate between rec_in and rec_out;
            by pnr eksd ;
            %runquit;

            data work.&score.&I._red;
                set work.&score.&I._red;
                wdays=.;
                %if %symexist(ATC&score.&I.D) %then wdays = &&ATC&score.&I.D;;
                weight = &&ATC&score.&I.W;
                length outcome $20. label $50.;
                outcome="&name";
                label=&&ATCL&score.&I;

                %let recn=;
                %if &update=TRUE %then %let recn=1;;
                rec_in&recn=&projectdate;
                rec_out&recn=&globalend;
                format rec_in&recn rec_out&recn date.;
                %if &update=TRUE %then id = catx(" ",of outcome eksd weight);;
                keep pnr outcome label eksd weight rec_in&recn rec_out&recn wdays %if &update=TRUE %then id;;
           %runquit;

           %if &update=TRUE %then %do;
                data work.base&score.&I._red;
                    set mcolib.LMDB&score;
                    where outcome="&name";
                    id=catx(" ", of outcome eksd  weight);
                %runquit;

                proc sort data=work.base&score.&I._red;
                    by pnr %if &update=TRUE %then id; outcome eksd ;
                %runquit;

                data work.&score.&I._red;
                    merge work.&score.&I._red(in=a) work.base&score.&I._red(in=b);
                    by pnr id;
                    if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
                    if a and not b then to; rec_out=rec_out1; rec_in=rec_in1; end;
                    drop rec_in1 rec_out1 id;
                %runquit;

                proc sort data=work.&score.&I.red;
                    by pnr outcome eksd  rec_in rec_out;
                %runquit;
          %end;

          %let sets = &sets work.&score.&I._red;
          %let I=%eval(&I+1);
         %end;
       %end;
    %end;

    data mcolib.LMDB&score;
        set &sets;
        by pnr outcome;
        if pnr ne "";
    %runquit;

    proc sort data=mcolib.LMDB&score;
        by pnr outcome eksd  rec_in rec_out weight;
    %runquit;

%mend;
