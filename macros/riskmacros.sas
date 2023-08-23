/* SVN header
$Date: 2021-12-21 11:35:50 +0100 (ti, 21 dec 2021) $
$Revision: 318 $
$Author: wnm6683 $
$Id: riskmacros.sas 318 2021-12-21 10:35:50Z wnm6683 $
*/
/*#+CHANGELOG
    Date      Initials  Status
    03-10-16  JNK       Corrected hypertension, a CO was used instead of C0 in the diagnosis
    03-01-17  JNK       Initializing scores to 0  (if missing result is . - can cause problems with stata)
                        Fixing ChadS2Vasc score - only counting sex if female
    23-05-17  JNK       Updating with FLS changes from SDS (heartfailure etc.). Check sex-calculation in atriastroke (sex=2)
    02-06-17  JNK       Renin_red replaced with Renin - introduced in last update
    02-07-17  FLS       Correcting sex=2 within addition return missing, corrected to (sex="2") to return boolian also changed AND to OR in HF_chads
*/
/* this macro will store tables with risk-scores in your data library and documentation in the &docpath library. */
%macro riskmacros (basetable, IndexDate, risktable, indicators, nof_days, docpath, ajour, MergeToInputTable=TRUE);
/* docpath:        Documentation of how calculations are done. Results are stored as txt files in the path directory */
/* IndexDate:      Date for riskcalculation */
/* basetable:      must include pnr and IndexDate */
/* risktable:      Name of resulting table with riskscores */
/* indicators:     Name of resulting table with comorbidity indicators */
/* ajour:          Using only tables that are valid at the time of &ajour */
/* nof_days:       Counting the period from &IndexDate-nof_days to &IndexDate when calculating hypertension */
  %local M riskvarATC riskvarLPR riskvarN riskvarATCN riskvarLPRN hasbledindi chadsvascindi chadsindi atriastrokeindi atriableedindi orbitindi;
  %let riskvarATC      = loop DIABATC Aspirin Clopi NSAID Thien renin;
  %let riskvarLPR      = hyplpr HFstr LVD DIABLPR Istroke SE TIA PADvasc Aplaq MIstr Renal GIbleed ICbleed impbleed genbleed ocbleed /*Ibleed Mbleed3 Gbleed2 TIBleed*/ Alco Liver Mrenal Anemia;
  %let riskvarN        = %sysfunc(countw(&riskvarATC &riskvarLPR));
  %let riskvarATCN     = %sysfunc(countw(&riskvarATC));
  %let riskvarLPRN     = %sysfunc(countw(&riskvarLPR));
  %let hasbledindi     =  hypertension_hasbled&IndexDate renal_hasbled&IndexDate liver_hasbled&IndexDate stroke_hasbled&IndexDate bleeding_hasbled&IndexDate drugs_hasbled&IndexDate alcohol_hasbled&IndexDate;
  %let chadsvascindi   =  hypertension_chadsvasc&IndexDate hf_chadsvasc&IndexDate diabetes_chadsvasc&IndexDate stroke_chadsvasc&IndexDate vascular_chadsvasc&IndexDate;
  %let chadsindi       =  hypertension_chads&IndexDate hf_chads&IndexDate diabetes_chads&IndexDate stroke_chads&IndexDate;
  %let atriastrokeindi =  hypertension_atriastroke&IndexDate proteinuria_atriastroke&IndexDate renal_atriastroke&IndexDate hf_atriastroke&IndexDate diabetes_atriastroke&IndexDate;
  %let atriableedindi  =  hypertension_atriableed&IndexDate bleeding_atriableed&IndexDate renal_atriableed&IndexDate anemia_atriableed&IndexDate ;
  %let orbitindi       =  renal_orbit&IndexDate antiplat_orbit&IndexDate bleeding_orbit&IndexDate anemia_orbit&IndexDate;

  %macro ATCrisk(name, count=1, date= , before=);  ((&name >= &count) AND (&name ne .)) %if "&before" ne "" AND "&date" ne "" %then  AND (eksd>= &Date - &before);  %mend;
  %macro LPRrisk(name, date, before=); ((&name <= &Date) AND (&name ne .)) %if "&before" ne "" %then AND (&date - &name.l < &before);  %mend;

  %let localbasetable = %NewDatasetName(localbasetable);
	  data &localbasetable; set &basetable;
	  keep pnr &indexdate;
  %runquit;
	  proc sort data=&localbasetable nodupkey;
	  by pnr &indexdate;
  %runquit;

