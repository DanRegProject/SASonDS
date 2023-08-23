%macro TjekMacro(inputtable, firstvar, variablelist, outputname=table, titletxt='');
  %local N I;

  %start_timer(tjekmacro);

*  ODS HTML body='&outputname.%qsysfunc(datetime(), datetime20.3).html';
  proc tabulate data=&inputtable;
  class &firstvar &variablelist;
  table &firstvar all, (&variablelist all)*N*f=9.0;
  title &titletxt;
  run;
*  ODS HTML close;

  %end_timer(tjekMacro, text=Measure time for Tjekmacro macro);
%mend;


