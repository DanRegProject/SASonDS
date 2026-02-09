%macro subsetdata(pop, head, inlib=master, outlib=mydata, primtab=, key=pnr, append=TRUE);

%local i first;
%let first=1;
%let append=%UPCASE(&append);
%IF %sysfunc(exist(&pop)) %then %do;
  %LET head=%UPCASE(&head);
  %LET ds_names=;
  proc sql noprint;
    select distinct memname into :ds_names separated by ' '
      from dictionary.tables
      where libname=upcase("&inlib") and prxmatch("/^&head.([^A-Za-z]|$)/",memname)>0 and 
      (upper(memtype)="DATA" or upper(memtype)="VIEW");
      %let i=1;
      %do %while (&scan(&ds_names,&i) ne );
        %let ds=&scan(&ds_names,&i);
        %if %varexist(&inlib..&ds,&key) %then %do;
          proc sql inobs=&sqlmax;
          create table _tempfile_ as 
            select "&ds" as _source_, a.*
            from &inlib..&ds a,
            (
              select distinct &key from
              %if &primtab ne %then (
                select '.&key from &inlib..&primtab.&i p, &pop q
                where p.pnr=q.pnr ) ;
            ) b, where a.&key=b.&key;
            quit;
          %if &append ne TRUE %THEN %DO;
            data &outlib..&ds;
          %END;
          %IF &append EQ TRUE %THEN %DO;
            data &outlib..&head;
          %END;
          set  
          %IF &append EQ TRUE and &first=0 %THEN
            &outlib..&head;
            _tempfile_;
          run;
          %IF &append EQ TRUE %THEN %LET first=0;
        %end;
        %ELSE %DO;
          proc sql inobs=&sqlmax;
            create table &outlib..&ds as
              select "&ds" as _source_, * from &inlib..&ds;
            quit;
        %END;
        %let I=%eval(&I+1);
      %end;
      %if &append=TRUE %THEN %DO;
        proc sort data=&outlib..&head;
          by pnr _source_;
        run;
      %END;
%END;
%ELSE %put THE file &pop does not exist;
%MEND;
