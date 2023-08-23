/* make a pop file with the recnum that goes with pnr (for LPR tables) */
/* if new tables that are linked internally with IDs, then a new source element and lines to create id tables must be added */
%macro GetPnrAndRecnum(inpop,outpop,source=LPR LPRPSYK MINIPAS MINIPASPSYK MFR LPR3SB,ajour=today());
  %local M tmpds;
  %let tmpds=%sysfunc(round(%qsysfunc(datetime()),1));

  /* remove empty slots in population table */
  data temp&tmpds;
    set &inpop;
	if pnr ne "";
  run;

  /* loop through lpr adm, and fetch recnum information for the specific population */
  proc sql inobs=&sqlmax;
/* LPR */
  %if %sysfunc(indexw(%upcase(&source),LPR))>0 %then %do;
      %do M=1977 %to &lastyr;
          %let ds= raw.lpr2_mdl_t_adm&M;
          %if &M<2005 %then %let ds= raw.lpr_t_adm&M; ;
          %let idxds= &outpop.lpr2_mdl_t_adm;
          %if &M<2005 %then %let idxds= &outpop.lpr_t_adm; ;
          %if %sysfunc(exist(&ds)) %then %do;
              %if &M=1977 or &M=2005 %then create table &idxds as;
              %else insert into &idxds;
              select distinct
                  a.k_recnum , upcase("&ds") as table length=26
                  from &ds a, temp&tmpds b where a.v_cpr_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
              %end;
          %let ds= raw.lpr2_mdl_uaf_t_adm&M;
          %if %sysfunc(exist(&ds)) %then %do;
		  	  %if &M=2005 %then create table &outpop.lpr2_mdl_uaf_t_adm as;
              %else insert into &outpop.lpr2_mdl_uaf_t_adm;
              select distinct
                  a.k_recnum , upcase("&ds") as table length=26
                  from &ds a, temp&tmpds b where a.v_cpr_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
              %end;
          %end;
      %end;
/* PSYK */
      %if %sysfunc(indexw(%upcase(&source),LPRPSYK))>0 %then %do;
          create table &outpop.lpr_t_psyk_adm as
              select distinct
              a.k_recnum , upcase("raw.lpr_t_psyk_adm") as table
              from
              raw.lpr_t_psyk_adm
              a, temp&tmpds b where a.v_cpr_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
          %end;
/* minipas */
          %if %sysfunc(indexw(%upcase(&source),MINIPAS))>0 %then %do;
              %do M=2002 %to &lastyr;
                  %if %sysfunc(exist(raw.minipas_t_adm&M)) %then %do;
                      %if &M=2002 %then create table &outpop.minipas_t_adm as;
                      %else insert into &outpop.minipas_t_adm ;
                      select distinct
                          a.k_recnum  , upcase("raw.minipas_t_adm&M") as table
                          from
                          raw.minipas_t_adm&M
                          a, temp&tmpds b where a.v_cpr_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
                  %end;
              %end;
          %end;

/* minipas_psyk*/
          %if %sysfunc(indexw(%upcase(&source),MINIPASPSYK))>0 %then %do;
              %do M=2002 %to &lastyr;
                  %if %sysfunc(exist(raw.minipas_t_psyk_adm&M)) %then %do;
                      %if &M=2002 %then create table &outpop.minipas_t_psyk_adm as;
                      %else insert into &outpop.minipas_t_psyk_adm ;
                      select distinct
                          a.k_recnum , upcase("raw.minipas_t_psyk_adm&M") as table
                          from
                          raw.minipas_t_psyk_adm&M
                          a, temp&tmpds b where a.v_cpr_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
                  %end;
              %end;
          %end;
/* MFR */
          %if %sysfunc(indexw(%upcase(&source),MFR))>0 %then %do;
              %do N=1997 %to &lastyr;
                  %if %sysfunc(exist(raw.mfr_mfr&N)) %then %do;
                      %if &N=1997 %then create table &outpop.mfr_mfr as;
                      %else insert into &outpop.mfr_mfr;
                      select distinct
                          a.pk_mfr , upcase("raw.mfr_mfr&N") as table
                          from
                          raw.mfr_mfr&N
                          a , temp&tmpds b where a.cpr_moder_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
                  %end;
              %end;
          %end;
/* LPR3-SB */ 
          %if %sysfunc(indexw(%upcase(&source),LPR3SB))>0 %then %do;
                  %if %sysfunc(exist(raw.lpr3_sb_kontakt)) %then %do;
                      create table &outpop.lpr3_sb_kontakt as
                      select distinct a.kontakt_id, a.forloebelement_id, upcase("raw.lpr3_sb_kontakt") as table
                          from raw.lpr3_sb_kontakt a , temp&tmpds b
                          where a.personnummer_encrypted=b.pnr and &ajour between a.rec_in and a.rec_out;
                  %end;
                  %if %sysfunc(exist(raw.lpr3_sb_diagnose)) %then %do;
                      create table &outpop.lpr3_sb_diagnose as
                      select distinct a.diagnose_id, upcase("raw.lpr3_sb_diagnose") as table
                          from raw.lpr3_sb_diagnose a , &outpop.lpr3_sb_kontakt b
                          where a.kontakt_id=b.kontakt_id;
                  %end;
                  %if %sysfunc(exist(raw.lpr3_sb_procedurer)) %then %do;
                      create table &outpop.lpr3_sb_procedurer as
                      select distinct a.procedurer_id, upcase("raw.lpr3_sb_procedurer") as table
                          from raw.lpr3_sb_procedurer a , &outpop.lpr3_sb_kontakt b
                          where a.kontakt_id=b.kontakt_id;
                  %end;
          %end;
/* NEW TYPES ADD ON HEREAFTER */
      %sqlquit;
	/*For checking error/warning types*/
	* %put sqlobs=**&sqlobs** sqloops=**&sqloops** sqlrc=**&sqlrc**; ;
  %runquit;
  proc datasets nolist;
    delete temp&tmpds;
  %runquit;
%mend;
