/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: reduceMediStatus.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
/*
  #+NAME
    %reduceMediStatus
  #+TYPE
    SAS
  #+DESCRIPTION
  Output data from %mergeMedi is reduced to a status at
  a specified time. One row pr pnr
  The macro is called outside a datastep.
  #+SYNTAX
    %reduceMediStatus(
      indata,    Input dataset name, should before output from %findingATCperiods. Required.
      outdata,   Output dataset name. Required.
      drug,      Variable in indata identifying the drug. Required.
      IndexDate, Date variable in indata or date constant, defining
                  the date of required treatment status. Required.
      atc=       If several ATC codes included, this variable keeps the
                 ATC code, the drug variable should then before the same value for all records.
                  Use %prereducerFA3 in this as a wrapper. Optional.
     );
  #+OUTPUT:
    pnr
    &IndexDate
    &drug
    &drug.LaEksdBe&IndexDate  = "Last ekspdate before inclusion event, &IndexDate";
    &drug.LaDrugBe&IndexDate  = "Last drug before inclusion event, &IndexDate";
    &drug.LaPSBe&IndexDate    = "Last packsize before inclusion event, &IndexDate";
    &drug.LaVolBe&IndexDate   = "Last volume before inclusion event, &IndexDate";
    &drug.LaVTTBe&IndexDate   = "Last volumetext before inclusion event, &IndexDate";
    &drug.LaStrBe&IndexDate   = "Last strnum before inclusion event, &IndexDate";
    &drug.LaUnitBe&IndexDate  = "Last strunit before  inclusion event, &IndexDate";
    &drug.FiEksdBe&IndexDate  = "First ekspdate before inclusion event, &IndexDate";
    &drug.FiDrugBe&IndexDate  = "First drug before inclusion event, &IndexDate";
    &drug.FiPSBe&IndexDate    = "First packsize before inclusion event, &IndexDate";
    &drug.FiVolBe&IndexDate   = "First volume before inclusion event, &IndexDate";
    &drug.FiVTTBe&IndexDate   = "First volumetext before inclusion event, &IndexDate";
    &drug.FiStrBe&IndexDate   = "First strnum before inclusion event, &IndexDate";
    &drug.FiUnitBe&IndexDate  = "First strunit before  inclusion event, &IndexDate";
    &drug.FiEksdAf&IndexDate  = "First ekspdate after inclusion event, &IndexDate";
    &drug.FiDrugAf&IndexDate  = "First drug after inclusion event, &IndexDate";
    &drug.FiPSAf&IndexDate    = "First packsize after inclusion event, &IndexDate";
    &drug.FiVolAf&IndexDate   = "First volume after inclusion event, &IndexDate";
    &drug.FiVTTAf&IndexDate   = "First volumetxt after inclusion event, &IndexDate";
    &drug.FiStrAf&IndexDate   = "First strnum after inclusion event, &IndexDate";
    &drug.FiUnitAf&IndexDate  = "First strunit after inclusion event, &IndexDate";
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date        Initials  Status
    07-08-2014  FLS       Variables with First ever prescription added.
    10-10-2016  JNK       Remamed Last=La, First=Fi, Before=Be, After=Af
*/