/* store documentation in destination path (docpath) */
  %risk_documentation(&docpath);
  /* merge LPR input tables and reduce to valid table at &ajour time */
  /* LPR tables are only one line per pnr *//* this has changed now lpr has all rows, to be able to find last record before indexdate */
  %findLPRrisktables(&localbasetable, work.giantLPRtable, &IndexDate, &nof_days, &ajour);
  /* create a similar table for medication, check for drug use within the &nof_days period */
  %findATCrisktables(&localbasetable, work.giantATCtable, &IndexDate, &nof_days, &ajour);
  /* calculate hypertension */
  %findhypertension(&localbasetable, &IndexDate, work.hyp, &nof_days, &ajour);
  /* add age */
  proc sql;
    create table work.pop
    as select a.pnr, a.sex, a.birthday, b.&IndexDate as riskdate
    from
    risklib.riskpopulation a, &localbasetable b where a.pnr=b.pnr  and &ajour between a.rec_in and a.rec_out
    order by pnr, riskdate;
  quit;
  /* merge hypertension with the other risks, calculate at the end */
 data %if &risktable ne %then &risktable&IndexDate(keep=pnr &IndexDate hasbled&IndexDate chads2&IndexDate cha2ds2vasc&IndexDate atriastroke&IndexDate atriableed&IndexDate orbit&IndexDate);
    %if &indicators ne %then &indicators&IndexDate(keep=pnr &IndexDate sex age&IndexDate age65&IndexDate age75&IndexDate &hasbledindi &chadsvascindi &chadsindi &atriastrokeindi &atriableedindi &orbitindi);;
    merge work.giantLPRtable work.hyp work.giantATCtable work.pop (in = a);
    by pnr riskdate;
	if a; /* only continue if information is stored in work.pop */
    format riskdate &IndexDate date9.;
	/* set format explicit! */
	format hasbled&IndexDate cha2ds2vasc&IndexDate chads2&IndexDate  atriastroke&IndexDate atriableed&IndexDate orbit&IndexDate
           hf_chads&IndexDate hf_chadsvasc&IndexDate hf_atriastroke&IndexDate diabetes_chadsvasc&IndexDate diabetes_chads&IndexDate diabetes_atriastroke&IndexDate
           stroke_chads&IndexDate stroke_atria&IndexDate stroke_hasbled&IndexDate  stroke_atriastroke&IndexDate  stroke_chadsvasc&IndexDate
           vascular_chadsvasc&IndexDate liver_hasbled&IndexDate  bleeding_hasbled&IndexDate bleeding_atriableed&IndexDate  bleeding_orbit&IndexDate
           drugs_hasbled&IndexDate  alcohol_hasbled&IndexDate  renal_hasbled&IndexDate  renal_atriastroke&IndexDate renal_atriableed&IndexDate
           renal_orbit&IndexDate hypertension_hasbled&IndexDate  hypertension_chads&IndexDate hypertension_chadsvasc&IndexDate hypertension_atriastroke&IndexDate
           hypertension_atriableed&IndexDate proteinuria_atriastroke&IndexDate anemia_atriableed&IndexDate anemia_orbit&IndexDate antiplat_orbit&IndexDate 4.;
   format  age&IndexDate age65&IndexDate age75&IndexDate 4.;
   &IndexDate = riskdate;

    if birthday ne . then Age&IndexDate   =  intck('year', birthday, riskdate); /* use SAS date calculation and get exact number of years */
	if Age&IndexDate eq . then Age&IndexDate = 0;; /* in case indexdate is the same as birthday */
    Age75&IndexDate = (Age&IndexDate>=75);
    Age65&IndexDate = (Age&IndexDate>=65);
    array atria_age           (0:3) (0 64 74 84); /* age > atria_age(x) */
    array atria_prior_stroke  (0:3) (8  7  7  9); /* scale if stroke    */
    array atria_no_stroke     (0:3) (0  3  5  6); /* scale if no stroke */
    atria_age_point&IndexDate = 0;

	%do M=1 %to &RISKhypN;
      %let name = %scan(&RiskHyp, &M);
      if &name eq . then &name = 0;
    %end;

