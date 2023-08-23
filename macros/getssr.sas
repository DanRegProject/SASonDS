%macro getSSR(outlib=work, provider=1 2 3 4 5 01 02 03 04 05, service=, basedata=, fromyear=1990);
  %local N I;

  %start_timer(getSSR); /* measure time for this macro */

  %findingSSR(&outlib..SSRALL, provider=&provider, service=&service, basedata=&basedata, fromyear=&fromyear);

  %end_timer(getSSR, text=Measure time for GetSSR macro);
%mend;


%macro findingSSR(outdata, provider=, service=, basedata=, fromyear=);

  %local localoutdata lastyrbak yr ;
  %let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */

  /* log eksekveringstid */
  %put start findingSSR: %qsysfunc(datetime(), datetime20.3);
  %let startSSRtime = %qsysfunc(datetime());
   %let lastyr=%sysfunc(today(),year4.);
  %do %while (%sysfunc(exist(raw.ssr_t_ssik&lastyr))=0);
      %let lastyr=%eval(&lastyr - 1);
      %end;

    %do yr=&fromyear %to &lastyr;
    proc sql inobs=&sqlmax;
    %if &yr=&fromyear %then create table &localoutdata as;
    %else insert into &localoutdata ;
    select a.v_cpr_encrypted as pnr label="pnr",
    a.c_ydelsesnr as service label="Service", a.c_ytype as provider label="Provider",
    a.v_antydel as nservice  label="Number of services",
    a.v_kontakt as ncontacts label="Number of contacts",
    input(put(a.v_honaar+2000-100*(a.v_honaar>80),4.)||"W"||put(a.v_honuge,z2.)||"01",weekv9.) as ssrdate format=date. label="Date of GP payment for service",
    a.rec_in format=date., a.rec_out format=date.
    from raw.ssr_t_ssik&yr a
    %if &basedata ne %then inner join &basedata c on a.v_cpr_encrypted=c.pnr;
    %if &provider ne or &service ne %then %do;
    where
        %if &provider ne %then
            trim(left(a.c_ytype)) in ( %quotelst(&provider, quote=%str(%"),delim=%str(, )));
        %if &provider ne and &service ne %then
            and;
        %if &service ne %then
            trim(left(a.c_ydelsesnr)) in ( %quotelst(&service, quote=%str(%"),delim=%str(, )));
    %end;
    ;
    quit;
  %end;
 proc sort data=&localoutdata out=&outdata;
   by pnr ssrdate provider service;
%RunQuit;
 %cleanup(&localoutdata);

data _null_;
  endSSRtime = datetime();
  timeSSRdif=endSSRtime-&startSSRtime;
  put 'executiontime FindingSSR ' timeSSRdif:time20.6;
  run;
%mend;






