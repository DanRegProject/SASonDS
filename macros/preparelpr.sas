/* SVN header
$Date:  $
$Revision:  $
$Author: $
$Id:  $
*/
/* LPR macros, næsten direkte kopieret - skal måske ikke bruges */
%macro vwLPR(st,sl);
    %local I;
  proc sql;
    %do I=&st %to &sl;
	  create view master.vwLPR&I._hist as
	  select
      a.pnr,
	  a.recnum,
	  a.indate,
	  a.outdate,
	  a.pattype,
	  a.hospital,
      a.hospitalunit,
      b.diagnose,
	  b.diagtype,
	  a.aar, a.rec_in, a.rec_out from
      from master.lpr_ind&I a left join master.lpr_diag&I b
	  on a.recnum=b.recnum and a.rec_out=b.rec_out
	  where b.c_diagtype ne '+'
	  order by pnr;
	%end;
  quit;
%mend;
%macro aariLPR(st,sl);
        %local I;
  %do I=&st %to &st;
    data master.lpr_ind&I;
      set master.lpr_ind&I;
      aar = year(inddto);
    %runquit;
  %end;
%mend;
%macro vwLPRsksopr(st,sl);
        %local I;
  proc sql;
    %do I=&st %to &sl;
      create view master.vwLPRsksopr&I as
	  select a.v_recnum as recnum, a.c_komb as komb, a.c_oafd as hospitalunit, a.c_osgh as hospital
	  a.hospitalunit, a.rec_in, a.rec_out
	  from master.LPR_ind&I a
	  inner join
	  master.lpr_sksopr&I b
	  on a.k_recnum = b.v_recnum
	  where b.c_opr ne '+';
	%end;
  quit;
%mend;
%macro vwLPRsksube(st,sl);
        %local I;
  proc sql;
    %do I=&st %to &sl;
      create view master.vwLPRsksube&I as
	  select a.v_recnum as recnum, a.c_oafd as hospitalunit,
      a.c_osgh as hospital, a.d_odto as odto, a.tilopr as tilopr, a.c_opr as opr
	  from master.LPR_ind&I a
	  inner join
	  master.lpr_sksube&I b
	  on a.k_recnum = b.v_recnum
	  where b.c_oprart ne '+';
	%end;
  quit;
%mend;
