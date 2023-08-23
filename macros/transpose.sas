/* SVN header
$Date:  $
$Revision:  $
$Author: $
$Id:  $
*/
/* SORT_after_INDEXDATE
   sort the input dataaccording to indexdate
   input table is xxx including idate
   var      : variable name
   years_before : number of included years before indexdate
   years_after  : number of included years after indexdate
   keeplist     : variables to be keept beside pnr &indexdate AfIdate BeIdate &varname and &varname._dato
   no           : add &no to varname
   output       : table with the variables listed under keeplist. AfIdate and BeIdate are created for next step */
%macro sort_after_indexdate(output, input, indexdate, varname, years_before, years_after, keeplist, no=);
  data &output;
    set &input;
	by pnr &indexdate;
	if &varname ne .; /* exclude lines with no dates */
    /* keep only lines within the interval: years_before idate an years_after idate */
    if (&varname >= (&indexdate-&years_before*&YearInDays) and &varname <= (&indexdate + &years_after*&YearInDays));
	/* sort in before and after */
    if &varname <= &indexdate then beIdate = &varname;
    format beIdate date.;
    if &varname > &indexdate then AfIdate = &varname;
    format AfIdate date.;
	keep pnr &indexdate beIdate AfIdate &varname &keeplist;
  %runquit;
   /* sorter tabellen */
  proc sort data=&output noduplicates out=sorted;
    by pnr &indexdate AFIdate descending BeIdate;
  %runquit;
