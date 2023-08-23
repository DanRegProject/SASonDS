%macro diag_txt(prefix, dir, list, output, ICD8=FALSE);
  %local I nof listname;

  %nonrep(mvar=list, outvar=newlist);
  %let nof = %sysfunc(countw(&newlist));

  data _null_;
    file "&dir\&output..txt";

  %do I=1 %to &nof;
    %let listname = %lowcase(%scan(&newlist,&I));
	put "| &listname | "  &&&prefix.L&listname   " | %upcase(&&&prefix.&listname) | " %if &ICD8=TRUE and %symexist(&prefix.&listname._ICD8)=1 %then "&&&prefix.&listname._ICD8 | ";;
  %end;

  %runquit;
%mend;

%macro mco_txt(score,dir, output);
  %local U I W;

 data _null_;
    file "&dir\&output..txt";
    put "Definition for score &score";
    %if %symexist(LINK&score) %then %do;
        put " Link function : &&LINK&score";
    %end;

    %if %symexist(LPR&score.N) %then %do;
        put / "| weight | text | ICD-10 | ICD-8 |";
        %do I = 1 %to &&LPR&score.N;
            put "| &&LPR&score.&I.W  |  " &&LPRL&score.&I " |  &&LPR&score.&I  | &&LPR&score.&I._ICD8  | ";
        %end;
    %end;
    %if %symexist(CPR&score.N) %then %do;
  put / "| weight | text | Criteria |";
    %do I = 1 %to &&CPR&score.N;
      put "| &&CPR&score.&I.W |  " &&CPRL&score.&I " |  &&CPR&score.&I.C  |  ";
    %end;
  %end;
    %if %symexist(OTH&score.N) %then %do;
  put / "| weight | text | Criteria |";
    %do I = 1 %to &&OTH&score.N;
      put "| &&OTH&score.&I.W |  " &&OTHL&score.&I " |  &&OTH&score.&I.C  |  ";
    %end;
  %end;

  run;
%mend;


%macro create_datalist(prefix, dir, list, output, ICD8=FALSE);
  %if %index(&mcolist,%upcase(&prefix))>0 %then %do;
    %mco_txt(&prefix, &dir, &output);
  %end;
  %else %do;
    %diag_txt(&prefix, &dir, &list, &output, ICD8=&ICD8);
  %end;
%mend;
