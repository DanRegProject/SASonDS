/* SVN header
$Date: 2022-05-12 09:38:22 +0200 (to, 12 maj 2022) $
$Revision: 333 $
$Author: wnm6683 $
$Id: reduceMediperiods.sas 333 2022-05-12 07:38:22Z wnm6683 $
*/
/*
  #+NAME
    %ReduceMediPeriods
  #+TYPE
    SAS
  #+DESCRIPTION
    Output data from %getMedi is reduced to treatment periods, with optional variables indicating if
    each period is before, including or after IndexDate.
    Multiple rows pr pnr each indicating a period of treatment.
    Enddate is estimated according to type:
    type 1: periods based on drug use per day pr person and ATC code (&drug). Enddate is estimated as last prescription
            date plus number of pills available in last purchase if dose is average pills per day in the period.
            If this enddate exceeds startdate of the next period, these periods are joined.
    type 2: periods based on individual dose based on the frequency of aquiring drugs per day per person and ATC code (&drug).
    type 3: periods based on days between prescriptions (look at a fixed period=InclusionDays).
    The macro is called outside a datastep.
  #+SYNTAX
    %ReduceMediPeriods(
      indata,           Input dataset name, should be output from %getMedi. Required.
      outdata,          Output dataset name. Required.
      drug,             Variable in indata identifying the drug. Required.
      type,             1: fixed dose strategy, 2: variable dose strategy. 3: Fixed period strategy, Required.
  Default - used for all types:
      ajour=            If set - reduce input dataset to ajour period.
      IndexDate=,       Date variable in indata or date constant, defining
                        the date of required treatment status. Optional.
      slipdays=1        Max. allowed days between subsequent prescriptions within same treatment.
      slipscale=1.5     How many pills do you forget - Allowed increase in observed grace period.
                        Should be 0 only if slipdays criteria is wanted.
      if slipdays is preferred to slipscale then set slipscale to a high number, and vice versa.
  TYPE 1:
      tabsperday,       number of tablets pr day.
  TYPE 2:
      stddosage,        initial standard dose.
      maxdosage,        upper limit of daily dosage.
      mindosage=.1      lower limit of daily dosage.
  TYPE 3:
      InclusionDays   Amount of days in a period from purchase (eksd date) until periodend.
  #+OUTPUT:
    pnr
    &IndexDate
    &drug
    startdate
    enddate
    nvisits
    if &type=2 dailydose
    if &type=1 maxpack= "highest number of tablets available in period"
  if &IndexDate is specified:
    &drug.Before&IndexDate = "Indicator, treatment period before inclusion event, &IndexDate";
    &drug.During&IndexDate = "Indicator, treatment period include inclusion event, &IndexDate";
    &drug.After&IndexDate  = "Indicator, treatment period after inclusion event, &IndexDate";
  #+AUTHOR
    Flemming Skjøth
  #+CHANGELOG
    Date        Initials  Status
    07-08-2014  fls       Documentation written, enddate truncated with floor()
    08-08-2014  fls       maxpack information included
    12-11-14    FLS       Added number of packages to code
    24-03-2017  JNK       Renamed to ReduceMediperiods, aligned naming to new concept. Added type 3.
*/
%macro reduceMediPeriods(indata, outdata, drug, type, IndexDate=, ajour=today(), slipscale=1.5, slipdays=1, tabsprday=, stddosage=, maxdosage=, mindosage=0.1, InclusionDays=,subset=,bydrug=FALSE,dosedata=);
  %if &type=1 and &tabsprday= %then %do;
      %put ERROR ReduceMediPeriods: tabsprday must be specified if type=1;
      %abort cancel;
      %end;
  %if &type=2 and &stddosage= %then %do;
      %put ERROR ReduceMediPeriods: stddosage must be specified if type=2;
      %abort cancel;
      %end;
  %if &type=2 and &dosedata ne %then %do;
      %if %varexist(&dosedata,&stddosage) = 0 %then %do;
		%put ERROR ReduceMediPeriods: stddosage must be included in &dosedata if type=2;
      	%abort cancel;
		proc sql;
		select max(ant) from (select pnr, count(*) as ant from &dosedata group by pnr) into :antdose;
		quit;
		%if &antdose>1 %then %do; 
			%put more than one dose pr pnr in &dosedata; 
			%abort cancel; 
		%end;
      %end;
