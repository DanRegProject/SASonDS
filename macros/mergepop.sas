/* SVN header
$Date: 2021-12-15 11:52:40 +0100 (on, 15 dec 2021) $
$Revision: 312 $
$Author: wnm6683 $
$Id: mergePOP.sas 312 2021-12-15 10:52:40Z wnm6683 $
*/
/*
  #+CHANGELOG
    Date       Initials  Status
    23-11-2016  JNK      Changed back to "not" hist (new master folder) with updated variables names.
*/
%MACRO mergePOP(outdata,basedata,IndexDate,ajour=today() );
  %put start mergePOP: %qsysfunc(datetime(), datetime20.3), udtræksdato = &ajour;
  proc sql;
    create table _udvandring_ as
      select a.pnr, a.&IndexDate, b.udv_dato, b.indv_dato /*, a.DataValidUntil, b.datauntil as migrdatauntil */
      from &basedata a left join master.vandringer b
      on a.pnr=b.pnr and a.&IndexDate<=b.udv_dato
      where &ajour between b.rec_in and b.rec_out
      order by pnr, &IndexDate, udv_dato;
      /*Sidste Indvandring før IndexDate*/
      /* pr 20/5 15 også udvandrede som ikke er indvandrede pr IndexDate */
      create table _indvandring_ as
      select a.pnr, a.&IndexDate, b.udv_dato, b.indv_dato /*, b.datauntil as migrdatauntil */
      from &basedata a left join master.vandringer b
      on a.pnr=b.pnr and (b.indv_dato<=a.&IndexDate or a.&IndexDate between b.udv_dato and b.indv_dato
      or (b.udv_dato<a.&IndexDate and b.indv_dato=.))
      where &ajour between b.rec_in and b.rec_out
      order by a.pnr, a.&IndexDate, b.udv_dato;
  data _udvandring_;
    set _udvandring_;
    by pnr &IndexDate;
    if first.&IndexDate;
    rename udv_dato=udv_dato2;
    rename indv_dato=indv_dato2;
    label udv_dato="Date of emigration, first after studystart";
    label indv_dato="Date of immigration, related to first emigration after studystart";
  run;
  data _indvandring_;
    set _indvandring_;
    by pnr &IndexDate;
    if last.&IndexDate;
    rename udv_dato=udv_dato1;
    rename indv_dato=indv_dato1;
    label udv_dato="Date of emigration, last before studystart";
    label indv_dato="Date of immigration related to last emigration before studystart, if any";
  run;
  proc sort data=&basedata out=&outdata;
    by pnr &IndexDate;
  run;
  data &outdata;
    merge &outdata(in=a) _udvandring_ _indvandring_; *fls 25/06/15 rettet basedata->outdata;
    by pnr &IndexDate;
    if a;
  run;
  data &outdata;
      merge &outdata(in=a) master.population (where=(&ajour between rec_in and rec_out) )
                           master.valideredecprnumre(in=b keep=pnr);;
    by pnr;
    if a;
    inbef=b;
    drop rec_in rec_out  ;
  run;
%MEND;
