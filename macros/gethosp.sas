/*
  getHosp();
  the macro findingHOSPperiods finds periods of hospital admissions.
  the macro smoother smoothes periods of admission, joining them if there is 1 day our less between admission.
*/

%MACRO getHosp(outdata, basedata=,  fromyear=1977);
  %LOCAL localoutdata yr dsn1;
  /* log hastighed */
  %PUT start getHosp: %qsysfunc(datetime(), datetime20.3);
  %LET startHOSPtime = %qsysfunc(datetime());

  %LET localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */

  %PUT &basedata;
  %LET lastyrGH=%sysfunc(today(),year4.); /*local lastyr for getHosp*/
  %DO %while (%sysfunc(exist(master.lpr_adm&lastyrGH))=0);
      %LET lastyrGH=%eval(&lastyrGH - 1);
  %END;
  %DO %while (%sysfunc(exist(master.lpr_adm&fromyear))=0);
      %LET fromyear=%eval(&fromyear + 1);
  %END;

  %LOCAL FIRST;
  %LET FIRST=1;
  proc sql inobs=&sqlmax;
    %DO yr=&fromyear %TO &lastyrGH;
      %LET dsn1=master.lpr_adm&yr;      
	  %LET dsn2=master.lpr_bes&yr;
	  %IF &first=1 %THEN create table &localoutdata as;
	  %ELSE insert into &localoutdata;
	  %LET first=0;
	  select
              a.pnr,
              a.start as indate label="indate",
              a.slut as outdate label="outdate",
              dhms(a.start,%IF %VAREXIST(&dsn1,indtime) %THEN  case a.indtime when . then 11 else a.indtime end ; %ELSE 11;,
              %IF %VAREXIST(&dsn1,indminut) %THEN case a.indminut when . then 59 else a.indminut end ; %ELSE 59;,00) as starttime format=datetime.,
              case a.slut when . then . else dhms(a.slut,11,59,00) end as endtime format=datetime.,
              a.slut-a.start as hospdays,
              year(a.start) as year label="year", 
			%IF %SYSFUNC(exist(&dsn2)) %THEN
			b.ambdto; %ELSE .; as ambdate,
			a.prioritet as priority length=6 format=$6.,
			a.pattype as patienttype,
		    a.shak_sgh_ans as hospital length=30 format=$30. label="hospital",
            a.shak_afd_ans as hospitalunit length=30 format=$30. label="hospitalunit",
            a.adiag as diagnose length=10 format=$10. label="diagnose"
          from
             &dsn1 a
              %IF %SYSFUNC(exist(dsn2)) %THEN 	
				left join &dsn2 b
				on a.kontakt_id=b.kontakt_id;
			  %IF &basedata ne %THEN join &basedata c on a.pnr=c.pnr ;
			  ;
  %END;
%LET dsn3=master.LPR_F_kontakter2022;
%IF %sysfunc(exist(&dsn3))=1 %THEN %DO;
   	  %IF &fromyear<2019 and %sysfunc(exist(&localoutdata))=1 %THEN insert into &localoutdata;
          %ELSE create table &localoutdata as;
	  select
			a.pnr,
			a.start as indate format=date.,
			a.slut as outdate format=date.,
			dhms(a.start,0,0,a.starttid) as starttime,
			dhms(a.slut,0,0,a.sluttid) as endtime,
			case a.slut when . then . else slut-start end as hospdays,
			year(start) as year,
			case when a.kontakttype="ALCA00" and
			          a.prioritet="ATA3" and
					  a.start=a.slut 
			     then a.start else .
				 end as ambdate,
			a.prioritet as priority length=6 format=$6.,
			"" as patienttype,
			a.sorenhed_ans as hospital length=30 format=$30. label="hospital",
			a.sorenhed_ans as hospitalunit length=30 format=$30. label="hospital",
			a.adiag as diagnose length=10 format=$10. label="diagnose"
			from
              &dsn3  a
              %IF &basedata ne %THEN join &basedata c
               on a.pnr=c.pnr ;
              where upcase(a.kontakttype) in ("ALCA00","ALCA10");
        %END;
  %SqlQuit;

  data &localoutdata;
	  set &localoutdata;
	  if ambdate ne . then do;
	  	indate=ambdate; outdate=ambdate; hospdays=0;
	  	starttime=.; endtime=.;
	  end;
	keep pnr year indate outdate starttime endtime diagnose priority patienttype hospital hospitalunit;
  run;

%IF %SYSFUNC(exist(master.depclass)) %THEN %DO;
	proc sql;
	create table &localoutdata as
	select a.*, b.deptypetxt
	from &localoutdata a left join master.depclass b
	on a.hospital=b.hospital and strip(a.hospitalunit)=strip(b.hospitalunit) and 
	a.year between b.startyear and b.endyear;
	quit;
%END;

proc sort data=&localoutdata out=&outdata noduplicates;
	by pnr indate outdate starttime;
  run;


  %cleanup(&localoutdata);
 data _null_;
   endHOSPtime=datetime();
   timeHOSPdif=endHOSPtime - &startHOSPtime;
   put 'execution time GetHOSP ' timeHOSPdif:time20.6;
 run;

%MEND;