%end;
%if &bydrug eq FALSE %then %do;
        proc sql noprint;
            select distinct &drug into :druglist separated by '_' from &indata;
            select length("&druglist") into :lendruglist from &indata(obs=1);
      %end;

  /* reduce dataset to ajour period */
    data _temp1_;
        %if &bydrug eq FALSE %then %do;
            length &drug $ &lendruglist;
            %end;
        set &indata
			%if &bydrug eq FALSE and %varexist(&indata,&drug)>0 %then %do;
            (drop=&drug)
            %end;
        ;
        %if "&ajour" ne "" OR "&subset" ne "" %then %do;
            where %if "&ajour" ne "" %then &ajour between rec_in and rec_out;
            %if "&ajour" ne "" AND "&subset" ne "" %then AND;
            %if "&subset" ne "" %then &subset;
            ;
            %end;
        %if &bydrug eq FALSE %then %do;
            &drug = "&druglist";
            %end;
    run;
  proc sort data=_temp1_ out=_temp1_;
    by pnr &drug eksd;
  %runquit;
  %if &type=2 and &dosedata ne %then %do;
    data _temp1_;
		merge _temp1_(in=a) &dosedata(in=b keep=pnr 
                %if %varexist(&dosedata,&stddosage)>0 and %varexist(_temp1_,&stddosage)=0 %then  &stddosage;
                %if %varexist(&dosedata,&mindosage)>0 and "&stddosage" ne "&mindosage" %then  &mindosage;
                %if %varexist(&dosedata,&maxdosage)>0 and "&stddosage" ne "&maxdosage" %then  &maxdosage;
				);
				by pnr;
				if a and b;
	%runquit;
/*
proc sql;
            create table _temp1_ as
                select a.*
                %if %varexist(&dosedata,&stddosage)>0 and %varexist(_temp1_,&stddosage)=0 %then , b.&stddosage;
                %if %varexist(&dosedata,&mindosage)>0 and "&stddosage" ne "&mindosage" %then , b.&mindosage;
                %if %varexist(&dosedata,&maxdosage)>0 and "&stddosage" ne "&maxdosage" %then , b.&maxdosage;
                from _temp1_ a, &dosedata b
                    where a.pnr=b.pnr
                    order by a.pnr, a.&drug, a.eksd;
                quit;
  */
