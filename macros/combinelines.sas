/* SVN header
$Date: 2020-03-11 08:30:44 +0100 (on, 11 mar 2020) $
$Revision: 207 $
$Author: fskMarJen $
$ID: $
*/

%macro CombineLinesWithSameInfo(tablename, variablelist);
 /* create compare id */
  data work.combine;
    set &tablename;
    %makeid(compareid,&variablelist);
  %runquit;
  /* sort data */
  proc sort data=work.combine;
    by compareid &variablelist rec_in rec_out;
  %runquit;

  /* look for dublicate lines, store in two tables*/
  data work.same_lines work.without_dup;
    set work.combine;
	by compareid;
	if first.compareid ne last.compareid then output work.same_lines;
	else output work.without_dup;
  run;

  /* combine the lines with same information */
  data work.reduced;
    set work.same_Lines;
	by compareid;
	format prev_recin final_in final_out prev_recout date. ;

	retain final_in final_out;

	/* store information from previous line */
	prev_recin = lag1(rec_in);
	prev_recout = lag1(rec_out);

	/* 2. line or more */
	if first.compareid=0 then do;
      final_in = min(rec_in,prev_recin);
	  final_out = max(rec_out, prev_recout);
	end;
	/* last line - output */
	if last.compareid;
	rec_in = final_in;
	rec_out = final_out;
	/* drop help-variables */
	drop prev_recin prev_recout final_in final_out;
  %runquit;

  data work.final;
    merge work.reduced work.without_dup;
	by compareid;

*	if first.compareid; /* only keep first line */
  %runquit;
/* store final result */
  data &tablename;
    set work.final (drop=compareid);
  %runquit;
 %mend;
