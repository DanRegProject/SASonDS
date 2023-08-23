/* SVN header
$Date: 2020-09-24 09:40:55 +0200 (to, 24 sep 2020) $
$Revision: 245 $
$Author: fflb6683 $
$Id: mergeMedi.sas 245 2020-09-24 07:40:55Z fflb6683 $
*/
/*
  #+NAME
    %mergeMedi
  #+TYPE
    SAS
  #+DESCRIPTION
    Repeatedly calling %prereduceMediStatus for a list of diagnoses and merge on
    study dataset. Input material to %reducerFA3 may be restricted by
    optional parameters.
    The macro is called outside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %mergeMedi(
      basedata,  Input data set from %getMedi
      inlib,     Libname with diagnose (ALL) datasets
      outlib,    Libname where output from %reduceMedi is stored
      IndexDate, Event date variable from basedata
      sets,      Diagnoses, list refering to standard names
      ajour=,    optional
  );
  #+OUTPUT
    Output dataset from %reduceMedi is merged to basedata.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
  Date    Initials  Status
  21-01-2013  FLS   Macro added
  03-07-2014  FLS   Check added if &IndexDate variable exist in ALL datasets
              JNK   Cleanup stuff
  18-08-2015  FLS   retain fdiag corrected to retain fatch
  18-09-2020  MJE	handle table prefix
*/
%MACRO mergeMedi(basedata,inlib,outlib,IndexDate,sets, ajour=today(), postfix=);
  %put start mergeMedi: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour);
  %local medidat nsets i var;
  %let medidat=%NewDatasetName(medidattmp); /* temporært datasætnavn så data i work ikke overskrives */
  %let nsets =  %sysfunc(countw(&sets));


  %if &nsets gt 2 %then %do; /* reduce list if greater than 2 */
    %nonrep(mvar=sets, outvar=newsets);
    %let sets = &newsets; /* replace sets with newsets */
    %let nsets=%sysfunc(countw(&newsets)); /* recount */
  %end;
  %do i=1 %to &nsets;
    %LET var=%sysfunc(compress(%qscan(&sets,&i)));
    proc sql;
      create table &medidat as
        select a.*, b.&IndexDate.
        from &inlib..LMDB&var.ALL a,
        &basedata b
        where a.pnr=b.pnr and &ajour between rec_in and rec_out
        order by pnr, &IndexDate, eksd;
        /* klargør til at lave en fra/til liste over atc numre */
      create table test as
        select &var, count(pnr) as N from &medidat
        group by &var
        order by N;
      %RunQuit;
      data _null_;
        set test end=end;
        retain fatc;
        if _N_=1 and end then call symput("atc",substr(&var,1,4));
        else do;
          if _N_=1 then  fatc=&var;
          if end then call symput("atc",compress(cat(substr(&var,1,4),"-",substr(fatc,1,4))));
        end;
      %RunQuit;
	  %prereduceMediStatus(&medidat, &outlib..LMDB&var&postfix&IndexDate, &var&postfix, &atc, &IndexDate, ajour=&ajour);
    %END;
    proc sort data=&basedata;
      by pnr &IndexDate;
    run;
    data &basedata;
      merge &basedata(in=A)
      %do i=1 %to &nsets;
        %LET var=%sysfunc(compress(%qscan(&sets,&i)));
		&outlib..LMDB&var&postfix&Indexdate
      %END;
    ;
    by pnr &IndexDate;
    if A;
  %RunQuit;
  %cleanup(&medidat); /*26-06-15 oprydning */
%MEND;