/* FLS rettet HF definition */

    hf_chads&IndexDate                 = %LPRrisk(hfstr, riskdate) OR (%ATCrisk(loop) AND %ATCrisk(Renin));
    hf_chadsvasc&IndexDate             = hf_chads&IndexDate /*OR %LPRrisk(LVD,riskdate)*/;
    hf_atriastroke&IndexDate           = hf_chads&IndexDate;
    diabetes_chadsvasc&IndexDate       = %LPRrisk(diabLPR,riskdate) OR %ATCrisk(diabATC,count = 2);
    diabetes_chads&IndexDate           = diabetes_chadsvasc&IndexDate;
    diabetes_atriastroke&IndexDate     = diabetes_chadsvasc&IndexDate;
    stroke_chads&IndexDate             = %LPRrisk(istroke,riskdate) OR %LPRrisk(TIA,riskdate);
    stroke_atria&IndexDate             = %LPRrisk(istroke,riskdate);
    stroke_hasbled&IndexDate           = stroke_chads&IndexDate;
    stroke_atriastroke&IndexDate       = %LPRrisk(istroke,riskdate);
    stroke_chadsvasc&IndexDate         = stroke_chads&IndexDate OR %LPRrisk(SE,riskdate);
    vascular_chadsvasc&IndexDate       = (%LPRrisk(mistr,riskdate) OR %LPRrisk(PADvasc,riskdate)/* OR %LPRrisk(Aplaq,riskdate)*/);
    liver_hasbled&IndexDate            = %LPRrisk(liver,riskdate);
    bleeding_hasbled&IndexDate         = %LPRrisk(GIbleed,riskdate) OR %LPRrisk(icbleed,riskdate) OR %LPRrisk(impbleed,riskdate) OR %LPRrisk(genbleed,riskdate) OR %LPRrisk(ocbleed,riskdate);
    bleeding_atriableed&IndexDate      = bleeding_hasbled&IndexDate;
    bleeding_orbit&IndexDate           = bleeding_hasbled&IndexDate;
    drugs_hasbled&IndexDate            = %ATCrisk(Aspirin,date=riskdate,before=0.5*&YearInDays) OR %ATCrisk(Clopi,date=riskdate,before=0.5*&YearInDays) OR %ATCrisk(NSAID,date=riskdate,before=0.5*&YearInDays);
    alcohol_hasbled&IndexDate          = %LPRrisk(alco,riskdate,before=0.5*&YearInDays);
    renal_hasbled&IndexDate            = %LPRrisk(renal,riskdate);
    renal_atriastroke&IndexDate        = renal_hasbled&IndexDate;
    renal_atriableed&IndexDate         = renal_hasbled&IndexDate;
    renal_orbit&IndexDate              = renal_hasbled&IndexDate;
    hypertension_hasbled&IndexDate     = %ATCrisk(hypscore) OR %LPRrisk(hyplpr,riskdate,before=365.25);
    hypertension_chads&IndexDate       = hypertension_hasbled&IndexDate;
    hypertension_chadsvasc&IndexDate   = hypertension_hasbled&IndexDate;
    hypertension_atriastroke&IndexDate = hypertension_hasbled&IndexDate;
    hypertension_atriableed&IndexDate  = hypertension_hasbled&IndexDate;
    proteinuria_atriastroke&IndexDate  = %LPRrisk(mrenal,riskdate);
    anemia_atriableed&IndexDate        = %LPRrisk(anemia,riskdate);
    anemia_orbit&IndexDate             = anemia_atriableed&IndexDate;
    antiplat_orbit&IndexDate           = %ATCrisk(Aspirin) OR %ATCrisk(Thien);


    /* sørg for at nedenstående udregninger ender i dokumentationen */
    hasbled&IndexDate     = hypertension_hasbled&IndexDate + renal_hasbled&IndexDate + liver_hasbled&IndexDate + stroke_hasbled&IndexDate + bleeding_hasbled&IndexDate + age65&IndexDate + drugs_hasbled&IndexDate + alcohol_hasbled&IndexDate;
    cha2ds2vasc&IndexDate = hypertension_chadsvasc&IndexDate + hf_chadsvasc&IndexDate + age65&IndexDate + age75&IndexDate + diabetes_chadsvasc&IndexDate + (stroke_chadsvasc&IndexDate*2) + vascular_chadsvasc&IndexDate + sex;
    chads2&IndexDate      = hypertension_chads&IndexDate + hf_chads&IndexDate + age75&IndexDate + diabetes_chads&IndexDate + (stroke_chads&IndexDate*2);


   /* calculate input from age in ATRIA score */

  %do M=0 %to 3;
     if (age&IndexDate > atria_age(&M)) then do;
       if stroke_atria&IndexDate>0 then atria_age_point&IndexDate = atria_prior_stroke(&M);
	   else atria_age_point&IndexDate = atria_no_stroke(&M);
      end;
    %end;

    atriastroke&IndexDate  = hypertension_atriastroke&IndexDate + proteinuria_atriastroke&IndexDate + renal_atriastroke&IndexDate + hf_atriastroke&IndexDate + sex + diabetes_atriastroke&IndexDate + atria_age_point&IndexDate;
    /* FLS Rettet vægte i atriableed */
    atriableed&IndexDate   = 3*anemia_atriableed&IndexDate + hypertension_atriableed&IndexDate + 3*renal_atriableed&IndexDate + 2*age75&IndexDate + bleeding_atriableed&IndexDate;
    orbit&IndexDate        = age75&IndexDate + 2*anemia_orbit&IndexDate + 2*bleeding_orbit&IndexDate + renal_orbit&IndexDate + antiplat_orbit&IndexDate;


 /* 03/01-2017 set missing scores to zero */
    /* 03/01-2017 set missing scores to zero */
    if hasbled&IndexDate     = . then hasbled&IndexDate = 0;
    if cha2ds2vasc&IndexDate = . then cha2ds2vasc&IndexDate = 0;
    if chads2&IndexDate      = . then chads2&IndexDate = 0;
    if atriastroke&IndexDate = . then atriastroke&IndexDate = 0;
    if atriableed&IndexDate  = . then atriableed&IndexDate = 0;
    if orbit&IndexDate       = . then orbit&IndexDate = 0;
  %runquit;
  /* merge result on &basetable */
  %if &MergeToInputTable = TRUE %then %do;
    %if &risktable ne or &indicators ne %then %do;
      data &basetable;
        merge &basetable &risktable&IndexDate &indicators&IndexDate;
	    by pnr &indexdate;
      %runquit;
    %end;
  %end;
