*libname outdata "../outputdata";
options mprint merror;
%macro updatecheck(inlib,arkivlib,doclib=., key="rec_in");
    %let inlib=%upcase(&inlib);
    %let arkivlib=%upcase(&arkivlib);
    %let key=%upcase(&key);
proc sql noprint;
    select memname into :in_list separated by ' '
        from dictionary.tables where libname = "&inlib" order by memname;
        select memname into :arkiv_list separated by ' '
        from dictionary.tables where libname = "&arkivlib" order by memname;
    %local n i this thisv m j first thist;
	%let first=1;
    %let n_in = %sysfunc(countw(&in_list));
    %let n_arkiv = %sysfunc(countw(&arkiv_list));
    %let m = %sysfunc(countw(&key));
        proc sql noprint;
    	create table tablecounts as
				select upcase(libname) as lib, upcase(memname) as table, upcase(name) as varname, 0 as value, 0 as N  from dictionary.columns
					where upcase(libname) in ("&inlib", "arkiv_lib")  and upcase(name) in (&key);
			%do i = 1 %to &m;
    			%let thisv= %upcase(%sysfunc(scan(&key,&i)));
				%put &thisv;
    			%let thisv= %qsysfunc(dequote(&thisv));
				%put &thisv;

			%do j = 1 %to &n_in;
    			%let thist= %upcase(%sysfunc(scan(&in_list,&j)));
		       	create table tmp1 as
                            select a.lib, a.table, a.varname, b.value, b.N from tablecounts a, (
                            select c.&thisv as value, count(*) as N from &inlib..&thist c
                            group by  c.&thisv) b
                            where a.lib="&inlib" and upcase(a.table)="&thist" and upcase(a.varname)="&thisv";
                        insert into tablecounts select * from tmp1;
                        %end;
                	%do j = 1 %to &n_arkiv;
    			%let thist= %upcase(%sysfunc(scan(&arkiv_list,&j)));
		       	create table tmp1 as
                            select a.lib, a.table, a.varname, b.value, b.N from tablecounts a, (
                            select c.&thisv as value, count(*) as N from &arkivlib..&thist c
                            group by  c.&thisv) b
                            where a.lib="&arkivlib" and upcase(a.table)="&thist" and upcase(a.varname)="&thisv";
                        insert into tablecounts select * from tmp1;
                        %end;

	%end;
run;
quit;
create table tabletest as
select a.lib as inlib, b.lib as arklib, a.table as intable, b.table as arktable, a.varname as invar, b.varname as arkbvar,
       a.value as inval, b.value as arkval, a.N as inN, b.N as arkN
	   from ( tablecounts where lib="&inlib" ) a outer join ( tablecounts where lib="&arkivlib" ) b
	   on a.table=b.table and a.varname=b.varname and a.value=b.value;
	   run;
	   quit;

%mend;

 libname raw "f:/Projekter/PDB00001220/FSEID00002177/outputdata" access=readonly;
 libname ark "v:/Projekter/FSEID00002177/BackupData/2020-03-02/" access=readonly;
%updatecheck(raw,ark);
/*
ods pdf file="&doclib/OpdateringsKontrol";
%let curdir=%sysfunc(pathname(&inlib));
%let arkivdir=%sysfunc(pathname(&arkivlib));
title "Kontrol dokument for &curdir sammenlignet med &arkivdir ";
proc tabulate data=tablecounts missing;
class table varname year;
var Nkey;
table table, varname, year*Nkey="N unique"*sum=""*f=8.0;
run;
ods pdf close;
%mend;
*/
