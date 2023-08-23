/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: smoother.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
/*
  #+NAME          :  %smoother
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Smoother indlæggelsesperioder
                     NB: Et forløb betegnes som ét forløb hvis der er mindre end en dag i mellem
  #+OUTPUT        :  output datasætnavn
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  10-09-15    JNK      ported from DS
                  :
*/
%macro smoother(outdata, indata, indate, outdate, basedata=, basedate=);
data &outdata;
  set &indata;
  keep pnr &indate &outdate rec_in rec_out;
run;
proc sort data=&outdata;
  by pnr &indate &outdate;
run;
data &outdata (drop=id &outdate rename=(&indate=begin end2=end));
  set &outdata;
  retain end2;
  id=lag1 (pnr);
  if id=pnr and &indate<=(end2) then do;
    &indate=end2+1;
    end2=max(&outdate, end2);
  end;
  else do;
    seg+1;
	end2=&outdate;
  end;
  format end2 date7.;
run;
data &outdata (drop=begin end seg);
  set &outdata;
  retain &indate &outdate;
  by pnr seg;
  format &indate &outdate date7.;
  if first.seg then do;
    &indate=begin;
  end;
  if last.seg then do;
    &outdate=end;
	duration=&outdate-&indate;
	output;
  end;
  label &indate= "treatment period start";
  label &outdate="treatment period end";
run;
%if &basedata ne %then %do;
  data &outdata;
    merge &outdata &basedata;
	  by pnr;
	  %if &basedate ne %then %do;
	    Before&basedate = (&indate<&basedate and &outdate<&basedate and &outdate ne .);
		During&basedate = (&indate<=&basedate and &outdate>=&basedate);
		After&basedate  = (&indate>&basedate);
	  %end;
	run;
%end;
%mend;
