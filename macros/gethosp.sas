/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: getHOSP.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/*
  #+NAME
    %getHOSP
  #+TYPE
    SAS
  #+DESCRIPTION
    The macro ''getHOSP'' finds periods of hospital admissions.
    The macro ''%smoother'' smooths periods of admission, joining them if
    there is 1 day or less between admissions.
  #+SYNTAX
    %findingHOSPperiods(
      outdata,    Output data set name. Required.
      basedata=,    Input dataset with required population. Required
      pattype=0,    List of patient types (0 1 2 3). Separated with spaces.
    )
    %smoother(
      outdata,  Output data set name. Required.
      indata,   Data set to be smoothed. Required.
      indate,   Variable containing start date for hospital admission period
      outdate   Variable containing end date for admission period.
    )
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date       Initials  Status
    22/3/13    AGR       Documentation added
    05-12-2014 FLS       Recent added information on hospital
                         and unit did not work properly due to
                         shift in unit variable definition in 1996
    31-07-2014  JNK      Changed to *_hist version and added ajour and keephist.
    23-11-2016  JNK      Changed back to "not" hist (new master folder) and updated variables names (aar-> year etc)
*/
%macro getHosp(outdata,basedata=, pattype=0, fromyear=1977);
  /* print linie med tidspunkt for kald af makro og for udtræksdato */
  %start_timer(getHOSP);
  %put "local macro version";
  %local localoutdata yr;
  %let localoutdata = %NewDatasetName(localoutdatatmp); /* temporært datasæt så der arbejdes i work */
  %put &basedata;
  proc sql inobs=&sqlmax;
  %do yr=&fromyear %to &lastLPR;
    %if &yr=&fromyear %then create table &localoutdata as ;
    %else insert into &localoutdata ;
    select a.pnr, a.indate, (a.outdate-a.indate) as hospdays, a.outdate, a.year, a.hospital, a.adiag as diagnose,
     a.rec_in, a.rec_out, a.DataValidUntil
    from  Master.Lpr_ind&yr a
    %if &basedata ne %then , &basedata b;
    where
    a.pattype in (%commas(&pattype)) /* jnk 29/7-2015: rettet "and" rækkefølge så det virker hver gang */
    %if &basedata ne %then and a.pnr=b.pnr;
    ;
  %end;
  quit;
  proc sort data=&localoutdata out=&outdata;
    by pnr indate outdate diagnose;
  run;
  %cleanup(&localoutdata);
  %end_timer(getHOSP, text=execution time getHOSP);
%mend;
