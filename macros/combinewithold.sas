/* log
   08.08.2017  JNK  Changed from ODBC to local storage when updating new files. Not tested.
*/

/* when testing the code, reduce table size */
*%let combmax = 1000;
%let combmax = max;

/* Macro: CombineWithOld

	creates 3 tables in work:
		OriginalNotInUse with the old data that is not longer in use, keeping rec_in and rec_out information
		OriginalInUse    the dataset currently in use, rec_out = &globalend
		New              the new updated dataset available through the ODBC connection

	OriginalInUse and New are merged,
		If variables are present in both tables, then nothing is changed (keep rec_in and rec_out)
		If variables only present in OriginalInUse, then column is discontinued by setting rec_out = &last_dataupdate - 1
		If variables only presnt in New, then rec_in = &last_dataupdate  and rec_out = &globalend

	project  = name of project on server, eg. PDB00001220
	lib      = place to store result, can be for testing (MasterRawCode/raw) or final (MasterData/raw)
	compby   = the list of compare variables (all variables in table)
	sortby   = could be a shorter list - e.g. just pnr
	oldsort  = if variable list has changed, the old tables must be compared with this list of variables
	mergeNew - local macrovariable showing that the variables has changed since last update.
   */

%macro testvar(lib,ds,vars);
	%local I nvar nnewvar this;
	proc sql;
		select upcase(name) into :exvarlist separated by ' '
		from dictionary.columns
		where libname="%upcase(&lib)" and memname="%upcase(&ds)"
		and memtype="DATA";
	quit;

	%let nvar=%sysfunc(countw(&vars));
	%let nnewvar=0;
	%let cmdstr=;
	%do i=1 %to &nvar;
		%let this=%upcase(%sysfunc(scan(&vars,&i)));
		%if %sysfunc(indexw(&exvarlist,&this))=0 %then %do;
			%let nnewvar=%eval(&nnewvar + 1);
			%put &this &nnewvar;
			%if %index(&this,C_)>0 or %sysfunc(indexw(&this,KOEN_BARN))>0 %then %let cmdstr= &cmdstr &this %str(='';);
			%else %let cmdstr=&cmdstr &this %str(=.;);
		%end;
	%end;
	%put &cmdstr;
%mend;