%MACRO reduceMediStatus(indata,outdata,drug,IndexDate,atc=, ajour=);
  %local temp;
  %let temp=%NewDatasetName(temp);
  %if &atc= %then %let atc=&drug;
  proc sort data=&indata;
    by pnr &IndexDate  eksd;
  run;
  data &temp;
    set &indata;
    afterbase=1;
    %if &IndexDate ne %then %do;
      afterbase=(eksd ge &IndexDate);
    %end;
    where &ajour between rec_in and rec_out;
    drop rec_in rec_out;
  run;
  data &outdata;
    set &temp;
    by pnr &IndexDate afterbase;
    length   %if &IndexDate ne %then %do;
      &drug.LaDrugBe&IndexDate
      &drug.LaUnitBe&IndexDate
      &drug.FiDrugBe&IndexDate
      &drug.FiUnitBe&IndexDate
    %end;
    &drug.FiUnitAf&IndexDate
    &drug.FiDrugAf&IndexDate $7;
    length   %if &IndexDate ne %then %do;
      &drug.LaVTTBe&IndexDate
      &drug.FiVTTBe&IndexDate
    %end;
    &drug.FiVTTAf&IndexDate $12;
    retain   %if &IndexDate ne %then %do;
      &drug.LaEksdBe&IndexDate  &drug.LaDrugBe&IndexDate
      &drug.LaPSBe&IndexDate    &drug.LaVolBe&IndexDate
      &drug.LaVTTBe&IndexDate   &drug.LaStrBe&IndexDate
      &drug.LaUnitBe&IndexDate  &drug.LaNPackBe&IndexDate
      &drug.FiEksdBe&IndexDate  &drug.FiDrugBe&IndexDate
      &drug.FiPSBe&IndexDate    &drug.FiVolBe&IndexDate
      &drug.FiVTTBe&IndexDate   &drug.FiStrBe&IndexDate
      &drug.FiUnitBe&IndexDate  &drug.FiNPackBe&IndexDate
    %end;
    &drug.FiEksdAf&IndexDate  &drug.FiDrugAf&IndexDate
    &drug.FiPSAf&IndexDate    &drug.FiVolAf&IndexDate
    &drug.FiVTTAf&IndexDate   &drug.FiStrAf&IndexDate
    &drug.FiUnitAf&IndexDate  &drug.FiNPackAf&IndexDate;
    format %if &IndexDate ne %then %do;
      &drug.LaEksdBe&IndexDate
      &drug.FiEksdBe&IndexDate
    %end;
    &drug.FiEksdAf&IndexDate  date.;
    if %if &IndexDate ne %then first.&IndexDate; %else first.pnr; then do;
      %if &IndexDate ne %then %do;
        &drug.LaEksdBe&IndexDate =.;  &drug.LaDrugBe&IndexDate  ="";
        &drug.LaPSBe&IndexDate   =.;  &drug.LaVolBe&IndexDate   =.;
        &drug.LaVTTBe&IndexDate  =""; &drug.LaStrBe&IndexDate   =.;
        &drug.LaUnitBe&IndexDate =""; &drug.LaNPackBe&IndexDate =.;
        &drug.FiEksdBe&IndexDate =.;  &drug.FiDrugBe&IndexDate  ="";
        &drug.FiPSBe&IndexDate   =.;  &drug.FiVolBe&IndexDate   =.;
        &drug.FiVTTBe&IndexDate  =""; &drug.FiStrBe&IndexDate   =.;
        &drug.FiUnitBe&IndexDate =""; &drug.FiNPackBe&IndexDate =.;
      %end;
      &drug.FiEksdAf&IndexDate =.;  &drug.FiDrugAf&IndexDate ="";
      &drug.FiPSAf&IndexDate   =.;  &drug.FiVolAf&IndexDate  =.;
      &drug.FiVTTAf&IndexDate  =""; &drug.FiStrAf&IndexDate  =.;
      &drug.FiUnitAf&IndexDate =""; &drug.FiNPackAf&IndexDate=.;
    end;
    %if &IndexDate ne %then %do;
      if first.afterbase and afterbase=0 then do;
        &drug.FiEksdBe&IndexDate=eksd;      &drug.FiDrugBe&IndexDate=&atc;
        &drug.FiPSBe&IndexDate=packsize;    &drug.FiVolBe&IndexDate=volume;
        &drug.FiVTTBe&IndexDate=voltypetxt; &drug.FiStrBe&IndexDate=strnum;
        &drug.FiUnitBe&IndexDate=strunit;   &drug.FiNPackBe&IndexDate=NPack;
      end;
      if Last.afterbase and afterbase=0 then do;
        &drug.LaEksdBe&IndexDate=eksd;       &drug.LaDrugBe&IndexDate=&atc;
        &drug.LaPSBe&IndexDate=packsize;     &drug.LaVolBe&IndexDate=volume;
        &drug.LaVTTBe&IndexDate=voltypetxt;  &drug.LaStrBe&IndexDate=strnum;
        &drug.LaUnitBe&IndexDate=strunit;    &drug.LaNPackBe&IndexDate=NPack;
      end;
    %end;
    if first.afterbase and afterbase=1 then do;
      &drug.FiEksdAf&IndexDate=eksd;       &drug.FiDrugAf&IndexDate=&atc;
      &drug.FiPSAf&IndexDate=packsize;     &drug.FiVolAf&IndexDate=volume;
      &drug.FiVTTAf&IndexDate=voltypetxt;  &drug.FiStrAf&IndexDate=strnum;
      &drug.FiUnitAf&IndexDate=strunit;    &drug.FiNPackAf&IndexDate=NPack;
    end;
    if %if &IndexDate ne %then Last.&IndexDate; %else Last.pnr; then output;
    keep pnr &drug /* jnk added drug 22/11 */
    %if &IndexDate ne %then &IndexDate
      &drug.LaEksdBe&IndexDate   &drug.LaDrugBe&IndexDate
      &drug.LaPSBe&IndexDate     &drug.LaVolBe&IndexDate
      &drug.LaVTTBe&IndexDate    &drug.LaStrBe&IndexDate
      &drug.LaUnitBe&IndexDate   &drug.LaNPackBe&IndexDate
      &drug.FiEksdBe&IndexDate   &drug.FiDrugBe&IndexDate
      &drug.FiPSBe&IndexDate     &drug.FiVolBe&IndexDate
      &drug.FiVTTBe&IndexDate    &drug.FiStrBe&IndexDate
      &drug.FiUnitBe&IndexDate   &drug.FiNPackBe&IndexDate
    ;
    &drug.FiEksdAf&IndexDate  &drug.FiDrugAf&IndexDate
    &drug.FiPSAf&IndexDate    &drug.FiVolAf&IndexDate
    &drug.FiVTTAf&IndexDate   &drug.FiStrAf&IndexDate
    &drug.FiUnitAf&IndexDate  &drug.FiNPackAf&IndexDate;
    %if &IndexDate ne %then %do;
      label &drug.LaEksdBe&IndexDate = "Last ekspdate before inclusion event, &IndexDate";
      label &drug.LaDrugBe&IndexDate = "Last drug before inclusion event, &IndexDate";
      label &drug.LaPSBe&IndexDate   = "Last packsize before inclusion event, &IndexDate";
      label &drug.LaVolBe&IndexDate  = "Last volume before inclusion event, &IndexDate";
      label &drug.LaVTTBe&IndexDate  = "Last volumetext before inclusion event, &IndexDate";
      label &drug.LaStrBe&IndexDate  = "Last strnum before inclusion event, &IndexDate";
      label &drug.LaUnitBe&IndexDate = "Last strunit before inclusion event, &IndexDate";
      label &drug.LaNPackBe&IndexDate= "Last NPack before inclusion event, &IndexDate";
      label &drug.FiEksdBe&IndexDate = "First ekspdate before inclusion event, &IndexDate";
      label &drug.FiDrugBe&IndexDate = "First drug before inclusion event, &IndexDate";
      label &drug.FiPSBe&IndexDate   = "First packsize before inclusion event, &IndexDate";
      label &drug.FiVolBe&IndexDate  = "First volume before inclusion event, &IndexDate";
      label &drug.FiVTTBe&IndexDate  = "First volumetext before inclusion event, &IndexDate";
      label &drug.FiStrBe&IndexDate  = "First strnum before inclusion event, &IndexDate";
      label &drug.FiUnitBe&IndexDate = "First strunit before inclusion event, &IndexDate";
      label &drug.FiNPackBe&IndexDate = "First NPack before inclusion event, &IndexDate";
    %end;
    label &drug.FiEksdAf&IndexDate  = "First ekspdate after inclusion event, &IndexDate";
    label &drug.FiDrugAf&IndexDate  = "First drug after inclusion event, &IndexDate";
    label &drug.FiPSAf&IndexDate    = "First packsize after inclusion event, &IndexDate";
    label &drug.FiVolAf&IndexDate   = "First volume after inclusion event, &IndexDate";
    label &drug.FiVTTAf&IndexDate   = "First volumetxt after inclusion event, &IndexDate";
    label &drug.FiStrAf&IndexDate   = "First strnum after inclusion event, &IndexDate";
    label &drug.FiUnitAf&IndexDate  = "First strunit after inclusion event, &IndexDate";
    label &drug.FiNPackAf&IndexDate = "First NPack after inclusion event, &IndexDate";
    %if &IndexDate = %then %do;
      rename &drug.FiEksdAf&IndexDate = &drug.FiEksd;
      rename &drug.FiDrugAf&IndexDate = &drug.FiDrug;
      rename &drug.FiPSAf&IndexDate   = &drug.FiPS;
      rename &drug.FiVolAf&IndexDate  = &drug.FiVol;
      rename &drug.FiVTTAf&IndexDate  = &drug.FiVTT;
      rename &drug.FiStrAf&IndexDate  = &drug.FiStr;
      rename &drug.FiUnitAf&IndexDate = &drug.FiUnit;
      rename &drug.FiNPackAf&IndexDate= &drug.FiNPack;
    %end;
  run;
%MEND;
