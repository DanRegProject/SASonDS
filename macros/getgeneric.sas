%macro get(outlib=work, sets=, fromyear=1997, type=,
           indata=, outdata=, SOURCE=LPR PSYK PRIV LPR3, fromdate=, todate=,
           getvar=, subset=);

%start_timer(get); /* measure time for this macro */
%let type=%UPCASE(&type);
%local N nsets name code nsource RC filelist filelist2;
%global firstrun lastrun;
%PUT start get: %sysfunc(datetime(),datetime20.3);
%LOCAL I nvar outdat error;
%LET error=0;

%IF &sets=  or &type=  %THEN %DO;
   %PUT get ERROR: Required arguments not specified, sets or type ;
   %LET error=1;
%END;

%IF %sysfunc(countw(&type))>1 %THEN %DO;
   %PUT get ERROR: Only one type allowed;
   %LET error=1;
%END;

%IF %sysfunc(find("DIAG OPR UBE &xtragettypes",&type,i))=0 %THEN %DO;
   %PUT get ERROR: type (&type) not one of : DIAG OPR UBE &xtragettypes;
   %LET error=1;
%END;

%IF &error=0 %THEN %DO;
   %let nsets = %sysfunc(countw(&sets));
   %if &nsets > 1 %then %do;
      %nonrep(mvar=sets, outvar=newsets);
      %let nsets = %sysfunc(countw(&newsets));
      %let sets = &newsets;
   %end;

   %let firstrun=1;
   %let lastrun=0;

   %IF %sysfunc(find("&xtragettypes",&type,i)) ne 0 %THEN %LET SOURCE=&TYPE;
   %let nsource = %sysfunc(countw(&SOURCE));

   %do N=1 %to &nsets;
      %let code = %upcase(%scan(&sets,&N)); /* go through the sets */
      %if %symexist(&type.&code) %then %do;
         %let filelist=;
         %let filelist2=;
         %let inline=;

         %IF &N=&nsets %THEN %LET lastrun=1;
         %do s=1 %to &nsource;
            %let type = %lowcase(%scan(&SOURCE,&s));
            %let RC=;

          
%findrows(outdata=&type.&code.ALL&s, outcome=&code, code=&&type&code, indata=&indata,
          fromyear=&fromyear, type=&type, SOURCE=&stype, returncode=RC,
          fromdate=&fromdate, todate=&todate,
          getvar=&getvar, subset=&subset); /*See above*/

%if &RC=0 %then %do;
   %let filelist= &filelist &type.&code.ALL&s(in=in&s) ;;
   %let filelist2= &filelist2 &type.&code.ALL&s ;;
   %let inline = &inline +&s*in&s;;
%end;

%end; /* end of do s= */
%let firstrun=0;

proc sql noprint;  /* find alle tekstvariable hvor length ikke er ens */
   create table char_vars as select upcase(name) as name, max(length) as maxlength, min(length) as minlength
      from dictionary.columns
      where libname=upcase("WORK") and prxmatch("/%UPCASE(&type.&code.all)([^A-Za-z]|$)/",memname)>0
            and upper(type)="CHAR"
      group by upcase(name)
      having minlength<maxlength
      order by name;
   %let lenstr=;
quit;

data _null_;  /* lav et length statement med største værdi */
   set char_vars end=eof;
   by name;
   length len_stmt $300;
   retain len_stmt 'length';
   if first.name;
      len_stmt = catx(' ',len_stmt, strip(name), '$', strip(maxlength));
   if eof then call symput('lenstr', trim(len_stmt));
run;

data &outlib..&type.&code.ALL;
   &lenstr.;
   set &filelist;
   _in=0 ; &inline;
   source=lowcase(scan("&SOURCE",_in));
   drop _in;
%runquit;

%cleanup(char_vars &filelist2);

proc sort data=&outlib..&type.&code.ALL;
   by pnr &&&type.stdgetdatevar &&&type.stdgetcodevar;
%runquit;

%if &outdata ne  %then %do;
   proc sql nobs=&sqlmax;
      %if &N=1 %then create table &outlib..&outdata as ;
      %else insert into &outlib..&outdata;
      select &&&type.stdgetdatevar as lDate, %commas(&&&type.stdgetvar)
      from &outlib..&type.&code.ALL;
   %sqlquit;

   %end;