%macro CombineWithOld(project, lib, Name, compby=, sortby=, oldsort=, mergeNew=FALSE, yr=, orglib=rawdata, totallyraw=rbackup);

	%start_timer(entiremacro);
	%let newParms=TRUE;
	%local oldfound newfound;
	%if &compby=  %then %let compby=&sortby;;
	%if &oldsort= %then %let newParms=FALSE;
	%if &oldsort= %then %let oldsort = &compby;
	%if %symexist(GetDataWithODBC)=0 %then %do;
		%local GetDataWithODBC;
		%let GetDataWithODBC=FALSE;
	%end;

	%if %sysfunc(exist(&orglib..&Name.&yr)) %then %let oldfound=1;
	%if %sysfunc(exist(&totallyraw..&&Name.&yr)) %then %let newfound=1;


	/* Get the active part of the table in RAW and save a copy in work.original. Add the compareid to the temp table */
	%if &oldfound=1 and &newfound=1 %then %do;
		%start_timer(getold);
		%global cmdstr;
		%testvar(&orglib,&name.&yr,&oldsort);

		data work.OriginalInUse work.OriginalNotInUse;
			set &orglib..&Name.&yr  (obs=&combmax) ;
			&cmdstr;
			%makeid(compareid,&oldsort);
			if rec_out eq &globalend then output work.OriginalInUSe ;   /* origial dataset in use, compare with update and change rec_out accordingly. */
			else output work.OriginalNotInUse; /* original dataset, no changes (old dates) */
		%runquit;
		%end_timer(getold, text='storing old table in WORK, sorting into inUse and NotInUse');

		/* Get new version of the table from forskerdatabase, save in work.new */
		%start_timer(new);

		%if &GetDataWithODBC = TRUE %then %do;
			proc sql inobs=&combmax;
				connect to odbc as projdata (datasrc=forskerdatabase uid=fskFleSkj);
				create table new as
				select * from connection to projdata (select * from &project..&&Name.&yr);
				disconnect from projdata;
			%sqlquit;
			/* tjek log for warning hvis work.new er tom */
			%put sqlrc =&sqlrc;
			%if &sqlrc gt 0 %then %do; %put "stopped by error in ODBC connection"; quit; %end;
			data work.new;
				set work.new;
				%makeid(compareid,&oldsort);
			%runquit;	
			%end_timer(new, text='Getting new dataset with ODBC connection');
		%end;
		/* use the same merge macro when updating the individual projects - get new data from MasterData/raw and not ODBC */
		%if &GetDataWithODBC = FALSE  %then %do;
			data work.new; /* get new data from TotallyRaw. Only with rec_out = &globalend */
				set &totallyraw..&&Name.&yr  (obs=&combmax drop=rec_in rec_out) ; /* will be restored later in this macro */
				%makeid(compareid,&oldsort);
			%runquit;
			%end_timer(new, text='Adding compareid to work.new - table is already made in the local project');
		%end;

		/* create a compareid in the new table */

		/* tables must be sorted in order to do proper merge, remove duplicate-lines */
		proc sort data=work.OriginalInUse  nodupkey; /* noduplicates;*/
			by compareid /* %if &newParms=FALSE %then &sortby;;*/
		%runquit;
		proc sort data=work.new nodupkey ;/* noduplicates;*/
			by compareid /*%if &newParms=FALSE %then &sortby;; */
		%runquit;

		%macro remove_but_keep_code; /* can be reused somewhere else */
			/* compare tables by compareID, outputfile work.diffent only has unmatched compareid */
			%start_timer(compare);
			proc compare base=work.OriginalInUse
				compare=work.new outnoequal out = work.different noprint  outbase outcomp outdif;
				id compareid;
			%runquit;
			%end_timer(compare, text='compare dataset');
		%mend;


		/* merge the old tables with the new data */
		/* if new variables has been added that will not change the use of the old tables,
		then mergeNEW=TRUE and the new information is added to the active part of the table.
		If the new variables can not be added to the old version of the table, then mergeNEW=FALSE,
		then the entire old table will be marked obsolete, and rec_out set to &last_dataupdate-1 (in next step) */
		data work.newdata %if &mergeNew=FALSE %then work.oldobsolete;;
			merge work.new (in=a) work.OriginalInUse (in=b);
			by compareid;

			/* if the pnr is present in both active table and the new data, then do nothing (keep rec_in and rec_out). */
			if a and b then do;
				%if &mergeNew=FALSE %then %do; /* new additional parameters but no changes to old, add! */
					keep compareid;
					output work.oldobsolete;
				%end;
				/* else keep history */
			end;
			/* pnr only in the new data. No rec_in and rec_out history exist - set both */
			if a and not b then do;
				rec_out = &globalend;
				rec_in  = &last_dataupdate;
			end;
			/* pnr only in the active dataset but not in the new data. remove it by setting rec_out to &last_dataupdate -1 */
			if b and not a then do;
				rec_out = &last_dataupdate-1;
			end;
		%runquit;

		/* if there are changes to vital variable names, keep old data intact (set history) and start a new table with the new version */
		/* this equals an entire copy of the dataset in use */
		%if &mergeNew=FALSE %then %do;
			data work.old;
				merge work.OriginalInUse (in=a) work.oldobsolete (in = b);
				by compareid;

				if a and b;
				rec_out = &last_dataupdate-1;
			%runquit;

			data work.updnew;
				merge work.new (in=a) work.oldobsolete (in = b);
				by compareid;

				if a and b;
				rec_out = &globalend;
				rec_in = &last_dataupdate;
			%runquit;

				/* replace the previous version of work.newdata in order to continue after the if-sentence with the same naming */
			data work.newdata;
				set work.newdata work.old work.updnew;
				by compareid;
			%runquit;
		%end;

		/* combine the newdata with the table with old (not in use) history */
		data &lib..&Name.&yr;
			set work.newdata work.OriginalNotInUse;

			/* put in lib, combine new table with old, set rec_in and rec_out accordingly */
			format rec_in rec_out date.;
			*   drop  compareid  sp; /* remove the helpful variables */
			keep &sortby rec_in rec_out; /* remove all extras */
		%runquit;

		proc sort data=&lib..&Name.&yr nodupkey;
			by &sortby rec_in rec_out;
		%runquit;
	%end; /* if &oldfound=1 */

	%if &oldfound ne 1 and &newfound ne 1 and &GetDataWithODBC = TRUE %then %do;
		%start_timer(new);
		proc sql inobs=&combmax;
			connect to odbc as projdata (datasrc=forskerdatabase uid=fskFleSkj);
			create table &totallyraw..&&Name.&yr as
			select * from connection to projdata (select * from &project..&&Name.&yr);
			disconnect from projdata;
		%sqlquit;
		/* tjek log for warning hvis work.new er tom */
		%put sqlrc =&sqlrc;
		%if &sqlrc gt 0 %then %do; %put "stopped by error in ODBC connection"; quit; %end;
		%let newfound=1;
		%end_timer(new, text='Getting new dataset with ODBC connection');
	%end;

	%if &oldfound ne 1 and &newfound=1 %then %do;
		data &lib..&Name.&yr;
			set &totallyraw..&&Name.&yr;
			rec_out = &globalend;
			rec_in = &last_dataupdate;

			/* put in lib, combine new table with old, set rec_in and rec_out accordingly */
			format rec_in rec_out date.;
			keep &sortby rec_in rec_out; /* remove all extras */
		%runquit;

		proc sort data=&lib..&Name.&yr nodupkey;
			by &sortby rec_in rec_out;
		%runquit;

	%end;

	%end_timer(entiremacro, text='combine with old, entire macro');
