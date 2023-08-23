%macro describeSASchoises(comment, 
                          path=&locallogdir /* default out folder */,
                          name=SAScomments  /* default filename */ , 
                          newfile = FALSE   /* select reset option or append to existing file */
                          );
  %if &NewFile=TRUE %then %do;
    data _null_;
      file "&path\&name..txt"; /* create first version of file (erase old) */
  	  put &comment;
    run;
  %end;

  %if &NewFile=FALSE %then %do;
    data _null_;
	  file "&path\&name..txt" mod; /* mod means append (probably modify) */
	  put &comment;
	run;
  %end;
%mend;
