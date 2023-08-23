/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: mergeUBE.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
/*
  #+NAME
    %mergeUBE
  #+TYPE
    SAS
  #+DESCRIPTION
    Repeatedly calling %reduceOPR for a list of operations and merge on study dataset.
    The macro is called outside a datastep.
    For example of use, see t017.
  #+SYNTAX
    %mergeUBE(
      basedata,  Input data set, see %reducerFU
      inlib,   Libname with diagnose (ALL) datasets
      outlib,  Libname where output from %reducerFU is stored
      IndexDate,  Event date variable, see %reducerFU
      sets     Diagnoses, list refering to standard names
      ajour=   Set to date for dataset, defaults to today.
      postfix= additional name for variables and tables.
    );
    See t017../code/makedata.sas for an example.
  #+OUTPUT
    Output dataset from %reducerFU is merged to basedata.
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date    Initials  Status
    07-07-14  FLS     Macro added
    18-08-15            FLS             recoded to link to mergeOPR which is identical code, ie reducerFO can be used.
*/
%MACRO mergeUBE(basedata,inlib,outlib,IndexDate,sets,ajour=, postfix=);
  %mergeOPR(&basedata,&inlib,&outlib,&IndexDate,&sets,ajour=&ajour, postfix=&postfix);
%MEND;