%mend;


%macro getTables(lib, project, name, compby, startyr, endyr, sortby, void, void2, oldsort=, mergenew=, NewFromYear=., orglib=rawdata, totallyraw=rbackup );
	/* løkke fra startyr til slutyr */
	%local M;

	%if &newfromyear ne . %then %let startyr = %SYSFUNC(max(&startyr,&newfromyear));; /* update only from newfromyear, no matter what the table in data_variables says */

	%if &startyr=0 %then %do;
		%CombineWithOld(&project, &lib, &name, compby=&compby, sortby=&sortby, oldsort=&oldsort, mergeNew=&mergeNew, orglib=&orglib, totallyraw=&totallyraw);
	%end;
	%else %do;
		%do M=&startyr %to &endyr;
			%CombineWithOld(&project, &lib, &name, compby=&compby, sortby=&sortby, oldsort=&oldsort, mergeNew=&mergeNew, yr=&M, orglib=&orglib, totallyraw=&totallyraw);
		%end;
	%end;
%mend;

%macro CombineTables(lib, prefix, nof, project=&DefaultProject, NewFromYear=., orglib=rawdata, totallyraw=rbackup);
	%local I;


	%start_log(&currentpath/log, &prefix);
	%header(path=&localpath, ajour=&last_dataupdate, dataset=&prefix, initials=JNK, reason=Update RAW data);

	%start_timer(startcombinetime);
	%if &nof %then %do;
		%do I=1 %to &nof; /* loop amount of tables */
			%put Invoke GetTables on &prefix table &I: &&&prefix._table&I;
			%GetTables(&lib, &project, &&&prefix._table&I, NewFromYear=&NewFromYear, orglib=&orglib, totallyraw=&totallyraw);
		%end;
	%end;
	%else %do;
		%GetTables(&lib, &project,  &&&prefix, NewFromYear=&NewFromYear, orglib=&orglib, totallyraw=&totallyraw); /* get only one table - typically for test purpose */
	%end;

	%end_timer(startcombinetime, text=execution time merging all tables with previous version);
	%end_log;
%mend;


%macro testcomparwithoriginal;
	proc compare base = raworg.cpr3_t_person
		compare=rawdata.cpr3_t_person outnoequal out = work.orgcompnew noprint   outbase outcomp /* outdif*/;
		by v_pnr_encrypted v_mor_pnr_encrypted v_far_pnr_encrypted c_kon c_status;
	%runquit;

	proc compare base = raworg.cpr3_t_person
		compare=work.new outnoequal out = work.orgnew noprint   outbase outcomp /* outdif*/;
		by v_pnr_encrypted v_mor_pnr_encrypted v_far_pnr_encrypted c_kon c_status;
	%runquit;

	proc datasets library= work nolist;
		contents data=OriginalInUse out=newout;
		title 'contents of original';
	run;
%mend;
