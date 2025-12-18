/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: getDiag.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
/*
   #+CHANGELOG
    Date    Initials  Status

*/

%macro GetSocio(outlib, Sociolist, Civilstatus=("9" "D" "E" "F" "G" "L" "O" "P" "U"), indata=,handlemissing=);
%local N fromyear toyear nsets minyear maxyear year socio inlib fromdata;

%sociotjek(&Sociolist);

%let fromyear = 1986;
%let toyear = %sysfunc(year(%sysfunc(&ProjectEnd)));
%let nsets = %sysfunc(countw(&Sociolist));
/* if there are repeats in the varlist (not likely with so few variabels) */
%if &nsets > 1 %then %do;
	%nonrep(mvar=Sociolist, outvar=newSociolist);
    %let nsets = %sysfunc(countw(&newSociolist));
    %let Sociolist = &newSociolist;
%end;
/* create table famidall with pnr familie_id and year from fromyear to toyear */
proc datasets lib=work nolist;
	delete famid:;
	quit;
run;

%let minyear = %sysfunc(max(&fromyear, 1980	));
%let maxyear = %sysfunc(min(&toyear,&lastbef));
%do year=&minyear %to &maxyear;


	proc sql;
		create table work.famid&year as
			select A.pnr,
					B.familie_id,
					&year as year
			from &indata as A
			left join master.bef&year as B
			on A.pnr = B.pnr;
		quit;
%end;

data famidall;
set Famid:;
run;

proc sort data=famidall out = famidall;
by pnr year;
run;

/*loop over Sociolist to get all needed variabels*/

%do N=1 %to &nsets;
	%let Socio = %lowcase(%scan(&Sociolist, &N));
	%if &Socio = civilst %then %do;
		%let fromdata = Bef;
		%let inlib = master;
	%end;
	%if &Socio = famindkom %then %do;
		%let fromdata = Faik;
		%let inlib = master;
	%end;
	%if &Socio = udd %then %do;
		%let fromdata = Udda;
		%let inlib = master;
	%end;
	%if &Socio = socialst %then %do;
		%let fromdata = Indh;
		%let inlib = master;
	%end;

	%FindSocio(civilstatus=&Civilstatus,fromyear=&fromyear,toyear=&toyear,inlib=&inlib,fromdata=&fromdata,handlemissing=&handlemissing);

%end;
%mend;


%macro FindSocio(civilstatus=,fromyear=,toyear=,inlib=,fromdata=,handlemissing=);

%if %lowcase(&fromdata)=faik 	%then %FindFamIndkom(	fromyear=&fromyear,	toyear=&toyear,	inlib=&inlib,	outlib=mydata,handlemissing=&handlemissing);
%if %lowcase(&fromdata)=bef 	%then %Findcivilst(		fromyear=&fromyear,	toyear=&toyear,	inlib=&inlib,	outlib=mydata,	civilstatus=&civilstatus,handlemissing=&handlemissing);
%if %lowcase(&fromdata)=indh 	%then %FindStatus(		fromyear=&fromyear,	toyear=&toyear,	inlib=&inlib,	outlib=mydata,handlemissing=&handlemissing);
%if %lowcase(&fromdata)=udda 	%then %FindUdd(			fromyear=&fromyear,	toyear=&toyear,	inlib=&inlib,	outlib=mydata,handlemissing=&handlemissing);

%mend;



%macro Findcivilst(civilStatus=("9" "D" "E" "F" "G" "L" "O" "P" "U"),fromyear=,toyear=,inlib=,outlib=,handlemissing=);
%local minyear maxyear year;
%let minyear = %sysfunc(max(&fromyear, 	1980));
%let maxyear = %sysfunc(min(&toyear,&lastbef));

proc datasets lib=work nolist;
delete _civilst:;
quit;
run;

%do year=&minyear %to &maxyear;
	proc sql;
			create table work._civilst&year as
				select A.pnr,
						B.civst as civilst,
						B.civdato as civilstdate,
						rec_in,
						rec_out,
						&year as year,
						B.datavaliduntil
				from famidall as A
				left join &inlib..Bef&year as B
				on A.pnr = B.pnr
				where A.year = &year and B.civst in &civilStatus;
			quit;
	%end;
run;

data civilstall;
set _civilst:;
run;

proc sort data=civilstall out = civilstall;
by pnr year;
run;

%if &handlemissing eq lastknown %then %do;
	%put "doing lastknown";
	%lastknown(civilstall,civilst,pnr);
	%lastknown(civilstall,civilstdate,pnr);
	%lastknown(civilstall,rec_in,pnr);
	%lastknown(civilstall,rec_out,pnr);
	%lastknown(civilstall,DataValidUntil,pnr);
%end;


proc sort data = civilstall out = &outlib..SOCcivilstall NODUP;
by pnr year;
run;

%mend;



%macro FindFamIndkom(fromyear=2002,toyear=,inlib=,outlib=,handlemissing=);
%local minyear maxyear year;
%let minyear = %sysfunc(max(&fromyear, 	2002));
%let maxyear = %sysfunc(min(&toyear,&lastfaik));