%cleanup(&localbasetable);
%mend;
/* find the diagnosis tables with pnr in common with basetable */
%macro findLPRrisktables(basetable, outputtable, IndexDate, nofdays, ajour);
  %local M var;

/* find last observation before indexdate and collapse data into one row */
  %do M = 1 %to &RiskvarLPRN;
      %let var = %scan(&RiskvarLPR,&M);
                proc sql;
                    create table risk&var as
                        select a.*, b.&indexdate
                        from
                        risklib.&var as a
                        left join &basetable as b
                        on a.pnr = b.pnr and b.&indexdate ge &var;
                quit;
                run;

                proc sort data=risk&var;
                    by pnr &var;
                run;


                data risk&var.red;
                    set risk&var;
                    by pnr &var;
                    retain tempfirst templast;

                    if first.pnr then tempfirst = &var;
                    templast = &var;

                    &var = tempfirst;
                    &var.l = templast;

                    format &var date.;
                    format &var.l date.;
                    drop tempfirst;
                    drop templast;
                    if last.pnr;
                run;

 %end;






  /* merge all LPR input with valid timestamp */
  data work.LPRtable;
    merge
      %do M=1 %to &RiskvarLPRN;
        %let var = %scan(&RiskvarLPR, &M);
        risk&var.red
      %end;
      ;
      where &ajour between rec_in and rec_out;
      by pnr;
    %runquit;
    /* select only pnr from &basetable */;
    proc sql;
      create table work.risktable
      as select a.*, b.&IndexDate as riskdate
      from
      work.LPRtable a, &basetable b where a.pnr=b.pnr
          and &ajour between a.rec_in and a.rec_out
      order by pnr, riskdate;
    quit;
    /* create the outputtable with one single line pr pnr/riskdate */
    data &outputtable;
      set work.risktable;
      by pnr riskdate;
      %do M=1 %to &riskvarLPRN;
        retain temp&M;
      %end;
      /* save first set of variables in temp for each riskdate */
      if first.riskdate then do;
        %do M=1 %to &riskvarLPRN;
          %let var = %scan(&riskvarLPR,&M);
          temp&M = &var;
        %end;
      end;
      if last.riskdate then do;
        %do M=1 %to &riskvarLPRN;
          %let name = %scan(&riskvarLPR,&M);
          if &name eq . then &name = temp&M;
          drop temp&M;
        %end;
      end;
      if first.riskdate = 0 and last.riskdate = 0 then do;
      /* more than two lines of data to merge */
        %do M=1 %to &riskvarLPRN;
          %let name = %scan(&riskvarLPR, &M);
          if &name ne . and &name < temp&M then temp&M = &name;
          /* replace information in temp&M if it is present in this line and the date is prior to the temp&M date */
        %end;
      end;
      if last.riskdate then output;
        drop rec_in rec_out;
      run;
    %mend;
   /* find the medicines with pnr in common with basetable */
