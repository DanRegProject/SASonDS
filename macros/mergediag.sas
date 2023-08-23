/* SVN header
$Date: 2020-09-24 09:40:47 +0200 (to, 24 sep 2020) $
$Revision: 244 $
$Author: fflb6683 $
$Id: mergeDiag.sas 244 2020-09-24 07:40:47Z fflb6683 $
*/
/*
  #+NAME
    %mergeDiag
  #+TYPE
    SAS
  #+DESCRIPTION
    Repeatedly calling %reduceDiag for a list of diagnoses and merge on
    study dataset. Input material to %reduceDiag may be restricted by
    optional parameters.
    The macro is called outside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %mergeLPR(
      basedata,  Input data set, see %reducerFC
      inlib,   Libname with diagnose (ALL) datasets
      outlib,  Libname where output from %reducerFC is stored
      IndexDate,  Event date variable, see %reducerFC
      sets,    Diagnoses, list refering to standard names
      subset=,   Restrict type of diagnoses to include, optional
      postfix=,  String to add to diagnose string, keep short!, optional
      hosp=    Dataset, with hospitalisation periods, as
                output from %smoother(), diagnoses optained
              within hospitalisation period of IndexDate are ignored. Optional
  );
  See t017../code/makedata.sas for an example.
  #+OUTPUT
    Output dataset from %reducerFC is merged to basedata.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
  Date    Initials  Status
  21-01-13  FLS     Macro added
  03-07-14  FLS     Check added if &IndexDate variable exist in ALL datasets
  08-12-14  FLS     %RunQuit; after proc sql changed to quit; to avoid premature stop.
  20-05-15  FLS     Changed to SQL for added functionality
  31-07-15  JNK     Updated to hist version.
  18-08-15  FLS     Subset moved from dataset option to where statement in data step.
  12.09.16  JNK     Renamed to mergeDiag and renamed basedate to IndexDate
  18.09.20	MJE		handle table prefix

*/
%MACRO mergeDiag(basedata,inlib,outlib,IndexDate,sets,subset=,postfix=,hosp=, ajour=today());
  %put start mergeDiag: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour;
  %local I nsets var;
  %local lprdat;
  %put start mergeLPR: %qsysfunc(datetime(), datetime20.3), udtræksdato = &ajour;
  %let lprdat=%NewDatasetName(lprdattmp); /* fls 26-06-15 tilføjet temporært datasætnavn så data i work ikke overskrives */;
  %local lprhosp;
  %let lprhosp=%NewDatasetName(lprhosptmp); /* temporært datasætnavn så data i work ikke overskrives */
  %LET nsets=%sysfunc(countw(&sets));
  %if &nsets gt 2 %then %do; /* reduce list */
    %nonrep(mvar=sets, outvar=newsets);
    %let sets = &newsets;
    %let nsets = %sysfunc(countw(&newsets));
  %end;


  %do i=1 %to &nsets;
    %LET var=%sysfunc(compress(%qscan(&sets,&i)));
    data &lprdat; /* fls 26-06-15 istedet for &var.ALL */;
      set &inlib..LPR&var.ALL ;
      where &ajour between rec_in and rec_out
      %IF %isBlank(%superq(subset))=0 %THEN and &subset;
      ;
    %RunQuit;
    %if %isBlank(%superq(hosp))=0  %THEN %DO; /* dette sikrer at udskrivningsdato fremskrives til endelig udskrivning for indlæggelser; diagnose datoen (IndexDate) ændres ikke */
      proc sql;
        create table &lprhosp as
      	select a.*, b.hosp_in label="first day at hospital", b.hosp_out label="last day at hospital", b.hospdays label="number of days at hospital"/* jnk added for Mette */
        from &lprdat a left join &hosp b
        on a.pnr=b.pnr
        where (a.indate<b.hosp_in or a.indate>b.hosp_out or b.hosp_out=.)
        order by pnr, indate;
      %sqlQuit;
	    data &lprdat;
	      set &lprhosp;
        if pattype in (0,1) then outdate=hosp_out;
        drop hosp_in hosp_out;
    	%runquit;
    %end;
    %reduceDiag(&lprdat, &outlib..LPR&var&postfix&Indexdate, &var&postfix, &IndexDate, basedata=&basedata, ajour=&ajour);
  %end;
      proc sort data=&basedata;
        by pnr &IndexDate;
      run;
      data &basedata;
        merge &basedata(in=A)
        %do i=1 %to &nsets;
          %LET var=%sysfunc(compress(%qscan(&sets,&i)));
   	     &outlib..LPR&var&postfix&Indexdate
          %END;
        ;
   by pnr &IndexDate;
   if A;
   %RunQuit;
   %cleanup(&lprdat);
%if %isBlank(%superq(hosp))=0 %then %do; /* utestet med hosp! */
proc sql;
  create table &lprhosp as
    select a.*, b.hosp_in, b.hosp_out, b.hospdays
    from &basedata a left join &hosp b on
    a.pnr=b.pnr
    and &indexDate between b.hosp_in and b.hosp_out
    order by pnr, &indexDate;
data &basedata;
    set &lprhosp;
  %runquit;
  %cleanup(&lprhosp);

%end;
%mend;
