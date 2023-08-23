/* SVN header
$Date: 2023-08-22 14:50:31 +0200 (ti, 22 aug 2023) $
$Revision: 344 $
$Author: wnm6683 $
$Id: charlson.sas 344 2023-08-22 12:50:31Z wnm6683 $
    */
/*
  #+NAME
    %charlson
  #+TYPE
    SAS
  #+DESCRIPTION
    Extract Charlson index values for a specific population, at given time
    points. Output dataset contain variable Charlson reporting the
    index. The macro is called outside a datastep.
  #+SYNTAX
    %charlson(
      basedata=    Dataset containing population (pnr) and required status date (idate).
      outlib=      Output library where charlson tables is placed.
      IndexDate=   idate, Indexdate for each pnr.
      PeriodStart= If not set, period will be from birth to IndexDate. Else period is from PeriodStart-IndexDate.
      ajour=       Date for data extraction, use if to reproduce earlier data at a any given date after 30/5 2016. Optional.
    );
  #+OUTPUT
    pnr
  charlson
  #+AUTHOR
    Jette Kjældgaard
  #+CHANGELOG
   Date     Initials  Status
   14-12-2016 JNK     Replaced old with version from SDS.
   14-03-2017 JNK     Fixing... basedata to data, diagtype = 'xxx...' made longer
   22.06.2017 JNK     Keep indexdate in final table.
*/
%macro charlson(basedata, outlib, indexdate, PeriodStart=, ajour=today());
  /* merge the two tables - maybe some of the variables from &basedata is used when calculating charlson,
     e.g. date=idate or indate=idate-365 */
  proc sql;
    create table work.charlson as
      select a.pnr, a.&IndexDate, b.outcome, b.indate as charlindate, b.rec_in, b.rec_out, b.weight
      from &basedata a
      join charlib.charlson b on a.pnr=b.pnr
      where &ajour between b.rec_in and b.rec_out
      order by pnr, &IndexDate, outcome;
    %sqlquit;
    data &outlib..charlson&IndexDate;
      set work.charlson;
      by pnr &IndexDate;
      length diagtype $12;
      format charlson&IndexDate 8.;
      retain diagtype; /* only count one time for each diag-group */;
      retain charlson&IndexDate; /* index summary */;
      if first.&IndexDate then do;
        charlson&IndexDate=0;
        diagtype = ''; /* make sure diagtype is not truncated when comparing to outcome */;
    end;
    if diagtype ^= outcome then do;
      diagtype = outcome;
      %if "&PeriodStart"="" %then %do;
      /* count charlson index from birth until &IndexDate */;
        charlsonDate&IndexDate=&IndexDate;
        format charlsonDate&IndexDate date.;
        if charlindate <=&IndexDate then charlson&IndexDate = charlson&IndexDate+weight;
        label charlson&IndexDate = "CHARLSON index at &IndexDate";
        keep pnr charlson&IndexDate charlsonDate&IndexDate &IndexDate;
        retain charlsonDate&IndexDate;
      %end;
      %else %do;
      /* count charlson index in the period from &periodStart to &IndexDate */;
        charlsonDateStart&IndexDate=&PeriodStart;
        charlsonDateEnd&IndexDate = &IndexDate;
        format  charlsonDateStart&IndexDate charlsonDateEnd&IndexDate date.;
        if &PeriodStart<=charlindate<=&IndexDate then charlson&IndexDate = charlson&IndexDate+weight;
        label charlson&IndexDate = "CHARLSON index mesured between &PeriodStart and &IndexDate";
        keep pnr charlson&IndexDate charlsonDateStart&IndexDate CharlsonDateEnd&IndexDate &IndexDate;
        retain charlsonDateStart&IndexDate;
        retain charlsonDateEnd&IndexDate;
      %end;
    end;
    if last.&IndexDate then output;
  %runquit;
	data &outlib..charlson&IndexDate;
	  merge &basedata (in=a keep=pnr &IndexDate) &outlib..charlson&IndexDate (in=b);
	  by pnr &IndexDate;
	  if a and not b then charlson&IndexDate = 0; /* fill out with zeroes if pnr not in charlib.charlson */
  %runquit;
%mend;