%macro findATCrisktables(basetable, outputtable, IndexDate, nof_days, ajour);
  %local Q var name;
  data work.riskATC;
    merge
    %do Q=1 %to &riskvarATCN;
      %let var = %scan(&RISKvarATC, &Q);
      risklib.&var
    %end;
    ;
    by pnr eksd;
    where &ajour between rec_in and rec_out;
  %runquit;
  /* select only pnr from &basetable, within &ajour-period and with ekspedition date from &IndexDate-nofdays to &IndexDate */
  proc sql;
    create table work.ATCtable as
    select a.*, b.&IndexDate as riskdate
    from work.riskATC a, &basetable b
    where a.pnr=b.pnr and &ajour between rec_in and rec_out and
    a.eksd between (b.&IndexDate-&nof_days) and b.&IndexDate
    order by pnr, riskdate, eksd;
  %sqlquit;

  /* convert &name to numeric  */
  data work.ATCtable;
    set work.ATCtable;

    %do Q=1 %to &RiskvarATCN;
      %let name = %scan(&RiskvarATC, &Q); /* names are corresponding to the defines in ATCkoder.sas */
	  *&name.num = input(&name,4.); /* convert to num */
	  *drop &name; /* dump the variable holding the char value */
	%end;
  %runquit;


  /* reduce to a single line for each pnr/riskdate */
  data &outputtable;
    set work.ATCtable;
    by pnr riskdate eksd;
    retain
      %do Q=1 %to &RiskvarATCN;
        h&Q
      %end;
      ; /* h1 h2 h3 h4 h5; */
    if first.riskdate then do;
    /* reset all temp variables */
      %do Q=1 %to &RiskvarATCN;
        h&Q = 0;
      %end;
    end;
    /* count H&Q */
    %do Q=1 %to &RiskvarATCN;
      %let name = %scan(&RiskvarATC, &Q); /* names are corresponding to the defines in ATCkoder.sas */
      h&Q = sum(h&Q, &name);
      if last.riskdate and last.eksd then do;
        &name = h&Q;
      end;
    %end;
    if last.riskdate and last.eksd then do;
      keep pnr riskdate &riskvarATC eksd;
      output;
    end;
  %runquit;