%mend;
/*
  output    = name of output table
  input     = name of input table, must include AfIdate and BeIdage and sorted according to indexdate, use SORTED from %sortafteridate
  varname   = variable to store in array
  nofbefore = how many years back in time
  nofafter  = how many years in the future
  varswitch = the variable to compare with optionsx
  nofvarsw  = how many variables to compare
  indexdate = idate
  optionX   = specify the options (variables)
  addvar1   = special case, eg. a variable containing txt information to be stored
  addvar1sw = switch
  var       = short name used when combining horrible amounts of variables */
  %macro transpose(output, input, varname, nofbefore, nofafter, varswitch, nofvarsw, indexdate,
                        option1=, option1sw=, option2=, option2sw=,
                        option3=, option3sw=, option4=, option4sw=,
                        option5=, option5sw=, option6=, option6sw=,
                        option7=, option7sw=, option8=, option8sw=,
                        option9=, option9sw=, option10=, option10sw=,
						addvar1=, addvar1sw=, /* add extra information */
                                                var= /* short name used for combining a new variable name */);
      %local M I;
  data &output;
    set &input end=last;
	by pnr &indexdate AfIdate /* decending -  BeIdate */;
	%if &var ne %then %let &var = &varname;;
	/* configure at programstart _N_ = 1*/
	if _N_ = 1 then do;
  	  %do M=1 %to &nofvarsw; /* create variables for all combinations of vars */
	    %if &nofafter ne 0 %then %do;
        ARRAY namea&M[*]  &var&&option&M.._AfIdate1-&var.&&option&M.._AfIdate&nofafter  _CHAR_;
        ARRAY datea&M [*] &var&&option&M.._AfIdatedt1-&var.&&option&M.._AfIdatedt&nofafter;
		%end;
	    ARRAY nameb&M[*]  &var&&option&M.._BeIdate1-&var.&&option&M.._BeIdate&nofbefore _CHAR_;
        ARRAY dateb&M [*] &var&&option&M.._BeIdatedt1-&var.&&option&M.._BeIdatedt&nofbefore;
		%if &addvar1 ne %then %do; /* txt information that goes with the variables */
	      ARRAY infoa&M[*]/* select char as input: $ */ $ &var&&option&M.._AfIdatetxt1-&var&&option&M.._AfIdatetxt&nofbefore;
	      ARRAY infob&M[*] $ &var&&option&M.._BeIdatetxt1-&var&&option&M.._BeIdatetxt&nofbefore;
		%end;
	    max_a&M = 0;
	    max_b&M = 0;
	    /* set date format */
        format &var.&&option&M.._BeIdatedt1-&var.&&option&M.._BeIdatedt&nofbefore date.;
	    %if &nofafter ne 0 %then format &var.&&option&M.._AfIdatedt1-&var.&&option&M.._AfIdatedt&nofafter date.;;
        /* keep information and store in one line when last.pnr */
        retain &var.&&option&M.._BeIdatedt1-&var.&&option&M.._BeIdatedt&nofbefore;
        retain &var.&&option&M.._BeIdate1-&var.&&option&M.._BeIdate&nofbefore;
		%if &nofafter ne 0 %then %do;
  	      retain &var.&&option&M.._AfIdatedt1-&var.&&option&M.._AfIdatedt&nofafter;
	      retain &var.&&option&M.._AfIdate1-&var.&&option&M.._AfIdate&nofafter;
		%end;
		%if &addvar1 ne %then %do;
	      retain &var&&option&M.._BeIdatetxt1-&var.&&option&M.._BeIdatetxt&nofbefore;
	      retain &var&&option&M.._AfIdatetxt1-&var.&&option&M.._AFIdatetxt&nofbefore;
		%end;
	  %end;
	end;
	if first.pnr then do;
	  %do M=1 %to &nofvarsw; /* create variables for all combinations of vars, Reset at first run for every pnr */
        a&M = 0;
	    b&M = 0;
		/* reset arrays */
		%do I=1 %to &nofbefore;
		  &var.&&option&M.._BeIdatedt&I = .;
          &var.&&option&M.._BeIdate&I = .;
		  %if &addvar1 ne %then &var&&option&M.._BeIdatetxt&I = .;;
		%end;
		%if &nofafter ne . %then %do;
  		  %do I=1 %to &nofafter;
	        &var.&&option&M.._AfIdatedt&I = .;
	        &var.&&option&M.._AfIdate&I = .;
		    %if &addvar1 ne %then &var&&option&M.._AfIdatetxt&I = .;;
		  %end;
		%end;
	  %end;
	end;
	/* retain count-values */
	retain
    %do M=1 %to &nofvarsw;
      a&M b&M max_a&M max_b&M
   %end;;
    %do M=1 %to &nofvarsw; /* loop switch variable, e.g., if two then check if &varswitch is A or B */
  	  *if &varswitch = &&option&M.sw then do;
	  %if &nofafter ne 0 %then %do;
	    if AfIdate ne . then do; /* measure is after idate */
		  if a&M=0 or &varname ne namea&M[a&M] then do; /* store only changes to &varname */
		    a&M = a&M + 1;
		    namea&M[a&M] = &varname;
		    datea&M[a&M] = AFIdate;
		    %if &addvar1 ne %then infoa&M[a&M] = &addvar1sw;;
		  end;
		end;
	  %end;
		if BeIdate ne . then do; /* measure is before idate */
		  if (b&M = 0) or (&varname ne nameb&M[b&M]) then do; /* store only changes to &varname */
		    b&M = b&M + 1;
		    nameb&M[b&M] = &varname;
		    dateb&M[b&M] = BeIdate;
		    %if &addvar1 ne %then infob&M[b&M] = &addvar1sw;;
		  end;
	    end;
	  *end;
	%end;
	%do M=1 %to &nofvarsw;
	  %if &nofafter ne 0 %then %do;
  	    if max_a&M < a&M then max_a&M = a&M; /* tæl a */
	  %end;
	  if max_b&M < b&M then max_b&M = b&M; /* tæl b */
	%end;
    if last then do;
	  put
	  %do M=1 %to &nofvarsw;
	    %if &nofafter ne 0 %then max_a&M; max_b&M
	  %end;
	  ;
	end;
	if last.pnr then output;
	keep
	  pnr &indexdate
  	  %do M=1 %to &nofvarsw; /* create variables for all combinations of vars */
        &var.&&option&M.._BeIdatedt1-&var.&&option&M.._BeIdatedt&nofbefore
        &var.&&option&M.._BeIdate1-&var.&&option&M.._BeIdate&nofbefore
	  %if &nofafter ne 0 %then %do;
	    &var.&&option&M.._AfIdatedt1-&var.&&option&M.._AfIdatedt&nofafter
	    &var.&&option&M.._AfIdate1-&var.&&option&M.._AfIdate&nofafter
	  %end;
		%if &addvar1 ne %then &var&&option&M.._BeIdatetxt1- &var&&option&M.._BeIdatetxt&nofbefore;
	  %end;
     ;
  %runquit;
%mend;
