%macro getOpr(outlib, oprlist,fromyear=1997, type=opr, oprart="" "V" "P" "D" "I",
    indata=, outdata=, SOURCE=LPR PRIV LPR3, fromdate=, todate=);
  %start_timer(getopr); /* measure time for this macro */
  %let type=%UPCASE(&type);
  %if "&type"="UBE" and &fromyear<1999 %then %let fromyear=1999;
  %if "&type"="OPR" and &fromyear<1997 %then %let fromyear=1997;
  %local N nofOPR name code nsource RC lenstr;

  %let nsource = %sysfunc(countw(&SOURCE));
  %let nofOPR = %sysfunc(countw(&oprlist));

  %do N=1 %to &nofOPR;
    %let code = %lowcase(%scan(&oprlist,&N)); /* go through the oprlist */
    %if %symexist(&type.&code) %then %do;
        %let lastyrOPR=%sysfunc(today(),year4.);
        %let filelist=;
        %let inline=;
        %do s=1 %to &nsource;
            %let stype = %upcase(%scan(&SOURCE,&s));
            %let RC=;

            %findingOpr(&type.&code.ALL&s, &code,  &&&type&code,  indata=&indata,
                   fromyear=&fromyear, type=&type,  oprart=&oprart, SOURCE=&stype, returncode=RC,
                   fromdate=&fromdate, todate=&todate); /*See above*/

            %if &RC=0 %then %do;
                %let filelist= &filelist &type.&code.ALL&s(in=in&s) ;;
                %let inline = &inline +&s*in&s;;
            %end;
      %end; /* end of do s= */

	    proc sql noprint;
        create table char_vars as select upcase(name) as name, max(length) as maxlength, min(length) as minlength
            from dictionary.columns
            where libname=upcase("&in") and index(memname,upcase("&type.&code.ALL"))>0 and upcase(type)="CHAR"
            group by upcase(name)
            having minlength<maxlength
            order by name;

    data _null_;
        set char_vars end=eof;
        by name;
        length len_stmt $300;
        retain len_stmt 'length';
        if first.name;
        len_stmt = catx(' ',len_stmt, strip(name), '$', strip(maxlength)) ;
        if eof then call symput('lenstr',trim(len_stmt));
    run;
    data &outlib..&type.&code.ALL;
	&lenstr.;
          set &filelist;
	  _in=0 &inline;
	  source=lowcase(scan("&SOURCE",_in));
          drop _in;
    %runquit;

*    %cleanup(&filelist);

    proc sort data=&outlib..&type.&code.ALL;
	 by pnr %testvar(&outlib..&type.&code.ALL,,start,nocomma=TRUE,outvar=FALSE)
           %testvar(&outlib..&type.&code.ALL,,start_proc,nocomma=TRUE,outvar=FALSE)
           %testvar(&outlib..&type.&code.ALL,,starttid_proc,nocomma=TRUE,outvar=FALSE) proc;
   %runquit;

   %if &outdata ne %then %do;
         proc sql inobs=&sqlmax;
          %if &N=1 %then create table &outlib..&outdata as ;
	  %else insert into &outlib..&outdata;
	  select pnr, start as IDate, start_proc, proc, outcome, adiag_proc
	  from &outlib..&type.&code.ALL;
	  %sqlquit;
    %end;
  %end; /* symexist */
  %else %put getOPR WARNING: &code not defined for &type;;
  %end; /* end of do N= */
  %if &outdata ne %then %do;
    proc sort data = &outlib..&outdata nodupkey;
	  by pnr idate proc outcome ;
	%runquit;
  %end;
  %end_timer(getOPR, text=Measure time for GetOPR macro);
%mend;


/*
  findingOpr();

  outdata:    output datanavn
  outcome:    tekststreng outcome label, should be short
  opr:	      opr koder 10, uden foranstillet K
  oprart:     Operationsart, tegn, med mellemrum (D, P, V)

  pattype:    patienttyper, ciffer, adskildt med mellemrum (0, 1, 2 og 3)
  indata:   input datasæt med identer og skæringsdato
  fromyear:   startår
*/