%mend;
/* collect hypertension data according to pnr and ajour */
%macro findhypertension(basetable, IndexDate, outputtable, nofdays, ajour);
  %local I U name;
  /* select only pnr from &basetable, within the ajour-period and with ekspedition date from &IndexDate-nofdays to &IndexDate */
  proc sql;
    create table work.hyptemp as
    select a.*, b.&IndexDate as riskdate
    from risklib.hypall a, &basetable b
    where a.pnr=b.pnr and &ajour between a.rec_in and a.rec_out and
    a.eksd between (b.&IndexDate - &nofdays) and b.&IndexDate;
  %sqlquit;
  proc sort data=work.hyptemp;
    by pnr riskdate eksd;
  %runquit;
  data &outputtable;
    set work.hyptemp;
    by pnr riskdate eksd;
	/* specify format for h&I and the names from the hypertension list */
	format
	%do I=1 %to &RISKhypN;
      %let name = %scan(&riskHyp, &I);
	  &name.hyp h&I
    %end;
	hypscore hyp1score 4.;
    /* keep temp values for each pnr */
    retain
    %do I=1 %to &RISKhypN;
      h&I
    %end;
  ; /* h1 h2 h3 h4 h5 h6; */
    if first.riskdate then do;
    /* reset all temp variables */
      %do I=1 %to &RiskhypN;
        h&I = 0;
      %end;
    end;
    /* JNK tjek her! */
    /* count H&I */
    %do I=1 %to &riskhypN;
      %let name = %scan(&riskHyp, &I);
      if h&I = 0 then do;
        if find(&name, 'C0', 'i') ge 1 then h&I = 1; /* not in the combination drug list, weight 1 */
      end;
      /* check for at combination drug */
      if h&I eq 1 then do;
        %do U=1 %to &RiskHypCompN;
          %let drug = &&RISKhypComp&U;
          if index(&name,"&drug")>0 then do;
            h&I = 2; /* on the combination list, weight 2 */
*            put "combination drug: &name is &drug, " &&RiskLHypComp&U;
          end;
        %end;
      end;
      &name.hyp = h&I ;
    %end;
    if last.riskdate and last.eksd then do;
      hypscore = 0; /* reset hypscore */
      %do I=1 %to &riskHypN;
        hypscore  = hypscore + h&I;
      %end;
      hyp1score = hypscore;    /* sum of hypscore, kept for testing/control */
      hypscore = hypscore > 1; /* hypertension if the score is greater than or equal to 2 */
      output;
    end;
    keep pnr eksd riskdate hypscore hyp1score
    %do I=1 %to &RISKhypN;
      %let name = %scan(&RISKHyp, &I);
      &name.hyp
    %end; /* keep all &names */
    ;
  %runquit;
%mend;
%macro RISK_documentation(path);
  data _null_;
    file "&path\chads2_description.txt";
    put " The CHADS2 score calculation is based on: ";
    put " | Component         | Prefix                                   | Weight | ";
    put " |-------------------+------------------------------------------+--------| ";
    put " | Heart failure     | hfstr or (loop AND Renin)                 | 1      | ";
    put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
    put " |                   | or combination drug                      |       | ";
	put " | 				  | or hypLPR < 365.25 days					 | 1      | ";
	put " | Age               | Age>75                                   | 1      | ";
    put " | Diabetes          | DiabLPR or DiabATC                       | 1      | ";
    put " | Stroke            | Istroke or TIA                           | 2      | ";
    put " ";
  %runquit;
  /* prefix description in separate tables: */
  %create_datalist(ATC, &path, HFatc Alfa Nonloop Vaso Beta Calcium Renin DiabATC, chads2_atc);
  %create_datalist(LPR, &path, HF2 DiabLPR Istroke TIA, chads2_lpr);
  %create_datalist(RISK, &path, &RISKhypComp, hyp_comp);
  data _null_;
    file "&path\cha2ds2vasc_description.txt";
  put "  The CHA2DS2-VASc score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Heart failure     | (hfstr or (loop and Renin))        | 1      | ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                   | or combination drug or hypLPR < 365.25 days                    | 1      | ";
  put " | Age               | Age>=75                                  | 1      | ";
  put " | Age               | Age>=65                                  | 1      | ";
  put " | Diabetes          | DiabLPR or DiabATC > 1                       | 1      | ";
  put " | Stroke            | Istroke or SE or TIA                     | 2      | ";
  put " | Vascular Disease  | MI or PAD3                       | 1      | ";
  put " | Sex               | Female sex                               | 1      | ";
  put " ";
  %runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, HFatc Alfa Nonloop Vaso Beta Calcium Renin DiabATC, cha2ds2vasc_atc);
