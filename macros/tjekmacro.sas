/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: getDiag.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
%macro TjekMacro(inputtable, firstvar, variablelist, outputname=outtable, titletxt='');
  %start_timer(tjekmacro);
*   ODS HTML body='&outtable..html';
   proc tabulate data=&inputtable;
   class &firstvar &variablelist;
   table &firstvar all, (&variablelist all)*N*f=9.0; 
   title &titletxt;
   run;
*   ODS HTML close;
  %end_timer(tjekmacro, text='Measure time of TjekMacro macro');
%mend;
