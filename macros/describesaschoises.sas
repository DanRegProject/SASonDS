/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: describeSASchoises.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
%macro describeSASchoises(comment, 
                          path=&locallogdir /* default out folder */, 
                          name=SAScomments  /* default name of file  */, 
                          NewFile=FALSE     /* select reset option or append in existing */
                          );
  %if &NewFile=TRUE %then %do;
    data _null_;
      file "&path\&name..txt"; /* create first version of file (erase old) */
      put &comment;
    run;
 %end;
 %if &NewFile=FALSE %then %do;  /* append to existing file or create a new one with a new name */
    data _null_;
      file "&path\&name..txt" mod; /* mod means append (probably modify... ) */
      put &comment;
    run;
  %end;
%mend;
