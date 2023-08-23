
*libname outdata "../outputdata";

%macro datacheck(inlib,doclib=.,key=v_pnr_encrypted v_cpr_encrypted patient_cpr_encrypted v_recnum k_recnum patient_cpr_encrypted cpr_encrypted kontakt_id PERSONNUMMER_ENCRYPTED,key2=);
	%let key =&key &key2;
	%let inlib=%upcase(&inlib);
	proc sql noprint;
		select memname into :ds_list separated by ' '
		from dictionary.tables where libname = "&inlib" and upcase(memname) not like "TABLEVARS%" order by memname;
	%macro loops;
		%local n i this thisv m j first;
		%let first=1;
		%let n = %sysfunc(countw(&ds_list));
		%let m = %sysfunc(countw(&key));
		%do i = 1 %to &n;
			%let year=.;
			%let this= %upcase(%sysfunc(scan(&ds_list,&i)));
			%if %index(&this,19)>0 or %index(&this,20)>0 %then %do;
				%let year = %substr(&this,%length(&this)-3);
				%let this = %substr(&this,1,%length(&this)-4);
			%end;
			proc sql noprint;
			select upcase(name) into :vlist separated by ' ' from dictionary.columns where upcase(libname) = "&inlib" and upcase(memname) = %if &year eq . %then  "&this"; %else "&this&year";;
			%if &first=1 %then create table tablevars as ;
			%else insert into tablevars;
			select "&this" as table length=30, &year as year, upcase(name) as varname, 0 as Nkey  from dictionary.columns
			where upcase(libname) = "&inlib" and upcase(memname) = %if &year eq . %then "&this"; %else "&this&year";;
			insert into tablevars
			set table="&this" , year=&year , varname="_TOT_N_", Nkey=0;
			%do j = 1 %to &m;
				%let thisv= %upcase(%sysfunc(scan(&key,&j)));
				%if %sysfunc(indexw(&vlist,&thisv))>0 %then %do;
					%if &year eq . %then %let tab = &inlib..&this; %else %let tab = &inlib..&this&year;;
					%put tab: &tab;
					update tablevars set Nkey= (select count(*) from (select distinct &thisv from 
					%if &year eq . %then &inlib..&this; %else &inlib..&this&year; 
					%if %varexist(&tab,rec_out) eq 1 %then where rec_out>today();))
					where upcase(table)="&this" and upcase(varname)="&thisv" %if &year ne . %then and year=&year;;
					update tablevars set Nkey= (select nobs from dictionary.tables where upcase(libname) = "&inlib" and upcase(memname) = 
					%if &year eq . %then  "&this"; %else "&this&year";
					%if %varexist(&tab,rec_out) eq 1 %then and rec_out>today();)
					where upcase(table)="&this" and upcase(varname)="_TOT_N_" %if &year ne . %then and year=&year;;
				%end;
	        %end;
		%let first=0;
	    %end;
	%mend;
	%loops;
	quit;


	libname dltemp  "&doclib.";
	proc tabulate data=tablevars out=dltemp.tablevars%sysfunc(&Last_dataUpdate)(drop= _TYPE_ _PAGE_ _TABLE_); missing;
		class table varname year;
		var Nkey;
		table table, varname, year*Nkey="N unique"*sum=""*f=8.0;
	run;

	proc sql noprint;
		select memname into :tv_list separated by ' '
		from dictionary.tables where libname = "DLTEMP" and upcase(memname) like "TABLEVARS%" order by memname;
	run; quit;
	
	%if %sysfunc(countw(&tv_list))=1 %then %do; *Ved første kørsel genereres en dummy kopi;
		data dltemp.tablevars00001; set dltemp.tablevars%sysfunc(&Last_dataUpdate);
		run;
		%let tv_list = TABLEVARS00001 &tv_list;
	%end;

	data tablevarsCombined; merge dltemp.%sysfunc(scan(&tv_list,%sysfunc(countw(&tv_list)))) 
								  dltemp.%sysfunc(scan(&tv_list,%sysfunc(countw(&tv_list))-1))(rename=(Nkey_Sum=Nkey_Sum_old));
		by table varname year;
		type = "Num";
		output;
		type = "diff";
		Nkey_Sum=Nkey_Sum-Nkey_Sum_old;
		output;
	run; 

	ods pdf file="&doclib/UdtraeksDokumentation.pdf";
		%let curdir=%sysfunc(pathname(&inlib));
		title "Kontrol dokument for &curdir";
		proc tabulate data=tablevarsCombined missing;
			class table varname type year;
			var Nkey_Sum;
			table table, varname*type, year*Nkey_Sum="N unique"*sum=""*f=8.0;
		run;
	ods pdf close;
%mend;

*%datacheck(outdata);

%macro codecheck(inlib,table,var,len,doclib=.);
    %let inlib=%upcase(&inlib);
    %let table=%upcase(&table);
proc sql noprint;
    select memname into :ds_list separated by ' '
        from dictionary.tables where upcase(libname) = "&inlib" and upcase(memname) like "&table%" order by memname;
%macro loops;
    %local n i this thisv m j first;
	%let first=1;
    %let n = %sysfunc(countw(&ds_list));
    %do i = 1 %to &n;
		%let year=.;
        %let this= %upcase(%sysfunc(scan(&ds_list,&i)));
		%if %index(&this,19)>0 or %index(&this,20)>0 %then %do;
			%let year = %substr(&this,%length(&this)-3);
			%let this = %substr(&this,1,%length(&this)-4);
		%end;
        proc sql noprint;
    	%if &first=1 %then create table tablecodes as ;
				%else insert into tablecodes;
				select distinct "&this" as table length=30, &year as year, substr(&var,1,&len) as &var
                                    from &inlib..&table&year;;
		%let first=0;
	%end;
    %mend;
%loops;
quit;
ods pdf file="&doclib/UdtraeksDokumentation_&table..pdf";
%let curdir=%sysfunc(pathname(&inlib));
title "Kontrol dokument for &curdir - tabel &table";
proc tabulate data=tablecodes missing;
class table &var year;
table table, &var, year*N=""*f=8.0;
run;
ods pdf close;
%mend;