%end; /* symexist */
%else %put get WARNING: &code not defined for &type;;
%end; /* end of do N= */
%if &outdata ne  %then %do;
   proc sort data = &outlib..&outdata nodupkey;
      by &&&type.stdgetvar;
   %runquit;
%end;
%END; /*error=0*/
%end_timer(get, text=Measure time for Get macro);
%mend;

/*
   findrows();

   outdata:    output datanavn
   outcome:    tekststreng outcome label, should be short
   indata:     input dataset med identer og skæringsdato
   fromyear:   startår
*/

%macro findrows(outdata=, outcome=, code=, indata=, fromyear=, type=, SOURCE=LPR, returnCode=, fromdate=,
                todate=, getvar=, subset=);

%local localoutdata dlstcnt starttime yr I locdsn1 locdsn2 locdsn3;
%if &code ne  %then %let dlstcnt = %sysfunc(countw(&code)) ; %else %let dlstcnt=0;

%let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasetnavn så data i work */
/* log eksekveringstid */
%put start findrows: %sysfunc(datetime(), datetime20.3);
%let startgettime = %sysfunc(datetime());
%let tablegrp=;
%let source=%UPCASE(&SOURCE);
%if %sysfunc(find("DIAG OPR UBE",&type,i))>0 %THEN %let tablegrp = &SOURCE._;

%let DSN1=%UPCASE(&&&SOURCE.prim);
%let dsn2=;
%if %symexist(&&&SOURCE.&type)=1 %then %let DSN2=%UPCASE(&&&SOURCE.&type);
%let dsn3=;
%if %symexist(&&&SOURCE.&type.2)=1 %then %let DSN3=%UPCASE(&&&SOURCE.&type.2);
%if "&SOURCE"="LPR3" %then %do;
   %let tablegrp = %UPCASE(&LPR3grp._);
%end;

%if &fromdate ne  %then %do;
   %let fromdate=c.&fromdate;
   %IF &todate ne  %THEN %LET todate=c.&todate; %ELSE %LET todate=c.&fromdate;
%end;
%if &fromyear ne  and &fromdate eq  %THEN %DO;
   %let fromdate=mdy(1,1,&fromyear);
   %LET todate=today();
%END;
%LET ds_names=;

proc sql noprint;
   select memname into :ds_names separated by ' '
   from dictionary.tables
   where upcase(libname)="MASTER" and prxmatch("/&tablegrp.&dsn1.([^A-Za-z_]|$)/",upcase(memname))>0 and
         (upcase(memtype)="DATA" or upcase(memtype)="VIEW")
   order by memname;

%LET getvar = %UPCASE(&&&type.stdgetvar &getvar);

%let I=1;
%do %while (%SCAN(&ds_names,&I) ne );
   %let RC=0;
   %if &dsn2 ne %then %let locdsn2= %SYSFUNC(tranwrd(%SCAN(&ds_names,&i),&dsn1,&dsn2));
   %if &dsn3 ne %then %let locdsn3= %SYSFUNC(tranwrd(%SCAN(&ds_names,&i),&dsn1,&dsn3));
   %let locdsn1= %SCAN(&ds_names,&i);
      %LET rename=;
   %LET rename2=;

   %if &dsn2 eq or (&dsn2 ne and %sysfunc(exist(master.&locdsn2))=1 and &dsn3 eq) or
      (&dsn2 ne and %sysfunc(exist(master.&locdsn2))=1 and &dsn3 ne and %sysfunc(exist(master.&locdsn3))=1 )
   %then %do;

   %IF &firstrun=1 %THEN %DO;
      %LET rename=;
      %LET rename2=;
      proc sql noprint;
         %if &dsn2 ne %then %DO;
            select trim(a.name)||'='||trim(a.name)||'_b' into :rename separated by ' '
            from (select distinct(name) from dictionary.columns
                  where upcase(libname)="MASTER" and memname="&locdsn1"
                  %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));) a,
                 (select distinct(name) from dictionary.columns
                  where upcase(libname)="MASTER" and memname="&locdsn2"
                  %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));) b
            where a.name=b.name;
         %end;

         %if &dsn3 ne %then %do;
            select trim(a.name)||'='||trim(a.name)||'_c' into :rename2 separated by ' '
            from (select distinct(name) from dictionary.columns
                  where upcase(libname)="MASTER" and (memname="&locdsn1" or memname="&locdsn2")
                  %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));) a,
                 (select distinct(name) from dictionary.columns
                  where upcase(libname)="MASTER" and memname="&locdsn3"
                  %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));) b
            where a.name=b.name;
         %end;

         select distinct(name) into :locgetvar1 separated by ', ' from dictionary.columns
            where upcase(libname)="MASTER" and memname="&locdsn1"
            %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));
