/* getdiag() */
/* */
/*
outlib:         output library
diaglist:       diagnosis list, define diagnoses using %DefineIndicator()
diagtype=:      diagnosetyper, tegn, med mellemrum (A, B, C, G, H og +) og nu med LPR3 koder også
ICD8=:          TRUE/FALSE include ICD8 codes
indata=:      input datasæt med identer og evt fromdate= og todate= variable
fromyear=:      start later than 1977
outdata=:       outputdatasæt med pnr, IDate, diagnose, outcome, source
SOURCE=:        basic source of data
fromdate=:      variable in basedata= restrict diagnoses from
todate=:        variable in basedata= restrict diagnoses to
*/
%macro getDiag(outlib, diaglist, diagtype=A B ALGA01 ALGA02, icd8=FALSE, indata=, fromyear=1977, outdata=, SOURCE=LPR PSYK PRIV LPR3, fromdate=, todate=);
	%local N nsets diag nsource s stype filelist inline lenstr;
*	options mlogic symbolgen merror mprint;
	%global FD_RC;

    %start_timer(getdiag); /* measure time for this macro */

    %let ICD8=%UPCASE(&ICD8);
	%let nsource = %sysfunc(countw(&SOURCE));
	%let nsets = %sysfunc(countw(&diaglist));
	%if &nsets > 1 %then %do;
		%nonrep(mvar=diaglist, outvar=newdiaglist);
		%let nsets = %sysfunc(countw(&newdiaglist));
		%let diaglist = &newdiaglist;
	%end;

	%do N=1 %to &nsets; /* start of outer do */
		%let diag = %lowcase(%scan(&diaglist,&N));
		%if %symexist(LPR&diag) %then %do;
		%let filelist=;
		%let inline=;
		%do s=1 %to &nsource; /* start of inner do */
			%let stype = %lowcase(%scan(&SOURCE,&s));
			%let FD_RC=;
			%findingDiag(&diag.ALL&s, &diag,
				%if &ICD8=TRUE and %symexist(LPR&diag._ICD8) %then &&LPR&diag._ICD8; &&LPR&diag,
				diagtype=&diagtype, indata=&indata, fromyear=&fromyear,
				SOURCE=&stype, fromdate=&fromdate, todate=&todate);
			%if &FD_RC=0 %then %do;
				%let filelist= &filelist &diag.ALL&s(in=in&s) ;;
				%let inline = &inline +&s*in&s;;
			%end;
		%end; /* end of inner do */
		/* Combine all data from potential sources and include a source identifier in the final dataset */
    proc sql noprint;
        create table char_vars as select upcase(name) as name, max(length) as maxlength, min(length) as minlength
            from dictionary.columns
            where libname=upcase("&in") and index(memname,upcase("&diag.ALL"))>0 and upcase(type)="CHAR"
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
		data &outlib..LPR&diag.ALL;
		&lenstr.;
			set &filelist;
			_in=0 &inline;
			source=lowcase(scan("&SOURCE",_in));

			drop _in;
        %runquit;
		proc sort data=&outlib..LPR&diag.ALL;
	    by pnr %testvar(&outlib..LPR&diag.ALL,,start,nocomma=TRUE,outvar=FALSE)
	           %testvar(&outlib..LPR&diag.ALL,,tidspunkt_start,nocomma=TRUE,outvar=FALSE)
	           %testvar(&outlib..LPR&diag.ALL,,tidspunkt_slut,nocomma=TRUE,outvar=FALSE)
			 diag;
		%RunQuit;

		%if &outdata ne %then %do;
			proc sql inobs=&sqlmax;
			%if &N=1 %then create table &outlib..&outdata as ;
			%else insert into &outlib..&outdata;
			select pnr, start as IDate, DIAG AS diagnose length=10, outcome length=20, source
			from &outlib..LPR&diag.ALL;
			%sqlquit;
		%end;
	   %end;  %else %put WARNING getDiag: LPR&diag does not exist; /* end of if symexist */
	%end; /* end of outer do */
	%if &outdata ne %then %do;
		proc sort data = &outlib..&outdata nodupkey;
			by pnr idate diagnose outcome ;
		%runquit;
	%end;


	%end_timer(getDiag, text=Measure time for GetDiag macro);
