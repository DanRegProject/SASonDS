/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: baseUBE.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
/*
  #+NAME
    %baseUBE
  #+TYPE
    SAS
  #+DESCRIPTION
    Utility to rename and restrict which variables to keep within a
    studydataset. It is assumed that data are prepared with %mergeUBE.
    The macro is called inside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %baseUBE(
      IndexDate,         Event date variable
      sets               Diagnoses, list refering to standard names censordate=censordate,
                               Date variable, time to stop
      keepOpr=FALSE,     Keep Operation information, First and last before, and first after
      keepPat=FALSE,     Keep Patient type information, First and last before, and first after
      keepDate=FALSE,    Keep Date information, First and last before, and first after
      keepBefore=TRUE,   Keep information before IndexDate
      keepAfter=TRUE,    Keep information after IndexDate
      keepStatus=TRUE    Keep status variables (&var.before, &var.fup,and &var.fupDate)
    );
  See t017../code/makedata.sas for an example.
  #+OUTPUT
    without changed options, &var.baseline, &var.fup as indicators are produced.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials  Status
    07-07-14  FLS     Macro added
    16-12-14  FLS     For some reason keepBefore and keepAfter was not coded correctly
    07-01-15  FLS     Variable selection finally correct
*/
%MACRO baseUBE(IndexDate,sets,censordate=&globalend,keepOpr=FALSE,keepPat=FALSE,keepDate=FALSE,keepBefore=TRUE,keepAfter=TRUE,keepStatus=TRUE,postfix=);
%baseOPR(&IndexDate,&sets,censordate=&censordate,keepOPR=&keepOPR,keepPat=&keepPat,keepDate=&keepDate,keepBefore=&keepBefore,keepAfter=&keepAfter,keepStatus=&keepStatus,postfix=&postfix);
    %MEND;
