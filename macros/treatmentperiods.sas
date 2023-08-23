/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: treatmentPeriods.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
%macro treatmentperiods(outdata,drug,recept=,hospital=);
/*
finder behandlingsperioder ud fra recept perioder og hospitalsperioder
NB der skal være overlap for at der defineres en behandlingsperiode
outdata:	output datasætnavn
recept: 	datasæt dannet af reducerFA
drug:		samme string drug label, som er brugt i reducerFA
hospital:	datasæt dannet af findingHOSPperiods
*/
data &outdata;
set &hospital;
rename inddto=&drug.start;
rename uddto=&drug.end;
hosp=1;
run;
data &outdata;
set &outdata &recept;
keep pnr &drug.start &drug.end hosp;
run;
proc sort data=&outdata;
by pnr &drug.start &drug.end;
run;
data &outdata (drop=id &drug.end hosp hosp1 seg1 rename=(&drug.start=begin end2=end));
set &outdata;
retain end2;
id=lag1(pnr);
if id=pnr and &drug.start<=(end2) then do;
	&drug.start=end2;
	end2=max(&drug.end,end2);
	end;
else do;
	seg+1;
	end2=&drug.end;
if hosp=1 then del=1;
	end;
format end2 date7.;
seg1=lag1(seg);
hosp1=lag1(hosp);
if seg1=seg and hosp1=hosp then del=1;
run;
data &outdata;
set &outdata;
if del^=1;
run;
data &outdata (drop=begin end seg del);
set &outdata;
retain &drug.start &drug.end;
by pnr seg;
format &drug.start &drug.end date7.;
if first.seg then do;
	&drug.start=begin;
	end;
if last.seg then do;
	&drug.end=end;
	output;
	end;
label &drug.start="&drug treatment period start";
label &drug.end="&drug tratment period end";
run;
data &outdata;
set &outdata;
retain &drug.periodnr;
by pnr;
if first.pnr then &drug.periodnr=0;
&drug.periodnr+1;
run;
%mend;