%mend;

/*
findingDiag();

outdata:    output datanavn
outcome:    tekststreng outcome label, should be short
icd:	      ICD koder version 8 eller 10, uden foranstillet D eller punktum,
adskilles ved mellemrum.
diagtype:   diagnosetyper, tegn, med mellemrum (A, B, C, G, H og +) og nu med LPR3 koder også
indata:   input datasæt med identer og skæringsdato
fromyear:   start later than 1977
SOURCE:     basic source of data
*/

%macro findingDiag(outdata, outcome, icd, diagtype=, indata=, fromyear=, SOURCE=LPR, fromdate=, todate=);
	%local localoutdata yr I dval dsn1 dsn2 dsn3 M tablegrp dlstcnt startdiagtime lastyrGH ;
	%if "&icd" ne "" %then %let dlstcnt = %sysfunc(countw(&icd)); %else %let dlstcnt=0;;
	%if "&diagtype" ne "" %then %let diagtype = %upcase(&diagtype);

	%let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */

	/* log eksekveringstid */
	%put start findingDiag: %qsysfunc(datetime(), datetime20.3);
	%let startDiagtime = %qsysfunc(datetime());
	/* find last available dataset */
	%let lastyrGH=%sysfunc(today(),year4.);
        %let SOURCE = %UPCASE(&SOURCE);
	%if "&SOURCE"="PSYK" %then %do;
		%let fromyear=2019;
		%let lastyrGH=2019;
		%let tablegrp=psyk;
	%end;
	%if "&SOURCE"="PRIV" %then %do;
		%if &fromyear<2002 %then %let fromyear=2002;
		%let tablegrp=priv;
		%let lastyrGH=2019;
	%end;
	%if "&SOURCE"="LPR" %then %let tablegrp=lpr;

	%if "&SOURCE"="LPR3" %then %do;
		%let lastyrGH=%sysfunc(date(),year4);
		%let tablegrp=&LPR3grp;/* NB assume at LPR3 always has a year label on file */
		%do %while (%sysfunc(exist(master.&tablegrp._kontakter&lastyrGH))=0 and &lastyrGH>2018);
			%let lastyrGH=%eval(&lastyrGH - 1);
		%end;
		%let fromyear=&lastyrGH;
	%end;

	%if &fromyear ne 0 and &lastyrGH ne 0 and  "&SOURCE" ne "LPR3" %then %do;
		%do %while (%sysfunc(exist(master.&tablegrp._adm&fromyear))=0 and &lastyrGH>&fromyear);
			%let fromyear=%eval(&fromyear + 1);
		%end;
		%do %while (%sysfunc(exist(master.&tablegrp._adm&lastyrGH))=0 and &lastyrGH>&fromyear);
			%let lastyrGH=%eval(&lastyrGH - 1);
		%end;
	%end;
	%let FD_RC=0;

	%if "&SOURCE"="LPR" %then %do;
		%if %sysfunc(exist(master.&tablegrp._adm&lastyrGH))=0 %then %do;
			%put WARNING getDiag: LPR data not available.;
			%let FD_RC=1;
		%end;
	%end;
	%if "&SOURCE"="PSYK" and %sysfunc(exist(master.&tablegrp._adm&lastyrGH))=0 %then %do;
		%put WARNING getDiag: LPR-PSYK data not available.;
		%let FD_RC=1;
	%end;
	%if "&SOURCE"="PRIV" %then %do;
		%if %sysfunc(exist(master.&tablegrp._adm&lastyrGH))=0 %then %do;
			%put WARNING getDiag: LPR-PRIV data not available.;
			%let FD_RC=1;
		%end;
	%end;

	%if "&SOURCE"="LPR3" %then %do;
		%if %sysfunc(exist(master.&tablegrp._kontakter&lastyrGH))=0 and %sysfunc(exist(master.&tablegrp._diagnoser&lastyrGH))=0 %then %do;
			%put WARNING getDiag: LPR3 data not available.;
			%let FD_RC=1;
		%end;
	%end;
    %if &FD_RC=0 %then %do;

		%if "&SOURCE" eq "LPR3" %then %let loopend=&fromyear; %else %let loopend=&lastyrGH;;
		%do yr=&fromyear %to &loopend;
                   %if "&SOURCE" eq "LPRPSYK" %then %do;
                        %let dsn1= master.&tablegrp._ADM&yr;
                        %let dsn2= master.&tablegrp._DIAG&yr;
                    %end;
                    %else %if "&SOURCE" eq "LPR3" %then %do;
                        %let dsn1=  master.&tablegrp._kontakter&lastyrGH;
                        %let dsn2=  master.&tablegrp._diagnoser&lastyrGH;
                    %END;
                    %else %do;
                            %let dsn1= master.&tablegrp._adm&yr;
                            %let dsn2= master.&tablegrp._diag&yr;
                    %end;
			proc sql inobs=&sqlmax;
                            %if %sysfunc(exist(&dsn1)) and %sysfunc(exist(&dsn2)) %then %do;
                                create table &localoutdata as
                                    select distinct
                                    a.*,
                                    %if "&fromdate" ne "" %then c.&fromdate as fromdate format=date10.,;
                                    %if "&todate" ne "" %then c.&todate as todate format=date10.,;
                                    b.*
                                        from &dsn1 a inner join &dsn2(rename=(kontakt_id=kontakt_id_b)) b on
                                        (a.kontakt_id=b.KONTAKT_ID_b)
                                        %if &indata ne %then %do;
                                        inner join &indata c on a.pnr=c.pnr
                                            %if "&fromdate" ne "" %then %do;
                                            and a.start between c.&fromdate and %if "&todate" ne "" %then c.&todate;
                                            %else c.&fromdate;
                                            %end;
                                        %end;
					where
					YEAR(a.start) >=  &fromyear
					%if &dlstcnt > 0 %then %do;
						and (
						%do Y=1 %to &dlstcnt;
							%let dval = %UPCASE(%qscan(&icd,&Y));
							%if &Y>1 %then OR ;
							/* ICD8 er numerisk ICD10 starter altid med et bogstav */
							%if %sysfunc(anyalpha(&dval),1) ne 0 %then %do;  /* If there is a character in the diagnosis (result from anyalpha ne 0) -> IDC-10 */
                                                        UPCASE( b.diag) like  "D&dval.%"
                                                            %if %index("&diagtype",+)>0 %then
                                                            OR UPCASE( b.diag) like  "&dval.%";
							%end; /* ICD-10, og evt med tillægskode uden D */
							%else %do;
								UPCASE(b.diag) like  "&dval.%"
							%end; /* ICD-8 - ingen tillægskoder */
						%end;
						 )
					 %end;
					%if "&diagtype" ne "" %then %do;    and
						upcase(b.DIAGTYPE) in (%quotelst(&diagtype,delim=%str(, )))
					%end;
			%end;
			;
			/*%SqlQuit;*/
			data &outdata;
                            set %if &yr ne &fromyear %then &outdata; &localoutdata(drop=kontakt_id_b);
                            outcome="&outcome";
			run;

		%end;


		%cleanup(&localoutdata);

%end;
	data _null_;
		endDiagtime = datetime();
		timeDiagdif=endDiagtime-&startDiagtime;
		put 'executiontime FindingDiag ' timeDiagdif:time20.6;
	run;
%mend;