%end;


  data _temp1_;
    set _temp1_;
    packsize = packsize*NPack;  /* packsize = antal købte tabletter (styk) i pakken, Npack = antal pakker */
    dosis    = strnum*packsize; /* antal WHO anbefalede doser pr køb */
  %runquit;
  /*Tag hensyn til at nogle får udskrevet flere recepter på samme drug samme dag */
  proc summary data=_temp1_ nway;
    by pnr &drug eksd;
    %if &IndexDate ne %then id &IndexDate;;
    var packsize dosis;
    %if &type=2 and &dosedata ne %then %do;
        id %if %varexist(_temp1_,&stddosage)>0 %then &stddosage;
           %if %varexist(_temp1_,&mindosage)>0 and "&stddosage" ne "&mindosage" %then &mindosage;
           %if %varexist(_temp1_,&maxdosage)>0 and "&stddosage" ne "&maxdosage" %then &maxdosage;
        ;
     %end;
    output out=_temp1_ sum=;
  %runquit;
  data &outdata;
    set _temp1_;
    by pnr &drug;
    retain startdate enddate nvisits %if &type=1 %then maxpack; %if &type=2 %then cumdosis dailydose ;;
    if first.&drug then do;
      nvisits=1;
      startdate=eksd;
      %if &type=1 %then %do;
        enddate=floor(startdate+packsize/&tabsprday);
        maxpack=packsize/&tabsprday;
      %end;
      %if &type=2 %then %do;
        dailydose=&stddosage;
        enddate=floor(startdate+dosis/dailydose);
        cumdosis=dosis;
      %end;
      %if &type=3 %then %do;
        enddate = startdate + &InclusionDays;
      /* enddate = startdate + inkluderingsperiode */
      %end;
    end;
    if first.&drug=0 then do;
      if enddate+min(&slipdays,%if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;)+1 ge eksd then do; /*+1 for at undgå at stoppe dagen før ny opstart*/;
        nvisits+1;
        %if &type=1 %then %do;
          enddate=floor(max(eksd,enddate)+packsize/&tabsprday) ;  /*=enddate ændret til =max(eksd,enddate)*/;
          maxpack=packsize/&tabsprday + max(0,(maxpack-(min(eksd,enddate)-startdate))); /* formodet antal dagsdoser tilrådighed nu */;
        %end;
        %if &type=2 %then %do;
          cumdosis=cumdosis+dosis;
          dailydose=min(&maxdosage,max((cumdosis-dosis)/(eksd-startdate),&mindosage));
          enddate=floor(startdate+cumdosis/dailydose); /*som ovenfor, da indløste piller bruges fremadrettet */;
        %end;
        %if &type=3 %then %do;
          enddate = eksd + &InclusionDays;
      /* enddate = eksd + inkluderingsperiode */
        %end;
      end;
      else do;
        enddate=floor(enddate+min(&slipdays, %if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;));
        output;
        startdate=eksd;
        nvisits=1;
        %if &type=1 %then %do;
          enddate=floor(startdate+packsize/&tabsprday);
          maxpack=packsize/&tabsprday;
        %end;
        %if &type=2 %then %do;
          dailydose=&stddosage;
          enddate=floor(startdate+dosis/dailydose);
          cumdosis=dosis;
        %end;
        %if &type=3 %then %do;
          enddate = startdate + &InclusionDays;
        /* enddate = startdate + inkluderingsperiode */
        %end;
      end;
    end;
    if last.&drug then do;
      enddate=floor(enddate+min(&slipdays,%if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;));
      output;
    end;
    label nvisits="Number of farmacy visits in treatment period";
    format startdate enddate date.;
  %runquit;
  DATA %if &IndexDate ne %then  _temp1_ _temp2_; _temp3_;
    SET &outdata;
    by pnr &drug;
    %if &IndexDate ne %then %do;
      &drug.Before&IndexDate=(&IndexDate>enddate);
      &drug.During&IndexDate=(&IndexDate>startdate AND &IndexDate<=enddate);
      &drug.After&IndexDate =(&IndexDate<=startdate);
      label &drug.Before&IndexDate= "&drug treatment period before &IndexDate";
      label &drug.During&IndexDate= "&drug treatment period before and at &IndexDate";
      label &drug.After&IndexDate=  "&drug treatment period after or starting at &IndexDate";
    %end;
    format startdate enddate date.;
    rename startdate = &drug.start;
    rename enddate   = &drug.end;
    label startdate  = "&drug treatment period start";
    label enddate    = "&drug treatment period end";
    keep pnr &drug &IndexDate startdate enddate nvisits
    %if &type=2 %then dailydose;
    %if &type=1 %then maxpack;
    %if &IndexDate ne %then &drug.before&IndexDate &drug.after&IndexDate &drug.during&IndexDate;; /* end of keep */
    %if &IndexDate ne %then %do;
      if &drug.before&IndexDate then output _temp1_;
      if &drug.during&IndexDate then output _temp2_;
      if &drug.after&IndexDate  then output _temp3_;
    %end;
    %else %do;
      &drug.after&IndexDate=1;
      output _temp3_;
    %end;
  %runquit;
  %if &IndexDate ne %then %do;
    proc sort data=_temp1_;
      by pnr &drug descending &drug.start;
    %runquit;
    data _Temp1_;
      set _temp1_;
      by pnr &Drug;
      if first.&drug then &Drug.Period&IndexDate=1;
      else &Drug.Period&IndexDate+1;
    %runquit;
    data _temp1_;
      set _temp1_;
      &drug.Period&IndexDate=-1*&drug.period&IndexDate;
    %runquit;
    data _temp2_;
      set _temp2_;
      &drug.Period&IndexDate=0;
    %runquit;
  %end;
  data _Temp3_;
    set _temp3_;
    by pnr &Drug;
    if first.&drug then &Drug.Period&IndexDate=1;
    else &Drug.Period&IndexDate+1;
  %runquit;
  data &outdata;
    set %if &IndexDate ne %then _temp1_ _temp2_;  _temp3_;
  %runquit;
  proc sort data=&outdata;
    by pnr &drug &drug.Period&IndexDate;
  %runquit;
  proc datasets nolist;
    delete %if &IndexDate ne %then _temp1_ _temp2_;  _temp3_;
  %runquit;
/* cleanup dataset - if no purchase of &drug, then reset to FALSE - blier vist renset fra start og indeholder derefter kun linier med IndexDate (hvis sat) */
  data &outdata;
    set &outdata;
      if &drug = "" then do;
        nvisits = 0;
        %if &IndexDate ne %then      &drug.before&IndexDate = 0;;
        &drug.Period&IndexDate = 0;
        %if &type=2 %then dailydose=0;;
        %if &type=1 %then maxpack=0;;
      end;
  %runquit;
%MEND;
