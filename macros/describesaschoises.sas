%macro describeSASchoises(comment, 
                          path=&locallogdir /* default out folder */,
                          name=SAScomments  /* default filename */ , 
                          newfile = FALSE   /* select reset option or append to existing file */
                          );
  %let mod=;
  %if %upcase(&NewFile)=FALSE %then %let mod=mod;
    data _null_;
      file "&path\&name..txt" &mod; 
  	  put &comment;
     	  put;
    run;
%mend;
