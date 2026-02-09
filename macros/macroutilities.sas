/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: macroUtilities.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/* start and stop calculation of execution time */
%macro start_timer(name);
  %if &create_timelog=TRUE %then %do;
    %global st&name;
  	%let st&name = %qsysfunc(datetime()); /* store starttime in a global macrovariable */
	  /* simple timestamp in log */
	  %put start &name %sysfunc(today(),date.) %sysfunc(time(),time.);
  %end;
%mend;
%macro end_timer(name, text=); /* optional text when writing result in log */
  %if &create_timelog=TRUE %then %do;
    data _null_; /* calculate time */
      end&name = datetime(); /* store current time */
      diff&name=end&name-&&st&name; /* calculate difference from starttime to now */
      put "execution time &TEXT  "  diff&name:time20.6;
    %runquit;
  %end;
%mend;
/* start and stop log */
%macro start_log(path, name, option=new); /* replace option=new with option= if log is to be appended to old */
  %if &create_log=TRUE %then %do;
    proc printto log="&path/&name..log" print="&path/&name..log" &option;    run;
  %end;
%mend;
%macro end_log;
  %if &create_log=TRUE %then %do;
    proc printto;
    run;
  %end;
%mend;
%macro quotelst(str, quote=%str(%"),delim=%str( ));
    /*
    / Author : Roland Rashleigh-Berry
    / Date   : 04-MAy-2011
    */
    %local i quotelst;
    %let i=1;
    %do %while(%length(%qscan(&str,&i,%str( ))) GT 0);
        %if %length(&quotelst) EQ 0 %then %let quotelst = &quote.%qscan(&str,&i,%str( ))&quote;
        %else %let quotelst=&quotelst.&quote.%qscan(&str,&i,%str( ))&quote;
        %let i=%eval(&i + 1);
        %if %length(%qscan(&str,&i,%str( ))) GT 0 %then %let quotelst=&quotelst.&delim;
        %end;
    %unquote(&quotelst)
%mend; /* quotelst */
%macro commas(str);
    /*
    / Author : Roland Rashleigh-Berry
    / Date   : 04-MAy-2011
    Convert a string of words to a string of comma separated words
    */
    %quotelst(&str,quote=%str(),delim=%str(, ))
%mend; /* commas */
%macro NewDatasetName(proposalname);
    %local i newdatasetname;
    %let proposalname=%sysfunc(compress(&proposalname));
    %let newdatasetname=_&proposalname;
    %do %while(%sysfunc(exist(&newdatasetname)));
        %let i=%eval(&i+1);
        %let newdatasetname=_&proposalname&i;
        %end;
    &newdatasetname
    %mend;
%macro cleanup(sets,lib=work);
    proc datasets nolist lib=&lib;
        delete &sets;
    run;
    quit;
    %mend;
** %isBlank();
** ref: chanchung.com/download/022-2009.pdf paper022-2009 SAS Global Forum;
**      Is this macro blank? ;
** Usage %isBlank(var) hvor var er macrovariabel (angives uden &);
** hvis var er en parameter i en macro funktion så bruges den som %isBlank(%superq(var)) ;
%macro isBlank(param);
  %sysevalf(%superq(param)=,boolean)
%mend;
** %RunQuit;
** ref: analytics.ncsu.edu/sesug/2010/CC07.Blanchette.pdf;
/** Usage %RunQuit; anvendes istedet for RUN; eller QUIT; stopper efterfølgende kørsel af SAS steps;
*/
%macro RunQuit;
  ;
  run;
  quit;
  %if &syserr. ne 0 %then %do;
    %abort cancel;
  %end;
%mend ;
%macro varexist
/*----------------------------------------------------------------------
Check for the existence of a specified variable.
----------------------------------------------------------------------*/
(ds        /* Data set name */
,var       /* Variable name */
,info      /* LEN = length of variable */
           /* FMT = format of variable */
           /* INFMT = informat of variable */
           /* LABEL = label of variable */
           /* NAME = name in case as stored in dataset */
           /* TYPE  = type of variable (N or C) */
/* Default is to return the variable number  */
);

/*----------------------------------------------------------------------
This code was developed by HOFFMAN CONSULTING as part of a FREEWARE
macro tool set. Its use is restricted to current and former clients of
HOFFMAN CONSULTING as well as other professional colleagues. Questions
and suggestions may be sent to TRHoffman@sprynet.com.
-----------------------------------------------------------------------
Usage:

%if %varexist(&data,NAME)
 %then %put input data set contains variable NAME;

%put Variable &column in &data has type %varexist(&data,&column,type);
------------------------------------------------------------------------
Notes:

The macro calls resolves to 0 when either the data set does not exist
or the variable is not in the specified data set. Invalid values for
the INFO parameter returns a SAS ERROR message.
-----------------------------------------------------------------------
History:

12DEC98 TRHoffman Creation
28NOV99 TRHoffman Added info parameter (thanks Paulette Staum).
----------------------------------------------------------------------*/
%local dsid rc varnum;

%*----------------------------------------------------------------------
Use the SYSFUNC macro to execute the SCL OPEN, VARNUM,
other variable information and CLOSE functions.
-----------------------------------------------------------------------;
%let dsid = %sysfunc(open(&ds));

%if (&dsid) %then %do;
  %let varnum = %sysfunc(varnum(&dsid,&var));

  %if (&varnum) & %length(&info) %then
    %sysfunc(var&info(&dsid,&varnum))
  ;
  %else
    &varnum
  ;

  %let rc = %sysfunc(close(&dsid));
%end;

%else 0;

%mend varexist;
/*
In datastep utility to calculate days since startdate for a bunch of endpoints
*/
%macro calcdays(sets,basedate,EndDateStr=EndDate,EndDayStr=EndDay);
    %do i=1 %to %sysfunc(countw(&sets));
        %let var=%sysfunc(compress(%qscan(&sets,&i)));
        &var.&EndDayStr=&var.&EndDateStr-&basedate;
        %end;
    %mend;
/* stop exekvering hvis fejl i sql koden. */
%macro sqlquit;
  ;quit;
  %if &sqlrc gt 0 %then %do;
    %put ERROR: Proc SQL failed, execution stopped!;
    %abort cancel;
  %end;
%mend;
%MACRO _doindex(data,idx,idxlist);
  proc sql;
    create index &idx on &data (%commas(&idxlist));
  quit;
%MEND;
%MACRO doIndex(data,idx,idxlist,st="",sl="");
%LOCAL I;
  %IF &st="" %THEN %DO;
    %_doindex(&data,&idx,&idxlist);
  %END;
  %ELSE %DO;
    %DO I= &st %TO &sl;
      %_doindex(&data&I,&idx,&idxlist);
    %END;
  %END;
%MEND;
%MACRO doIndexlist(data,idx,st="",sl="");
    %LOCAL I x nidx;
  %LET nidx=%sysfunc(countw(&idx));
  %IF &st="" %THEN %DO;
    %do x=1 %to &nidx;
      %LET index=%sysfunc(compress(%qscan(&idx,&x)));
      %_doindex(&data,&index,&index);
  %end;
  %END;
  %ELSE %DO;
    %DO I= &st %TO &sl;
      %do x=1 %to &nidx;
        %LET index=%sysfunc(compress(%qscan(&idx,&x)));
        %_doindex(&data&I,&index,&index);
      %END;
    %END;
  %end;
%MEND;
%macro clear_all_old_indexes(st, sl, lib, name);
%local I;
  %do I=&st %to &sl;
  proc datasets library=&lib;
    modify &name&I;
    index delete _all_;
  run;
  %end;
%mend;

/* create a macrovariable with all the names of variables in the dataset */
%macro getDatasetVarNames(dsn, liste, var1=, var2=);
  proc contents data=&dsn
    out = vars(keep = varnum name)  order = varnum
	noprint;
  %runquit;
  proc sql noprint;
    select NAME
	into :orderedvars separated by ' '
	from vars
	order by varnum;
  %sqlquit;
  %put %lowcase(&orderedvars);
  %let &liste = %lowcase(&orderedvars);
%mend;