%create_datalist(LPR, &path, HF2 LVD DiabLPR Istroke TIA SE MI PAD3 APLAQ, cha2ds2vasc_lpr);
data _null_;
  file "&path\HASBLED_description.txt";
  put "  The HAS-BLED score alculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                   | or combination drug or hypLPR < 365.25 days                     | 1      | ";
  put " | Renal Disease     | Renal                                    | 1      | ";
  put " | Liver Disease     | Liver                                    | 1      | ";
  put " | Stroke            | Istroke or TIA                           | 1      | ";
  put " | Bleeding          | GIbleed or ichbleed or impbleed 	       | 1      | ";
  put " | Age               | Age>=65                                  | 1      | ";
  put " | Drugs             | Aspirin or clopidogrel or NSAID          | 1      | ";
  put " | Alcohol           | Alco                                     | 1      | ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin Aspirin clopi nsaid, hasbled_atc);
%create_datalist(LPR, &path, Renal Liver Istroke TIA Ibleed Mbleed3 Gbleed2 TIbleed, hasbled_lpr);
data _null_;
  file "&path\atriastroke_description.txt";
  put "  The ATRIA Stroke score (0-12/0-15) calculation is based on: ";
  put " | Component         | Prefix                                   | Weight without           | Weight with              | ";
  put " |                   |                                          | prior stroke             | prior stroke             | ";
  put " |-------------------+------------------------------------------+--------------------------|--------------------------| ";
  put " | Age               | Age>=85                                  | 6                        | 9                        | ";
  put " | Age               | 75<=Age<85                               | 5                        | 7                        | ";
  put " | Age               | 65<=Age<75                               | 3                        | 7                        | ";
  put " | Age               | Age<65                                   | 0                        | 8                        | ";
  put " | Sex               | Female sex                               | 1                        | 1                        | ";
  put " | Diabetes          | DiabLPR or DiabATC > 1                       | 1                        | 1                        | ";
  put " | Heart failure     | hfstr and loop                            | 1                        | 1                        | ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |                          |                          | ";
  put " |                   | or combination drug or hypLPR < 365.25 days                      | 1                        | 1                        | ";
  put " | Proteinuria       | Mrenal                                   | 1                        | 1                        | ";
  put " | eGFR<45 pr ESRD   | Renal                                    | 1                        | 1                        | ";
  put " | Stroke            | Istroke                                  | used for age calculation | used for age calculation | ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin HFatc diabATC, atriastroke_atc);
%create_datalist(LPR, &path, Renal mrenal HF2 diabLPR Istroke TIA, atriastroke_lpr);
data _null_;
  file "&path\atriableed_description.txt";
  put "  The ATRIA Bleeding score (0-10) calculation is based on: ";
  put " | Component            | Prefix                                   | Weight | ";
  put " |----------------------+------------------------------------------+--------| ";
  put " | Anemia               | Anemia                                   | 3      | ";
  put " | dGFR<30 or dialysis  | Renal                                    | 3      | ";
  put " | Age                  | Age>=75                                  | 2      | ";
  put " | Bleeding             | GIbleed or ichbleed or impbleed 	      | 1      | ";
  put " | Hypertension         | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                      | or combination drug or hypLPR < 365.25 days                     | 1      | ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin , atriableed_atc);
%create_datalist(LPR, &path, Anemia Renal Ibleed Mbleed3 Gbleed2 TIbleed, atriableed_lpr);
  data _null_;
    file "&path\orbit_description.txt";
  put "  The ORBIT Bleeding score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Age               | Age>=75                                  | 1      | ";
  put " | Anemia/red.haem   | Anemia                                   | 2      | ";
  put " | Bleeding          | GIbleed or ichbleed or impbleed 	       | 2      | ";
  put " | <60mL/min/1.73m2  | Renal                                    | 1      | ";
  put " | Antiplatelet      | Aspirin or thienpyrides                  | 1      | ";
  %runquit;
  /* prefix description in separate tables: */
  %create_datalist(ATC, &path, Aspirin Thien , orbit_atc);
  %create_datalist(LPR, &path, Anemia Renal Ibleed Mbleed3 Gbleed2 TIbleed, orbit_lpr);
%mend;