%macro findingOpr(outdata, outcome, opr, oprart=, indata=, fromyear=, type=, SOURCE=LPR,returnCode=,fromdate=,todate=); /*Defined type to be operation per default - can use UBE*/
  %local localoutdata dlstcnt patcnt startOPRtime yr I first;
  %if &opr ne %then %let dlstcnt = %sysfunc(countw(&opr)); %else %let dlstcnt=0;;
  %let first = 1;
  %let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */
  /* log eksekveringstid */
  %put start findingOpr: %qsysfunc(datetime(), datetime20.3);
  %let startOPRtime = %qsysfunc(datetime());
  %let lastyrOPR=%sysfunc(today(),year4.);
  %let source=%UPCASE(&SOURCE);
	%if "&SOURCE"="PRIV" and &fromyear<2002 %then %let fromyear=2002;
	%if "&SOURCE"="PRIV" %then %let tablegrp=priv;
	%if "&SOURCE"="LPR"  %then %let tablegrp=lpr;
	%let tablename = adm;
	%if "&SOURCE"="LPR3" %then %do;
		%let lastyrOPR=%sysfunc(date(),year4);
		%let tablegrp = &LPR3grp;
		%if "&type" = "OPR" %then %do;
			%let tablename = procedurer_kirurgi;
		%end;
		%if "&type" = "UBE" %then %do;
			%let tablename = procedurer_andre;
		%end;
	%end;
        %do %while (%sysfunc(exist(master.&tablegrp._&tablename&lastyrOPR))=0 and &lastyrOPR>&fromyear);
			%let lastyrOPR=%eval(&lastyrOPR - 1);
        %end;
        %if &fromyear ne 0 and &lastyrOPR ne 0 and "&SOURCE" ne "LPR3" %then %do;
            %do %while (%sysfunc(exist(master.&tablegrp._sks&type.&fromyear))=0 and &lastyrOPR>&fromyear);
                %let fromyear=%eval(&fromyear + 1);
                %end;
            %do %while (%sysfunc(exist(master.&tablegrp._sks&type.&lastyrOPR))=0 and &lastyrOPR>&fromyear);
                %let lastyrOPR=%eval(&lastyrOPR - 1);
                %end;
        %end;
 	%if "&SOURCE"="LPR3" %then %let fromyear=&lastyrOPR;
        %let returncode0=0;

	%if "&SOURCE"="LPR" %then %do;
		%if %sysfunc(exist(master.&tablegrp._adm&lastyrOPR))=0 and %sysfunc(exist(master.&tablegrp._sks&type.&lastyrOPR))=0 %then %do;
			%put getOPR WARNING: LPR data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if "&SOURCE"="LPRPSYK" and %sysfunc(exist(master.&tablegrp._adm&yr))=0 %then %do;
		%put getOPR WARNING: LPR-PSYK data not available.;
		%let returncode0=1;
	%end;
	%if "&SOURCE"="PRIV" %then %do;
		%if %sysfunc(exist(master.&tablegrp._adm&lastyrOPR))=0 and %sysfunc(exist(master.&tablegrp._sks&type.&lastyrOPR))=0 %then %do;
			%put getOPR WARNING: PRIV data not available.;
			%let returncode0=1;
		%end;
	%end;
        %if "&SOURCE"="LPR3" %then %do;
		%if %sysfunc(exist(master.&tablegrp._&tablename&lastyrOPR))=0 %then %do;
			%put getOPR WARNING: LPR-F data not available.;
			%let returncode0=1;
		%end;
	%end;
        %if &returncode0=0 %then %do;
            %if "&SOURCE" eq "LPR3" %then %let loopend=&fromyear; %else %let loopend=&lastyrOPR;;
            %do yr=&fromyear %to &loopend;
                 proc sql inobs=&sqlmax;
		 		%if  "&SOURCE"="LPR3" %then %do;
					%let dsn1=  master.&tablegrp._kontakter&yr;
                    %let dsn2=  master.&tablegrp._&tablename.&yr;
                %end;
  	         	%else %do;
		     		%let dsn1=  master.&tablegrp._adm&yr;
		     		%let dsn2= master.&tablegrp._sks&type.&yr;
	   			%end;
				%if %sysfunc(exist(&dsn1)) and %sysfunc(exist(&dsn2)) %then %do;
                    create table &localoutdata as
                        select distinct
                        a.*
                        %if "&fromdate" ne "" %then c.&fromdate as fromdate format=date10.,;
                    %if "&todate" ne "" %then c.&todate as todate format=date10.,;
                    b.*
                        from
                        &dsn1 a inner join  &dsn2(rename=(kontakt_id=kontakt_id_b
						%if  "&SOURCE"="LPR3" %then forloeb_id=forloeb_id_b; ) b on
                        (a.kontakt_id=b.kontakt_id_b 
						%if  "&SOURCE"="LPR3" %then and a.forloeb_id=b.forloeb_id_b;)
        %if &indata ne %then %do;
			inner join &indata c on
			a.pnr=c.pnr
			%if "&fromdate" ne "" %then %do;
				and  b.start_proc between c.&fromdate
				and %if "&todate" ne "" %then c.&todate;
					%else c.&fromdate;
			%end;
        %end;
	  where
		%if &dlstcnt > 0 %then %do;
		(
			%do I=1 %to &dlstcnt;
				%let dval = %upcase(%qscan(&opr,&i));
				%if &i>1 %then OR ;
					upcase(b.PROC)  like "&dval%nrstr(%%)"
			%end;
		)
		%end;
	  /* in order to get at numeric list: */
	%if "&oprart" ne "" %then %do;
		%if &dlstcnt>0 %then and;
		b.proctype in (%commas(&oprart))
	%end;
 	%if &dlstcnt>0 or "&oprart" ne "" %then and;
 	a.pnr ne . ;

 	%sqlquit;
	data &outdata; set
		%if &first=0 %then &outdata;
            &localoutdata(drop=kontakt_id_b
			%if  "&SOURCE"="LPR3" %then forloeb_id_b;
			);
            outcome="&outcome";
	run;
	%let first = 0;
%end;
%end;
%end;

	%let &returnCode=&returncode0;

  %cleanup(&localoutdata);

  data _null_;
    endOPRtime = datetime();
    timeOPRdif=endOPRtime-&startOPRtime;
    put 'executiontime FindingOPR ' timeOPRdif:time20.6;
  run;
%mend;




