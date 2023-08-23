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
%macro cleanup(sets);
    proc datasets nolist;
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
** ref: communities.sas.com/message/154973;
%macro varexist(ds /* dataset name */, var /* variable name */);
    /*------------------------
    check for the existence of a specified variable.
    Usage: %if %varexist(&data,NAME) %then %put% input dataset contains variable 'NAME';
    The macro calls resolves to 0 when either the dataset does not exist or the variable is not
        in the specified dataset.
        -------------------------*/
    %LOCAL dsid rc;
    /*---------------------
        use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.
        -------------------------*/
    %LET dsid = %SYSFUNC(OPEN(&ds));
    %IF (&dsid) %THEN %DO;
        %IF %SYSFUNC(VARNUM(&dsid,&var)) %THEN 1;
        %ELSE 0;
        %LET rc = %SYSFUNC(CLOSE(&dsid));
    %END;
    %ELSE 0;
%MEND varexist;
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