proc datasets lib=work nolist;
delete _famindkom:;
quit;
run;

%do year=&minyear %to &maxyear;
proc sql;
	create table _famindkom&year as
		select 	A.pnr,
				A.familie_id,
				B.farmaekvivaindknetto as famindkom,
				&year as year,
				B.rec_in,
				B.rec_out,
				B.datavaliduntil
		from work.famidall as A
		left join &inlib..faik&year as B
		on A.familie_id = B.familie_id
		where A.year = &year;
	quit;
	run;
%end;

data famindkomall;
set _famindkom:;
run;

proc sort data=famindkomall out = famindkomall;
by familie_id year;
run;

%if &handlemissing eq lastknown %then %do;
	%put "doing lastknown";
	%lastknown(famindkomall,familie_id,pnr);
	%lastknown(famindkomall,famindkom,familie_id);
	%lastknown(famindkomall,rec_in,familie_id);
	%lastknown(famindkomall,rec_out,familie_id);
	%lastknown(famindkomall,DataValidUntil,familie_id);
%end;


proc sort data = famindkomall out = &outlib..SOCfamindkomall NODUP;
by pnr year;
run;
%mend;


%macro FindUdd(fromyear=,toyear=,inlib=,outlib=,handlemissing=);
%local minyear maxyear year;
%let minyear = %sysfunc(max(&fromyear, 	1997));
%let maxyear = %sysfunc(min(&toyear,&lastudda));

proc datasets lib=work nolist;
delete _udd:;
quit;
run;

%do year=&minyear %to &maxyear;
proc sql;
	create table _udd&year as
		select A.pnr,
				B.hf_kilde as uddkilde,
				B.hfaudd as udd,
				&year as year,
				B.rec_in,
				B.rec_out,
				B.datavaliduntil
		from work.famidall as A
		left join &inlib..udda&year as B
		on A.pnr = B.pnr
		where A.year = &year;
	quit;
%end;
run;

data uddall;
set _udd:;
run;

proc sort data=uddall out = uddall;
by pnr year;
run;

%if &handlemissing eq lastknown %then %do;
	%put "doing lastknown";
	%lastknown(uddall,uddkilde,pnr);
	%lastknown(uddall,udd,pnr);
	%lastknown(uddall,rec_in,pnr);
	%lastknown(uddall,rec_out,pnr);
	%lastknown(uddall,DataValidUntil,pnr);
%end;


proc sort data = uddall out = &outlib..SOCuddall NODUP;
by pnr year;
run;
%mend;


%macro FindStatus(fromyear=,toyear=,inlib=,outlib=,handlemissing=);
%local minyear maxyear year;
%let minyear = %sysfunc(max(&fromyear, 	2002));
%let maxyear = %sysfunc(min(&toyear,&lastindh));

proc datasets lib=work nolist;
delete _status:;
quit;
run;

%do year=&minyear %to &maxyear;

%if &year > 2013 %then %do;
	%let tablename 	= akm;
	%let varname 	= socio13;
	%let pre 		= 13;
%end;
%else %do;
	%let tablename 	= indh;
	%let varname 	= socio02;
	%let pre 		= 02;
%end;

proc sql;
	create table _status&year as
		select A.pnr,
				B.&varname as socialst&pre,
				&year as year,
				B.rec_in,
				B.rec_out,
				B.datavaliduntil
		from work.famidall as A
		left join &inlib..&tablename&year as B
		on A.pnr = B.pnr
		where A.year = &year;
	quit;
%end;
run;

data socialstall;
set _status:;
run;

proc sort data=socialstall out = socialstall;
by pnr year;
run;

%if &handlemissing eq lastknown %then %do;
	%put "doing lastknown";

	%lastknown(socialstall,socialst02,pnr);
	%lastknown(socialstall,socialst13,pnr);
	%lastknown(socialstall,rec_in,pnr);
	%lastknown(socialstall,rec_out,pnr);
	%lastknown(socialstall,DataValidUntil,pnr);
%end;


proc sort data = socialstall out = &outlib..SOCsocialstall NODUP;
by pnr year;
run;
%mend;




%macro lastknown(dataset,variable,by);
	proc sort data= &dataset  out = &dataset;
	by &by year;
	run;

	data &dataset;
		set &dataset;
		by &by;
		retain help;
		if not missing(&variable) then help = &variable;
		else &variable = help;
		if last.pnr then help = .;
		drop help;
	run;
%mend;


%macro sociotjek(list);
%local N t socio var;
    %let N = %sysfunc(countw(&list," "));
%do t=1 %to &N;
	%let socio = %sysfunc(scan(&list,&t));
	%if &socio ne civilst and &socio ne famindkom and &socio ne socialst and &socio ne udd %then %let var = 1;
	%else %let var = 0;
	%if &var eq 1 %then %put ERROR: &socio not in ( civilst famindkom socialst udd );
%end;
%mend;
