/* SVN header
$Date: 2021-01-13 15:25:51 +0100 (on, 13 jan 2021) $
$Revision: 259 $
$Author: wnm6683 $
$Id: mergeOPR.sas 259 2021-01-13 14:25:51Z wnm6683 $
*/
/*
  #+NAME
    %mergeOPR
  #+TYPE
    SAS
  #+DESCRIPTION
    Repeatedly calling %reducerFO for a list of operations and merge on study dataset.
    The macro is called outside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %mergeOPR(
      basedata, Input data set, see %reducerFC
      inlib,  Libname with diagnose (ALL) datasets
      outlib, Libname where output from %reducerFC is stored
      IndexDate, Event date variable, see %reducerFC
      sets    Diagnoses, list refering to standard names
      ajour=  Defaults to today, set to date of dataset.
    );
  See t017../code/makedata.sas for an example.
  #+OUTPUT
    Output dataset from %reducerFO is merged to basedata.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials  Status
    21-01-13  FLS     Macro added
    03-07-14  FLS     Check added if &IndexDate variable exist in ALL datasets
    03-08-15  JNK     Added ajour (hist-option)
    18-08-15    FLS                     Recoded to enable the use of multiple IndexDate within pnr
	18-09-20	MJE		handle table prefix
      */
%MACRO mergeOPR(basedata,inlib,outlib,IndexDate,sets,ajour=today(), postfix=);
  %put start mergeOPR: %qsysfunc(datetime(), datetime20.3), udtræksdato = &ajour;
  %local oprdat nsets i var;
  %let oprdat=%NewDatasetName(oprdattmp); /* fls 26-06-15 tilføjet temporært datasætnavn så data i work ikke overskrives */;
  %LET nsets=%sysfunc(countw(&sets)); /* count number of sets */

  %let tabletypes = opr ube;
  %let ntype = %sysfunc(countw(&tabletypes));
  %if &nsets > 1 %then %do;
    %nonrep(mvar=sets, outvar= newsets); /* check for dublets */
    %let nsets = %sysfunc(countw(&newsets)); /* replace with new string and new count */
    %let sets = &newsets;
  %end;
  %do j = 1 %to &ntype;
   %do i=1 %to &nsets;
    %LET var=%sysfunc(compress(%qscan(&sets,&i)));
	%let tabletype = %sysfunc(compress(%qscan(&tabletypes,&j)));

	%let runtype = 0;
	%if %sysfunc(exist(&inlib..&tabletype.&var.all)) eq 1 %then %let runtype = 1;

	%if &runtype eq 1 %then %do;
    proc sql;
      create table &oprdat as
        select a.*, b.&IndexDate
        from &inlib..&tabletype.&var.ALL /*(drop=
      %if %varexist(&inlib..&var.ALL,&IndexDate)=1 %then &IndexDate; %else &IndexDate; afterbase)*/ a,
        &basedata b
        where a.pnr=b.pnr and &ajour between rec_in and rec_out
        order by pnr, &IndexDate, oprdate;
      %SqlQuit;
	    %reduceOpr(&oprdat, &outlib..&tabletype.&var&postfix&Indexdate, &var&postfix, &IndexDate, ajour=&ajour);
	%end;
  %END;
%end;
    proc sort data=&basedata;
      by pnr &IndexDate;
    run;
  data &basedata;
    merge &basedata(in=A)
   %do j = 1 %to &ntype;
    %do i=1 %to &nsets;
		%let runtype = 0;
      %LET var=%sysfunc(compress(%qscan(&sets,&i)));
	  %let tabletype = %sysfunc(compress(%qscan(&tabletypes,&j)));

	  %if %sysfunc(exist(&inlib..&tabletype.&var.all)) eq 1 %then %let runtype = 1;

	  %if &runtype eq 1 %then %do;
      &outlib..&tabletype.&var&postfix&IndexDate
	  %end;
    %END;
   %end;
    ;
    by pnr &IndexDate;
    if A;
  %RunQuit;
  %cleanup(&oprdat);
%MEND;
