/* SVN header
$Date: 2023-08-22 14:50:31 +0200 (ti, 22 aug 2023) $
$Revision: 344 $
$Author: wnm6683 $
$Id: smoothhosp.sas 344 2023-08-22 12:50:31Z wnm6683 $
*/
/*
Smoother indlæggelsesperioder
NB Et forløb betegnes som ét forløb hvis der er mindre end 1 dag mellem
hospsmo:  output datasætnavn
hospall:   datasæt man ønsker at smoothe
ajour:      date of data
NofDays:    How many days between admissions are accepted as one hospitalization period
basedata:   Input dataset with pnr and IndexDate
IndexDate:  name of date varible in basedata
Inputtable hospitalALL produced by %getHOSP:


*/
%macro smoothhosp(hospsmo, hospall, ajour=today(), NofDays=1, basedata=,IndexDate=);
    %local nof_days_to_smooth;
  %let nof_days_to_smooth=&nofDays;
  data _hosptemp_;
    set &hospall(where=(&ajour between rec_in and rec_out));
	if outdate ne . ; /* remove all lines without outdate - if it is keept it will result in wrong calculation of hospdays */
  %runquit;
  data _hosptemp_ ;
    set _hosptemp_; /* now reduced to ajour period */
	by pnr indate outdate;
	retain in out seg;
    format in out date9.;
	if first.pnr then do; /* reset */
	  in = indate;
	  out = outdate;
	  seg = 1;
	end;
    else do;
	  if (indate - out) <= &nof_days_to_smooth then do;
        out=outdate;
	  end;
	  else do;
        in  = indate;
		out = outdate;
		seg = seg+1; /* next hospitalisation period */
	  end;
    end;
    hospdays = out-in; /* always update hospdays */
  %RunQuit;
  data &hospsmo; /* keep in mydate for testing purpose */
    set _hosptemp_;
    by pnr seg;
    rename in = hosp_in;
    label in = "hospital period start";
    rename out = hosp_out;
    label out = "hospital period end";
    keep pnr in out hospdays;
    if last.seg then output; /* the last line in each segment will hold the entire hospitalisation period from in to out */
  %RunQuit;
%if &basedata ne and &indexdate ne %then %do;
  proc sql;
    create table _basetemp_ as
        select
        a.*,
        b.hosp_in as hosp_in&IndexDate,
        b.hosp_out  as hosp_out&IndexDate,
        b.hospdays as hospdays&IndexDate
        from &basedata(drop = %if %varexist(&basedata,hosp_in&IndexDate) eq 1 %then hosp_in&IndexDate;
    %if %varexist(&basedata,hosp_out&IndexDate) eq 1 %then hosp_out&IndexDate;
    %if %varexist(&basedata,hospdays&IndexDate) eq 1 %then hospdays&IndexDate;) a left join &hospsmo b on
	a.pnr=b.pnr
  %if &IndexDate ne %then and &IndexDate between b.hosp_in and b.hosp_out;
	order by pnr;
  %sqlquit;
  data &basedata;
    set _basetemp_;
  %runquit;
  %end;
%mend;