%if &dsn2 ne %then
   select distinct(name) into :locgetvar2 separated by ', ' from dictionary.columns
      where upcase(libname)="MASTER" and memname="&locdsn2"
      %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));

%if &dsn3 ne %then
   select distinct(name) into :locgetvar3 separated by ', ' from dictionary.columns
      where upcase(libname)="MASTER" and memname="&locdsn3"
      %IF &getvar ne %THEN and upcase(name) in (%quotelist(&getvar, delim=%str(, )));

%runquit;

%let rename=%sysfunc(tranwrd(&rename,"_","_"));
%let rename2=%sysfunc(tranwrd(&rename2,"_","_"));

proc sql noprint inobs=&sqlmax;
   create table work.&locdsn1 as select &locgetvar1 from master.&locdsn1;
%if &dsn2 ne %then create table work.&locdsn2(rename=(&rename)) as select &locgetvar2 from master.&locdsn2;;
%if &dsn3 ne %then create table work.&locdsn3(rename=(&rename2)) as select &locgetvar3 from master.&locdsn3;;

   %IF &indata ne or "&fromdate" ne "" %then %do;
      delete from work.&locdsn1  where
            pnr not in (select distinct pnr from &indata)
         ;
      %if &dsn2 ne %then delete from work.&locdsn2  where &&&type.stdgetkeyvar._b not in (select &&&type.stdgetkeyvar
         from work.&locdsn1);;
      %if &dsn3 ne %then delete from work.&locdsn3  where &&&type.stdgetkeyvar._c not in (select &&&type.stdgetkeyvar
         from work.&locdsn1);;
   %end;
quit;
%end; /* firstrun */

proc sql inobs=&sqlmax;
   create table &localoutdata as
      select distinct
         a.*
         %if &dsn2 ne %then , b.*;
         %if &dsn3 ne %then , c.*;
         %if "&fromdate" ne "" %then , &fromdate as fromdate format=date10.;
         %if "&todate" ne "" %then , &todate as todate format=date10.;
      from &locdsn1 a
         %if &dsn2 ne %then inner join &locdsn2 b on
            (a.&&&type.stdgetkeyvar=b.&&&type.stdgetkeyvar._b);
         %if &dsn3 ne %then inner join &locdsn3 c on
            (a.&&&type.stdgetkeyvar=c.&&&type.stdgetkeyvar._c);

   %if &dlstcnt>0 or %quote(&subset) ne %then where;
      %if &dlstcnt > 0 %then %do;
         (
            %do v=1 %to &dlstcnt;
            %let dval = %upcase(%scan(&code,&v));
            %if &v>1 %then OR ;
               upcase(&&&type.stdgetcodevar) like "&dval%nstr(%%)"
         %end;
      )
   %end;
   %if &dlstcnt>0 and %quote(&subset) ne  %then and;
   %if %quote(&subset) ne  %then &subset;

   %if "&fromdate" ne "" %then %do;
      %if &dlstcnt>0 or %quote(&subset) ne  %then and; &&&type.stdgetdatevar
         between &fromdate and &todate
   %end;

   ;

quit;
%if &sqlrc=0 or &i=1 %then %do;
data &outdata;
%if &sqlrc=0 or &i>1 %then %do;   set
      %if &i>1 %then &outdata;
      %if &sqlrc=0 %then %do; &localoutdata(drop=
         %if &dsn2 ne %then &&&type.stdgetkeyvar._b;
         %if &dsn3 ne %then &&&type.stdgetkeyvar._c;
      );
      %end;
      ;
      %end;
   &type.outcome="&outcome";
run;
%end;
%end;
%let I=%eval(&I+1);
%if &lastrun=1 %THEN %DO;
   %cleanup(&locdsn1 &locdsn2 &locdsn3);
%END;
%end;

%cleanup(&localoutdata);

data _null_;
   endgettime = datetime();
   timedif=endgettime-&startgettime;
   put 'executiontime Findrows ' timedif:time20.6;
run;

%mend;

