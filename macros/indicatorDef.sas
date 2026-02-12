%macro IndicatorDef(type, name, short_txt, code, icd8=, w=, wdays=, crit=, verbose=FALSE);
   %let type=%upcase(&type);
   %global &type.&name &type.L&name ;

   %let &type.&name        = &code;
   %let &type.L&name       = &short_txt;  /* "label" - description */
   %if &type = DIAG %then %do;
      %global &type.&name._ICD8;;
      %let &type.&name._ICD8   = &icd8;  /* list of ICD8 codes */
   %end;

   %if &w ne        %then %do;
      %global &type.&name.W;
      %let &type.&name.W=&w;
   %end;

   %if &wdays ne    %then %do;
      %global &type.&name.D;  %let &type.&name.D=&wdays;
   %end;

   %if "&crit" ne "" %then %do;
      %global &type.&name.C;  %let &type.&name.C=&crit;
   %end;

   %if &verbose=TRUE %then %do;
      /* print names */
      %put &type.&name        = &&&type.&name;
      %put &type.L&name       = &&&type.L&name;

      /* special case for LPR - also including ICD8 */
      %if &type eq DIAG %then %do;
         %put &type.&name._ICD8 = &&&type.&name._ICD8;
      %end;

      %if &w ne        %then %do;
         %put &type.&name.W = &&&type.&name.W;
      %end;

      %if &wdays ne    %then %do;
         %put &type.&name.D = &&&type.&name.D;
      %end;

      %if "&crit" ne "" %then %do;
         %put &type.&name.C = &&&type.&name.C;
      %end;
   %end;
%mend;
