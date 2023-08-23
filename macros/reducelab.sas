/*
  macro %reduceLabStatus
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Output data from  %findingLab is reduced to a status at a specific time.
                     One row pr pnr. The macro is called outside a datastep";
  #+OUTPUT        :  pnr
                     &IndexDate
                     &drug
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  10-09-15    JNK      ported from DS
                  :
*/
/*
  macro %prereduceLabStatus
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Klargør til reduktion og omdøber alle inkluderede medicin til samme navn (npu).
                     f.eks.her hvor findingLab har samlet alt under A10, som default anvender
                     reduceLabStatus unikke npu koder, hvilket ikke ønskes her.
                     %prereduceLabStatus(DiabNPU, A10);
  #+CHANGELOG     :  Date        Initials Status
                  :  01-10-15    JNK      ported from DS
                  :
*/

%macro prereduceLabStatus(indata, outdata, grp, npu, IndexDate, ajour=);
%local localdata;
  %let localdata=%NewDatasetName(temp); /* temporært datasætnavn så data i work */

  data &localdata;
    set &indata;
	format &grp $10.; /* remove warning */
	NPU=analysiscode;
	&grp="&npu";
  run;
  %reduceLabStatus(&localdata, &outdata, &grp, &indexdate, NPU=NPU, ajour=&ajour);
  %cleanup(&localdata);

%mend;


%macro reduceLabStatus(indata, outdata, analysis, IndexDate, npu=, ajour=today());
%local temp;
%let temp=%NewDatasetName(temp);

%if &npu= %then %let npu=&analysis;
proc sort data=&indata;
  by pnr &IndexDate samplingdate;
run;
data &temp;
  set &indata;
  afterbase=1;
  %if &IndexDate ne %then %do;
    afterbase=(samplingdate ge &IndexDate);
  %end;
  where &ajour between rec_in and rec_out;
run;
data &outdata;
  set &temp;
  by pnr &IndexDate afterbase;
  length %if &IndexDate ne %then %do;
          &analysis.LaLabUBe&IndexDate
          &analysis.FiLabUBe&IndexDate
		  &analysis.LaLabCBe&IndexDate
          &analysis.FiLabCBe&IndexDate
		  &analysis.LaLabSBe&IndexDate
          &analysis.FiLabSBe&IndexDate
  %end;
  &analysis.FiLabUAf&IndexDate
  &analysis.FiLabCAf&IndexDate
  &analysis.FiLabSAf&IndexDate $17;

  retain %if &IndexDate ne %then %do;
          &analysis.LaLabVBe&IndexDate
          &analysis.LaLabDBe&IndexDate
          &analysis.FiLabVBe&IndexDate
          &analysis.FiLabDBe&IndexDate
          &analysis.LaLabUBe&IndexDate
          &analysis.FiLabUBe&IndexDate
		  &analysis.LaLabCBe&IndexDate
          &analysis.FiLabCBe&IndexDate
		  &analysis.LaLabSBe&IndexDate
          &analysis.FiLabSBe&IndexDate
  %end;
  &analysis.FiLabDAf&IndexDate
  &analysis.FiLabVAf&IndexDate
  &analysis.FiLabUAf&IndexDate
  &analysis.FiLabCAf&IndexDate
  &analysis.FiLabSAf&IndexDate;
  format %if &IndexDate ne %then %do;
    &analysis.LaLabDBe&IndexDate
	&analysis.FiLabDBe&IndexDate
  %end;
  &analysis.FiLabDAf&IndexDate date.;
  if %if &IndexDate ne %then first.&IndexDate; %else first.pnr; then do;
    %if &IndexDate ne %then %do;
	  &analysis.LaLabDBe&IndexDate=.;   &analysis.LaLabVBe&IndexDate=.;
	  &analysis.FiLabDBe&IndexDate=.;   &analysis.FiLabVBe&IndexDate=.;
	  &analysis.LaLabUBe&IndexDate="";   &analysis.LaLabCBe&IndexDate="";
	  &analysis.FiLabUBe&IndexDate="";   &analysis.FiLabCBe&IndexDate="";
	  &analysis.FiLabSBe&IndexDate="";   &analysis.LaLabSBe&IndexDate="";
	%end;
	&analysis.FiLabDAf&IndexDate=.;     &analysis.FiLabVAf&IndexDate=.;
	&analysis.FiLabUAf&IndexDate="";    &analysis.FiLabCAf&IndexDate="";
	&analysis.FiLabSAf&IndexDate="";
  end;
  %if &IndexDate ne %then %do;
    if first.afterbase and afterbase=0 then do;
	  &analysis.FiLabDBe&IndexDate=samplingdate;       &analysis.FiLabVBe&IndexDate=valuenum;
	  &analysis.FiLabUBe&IndexDate=Unit;               &analysis.FiLabCBe&IndexDate=analysiscode;
	  &analysis.FiLabSBe&IndexDate=value;
	end;
	if last.afterbase and afterbase=0 then do;
	  &analysis.LaLabDBe&IndexDate=samplingdate;       &analysis.LaLabVBe&IndexDate=valuenum;
	  &analysis.LaLabUBe&IndexDate=unit;               &analysis.LaLabCBe&IndexDate=analysiscode;
	  &analysis.LaLabSBe&IndexDate=value;
	end;
  %end;
  if first.afterbase and afterbase=1 then do;
    &analysis.FiLabDAf&IndexDate=samplingdate;       &analysis.FiLabVAf&IndexDate=valuenum;
    &analysis.FiLabUAf&IndexDate=unit;               &analysis.FiLabCAf&IndexDate=analysiscode;
	&analysis.FiLabSAf&IndexDate=value;
  end;
  if %if &IndexDate ne %then last.&IndexDate; %else last.pnr; then output;
  keep pnr
  %if &IndexDate ne %then &IndexDate
    &analysis.LaLabDBe&IndexDate  &analysis.LaLabVBe&IndexDate
    &analysis.FiLabDBe&IndexDate  &analysis.FiLabVBe&IndexDate
    &analysis.LaLabUBe&IndexDate  &analysis.LaLabCBe&IndexDate
    &analysis.FiLabUBe&IndexDate  &analysis.FiLabCBe&IndexDate
    &analysis.FiLabSBe&IndexDate  &analysis.LaLabSBe&IndexDate
  ;
  &analysis.FiLabDAf&IndexDate   &analysis.FiLabVAf&IndexDate
  &analysis.FiLabUAf&IndexDate   &analysis.FiLabCAf&IndexDate
  &analysis.FiLabSAf&IndexDate;
  %if &IndexDate ne %then %do;
    label &analysis.LaLabDBe&IndexDate=   "Last lab samplingdate before inclusion event, &IndexDate";
	label &analysis.LaLabVBe&IndexDate=   "Last lab analysis before inclusion event, &IndexDate";
	label &analysis.FiLabDBe&IndexDate=   "First lab samplingdate before inclusion event, &IndexDate";
	label &analysis.FiLabVBe&IndexDate=   "First lab analysis before inclusion event, &IndexDate";
    label &analysis.LaLabUBe&IndexDate=   "Last lab unit before inclusion event, &IndexDate";
	label &analysis.LaLabCBe&IndexDate=   "Last lab analysiscode before inclusion event, &IndexDate";
	label &analysis.FiLabUBe&IndexDate=   "First lab unit before inclusion event, &IndexDate";
	label &analysis.FiLabCBe&IndexDate=   "First lab analysiscode before inclusion event, &IndexDate";
	label &analysis.LaLabSBe&IndexDate=   "Last lab analysis (string) before inclusion event, &IndexDate";
	label &analysis.FiLabSBe&IndexDate=   "First lab analysis (string) before inclusion event, &IndexDate";
  %end;
  label &analysis.FiLabDAf&IndexDate=     "First lab samplingdate after inclusion event, &IndexDate";
  label &analysis.FiLabVAf&IndexDate=     "First lab analysis after inclusion event, &IndexDate";
  label &analysis.FiLabUAf&IndexDate=     "First lab unit after inclusion event, &IndexDate";
  label &analysis.FiLabCAf&IndexDate=     "First lab analysiscode after inclusion event, &IndexDate";  
  label &analysis.FiLabSAf&IndexDate=     "First lab analysis (string) after inclusion event, &IndexDate";
    %if &IndexDate = %then %do;
    rename &analysis.FiLabDAf&IndexDate=  &analysis.FiLabD;
	rename &analysis.FiLabVAf&IndexDate=  &analysis.FiLabV;
    rename &analysis.FiLabUAf&IndexDate=  &analysis.FiLabU;
	rename &analysis.FiLabCAf&IndexDate=  &analysis.FiLabC;
    rename &analysis.FiLabSAf&IndexDate=  &analysis.FiLabS;
  %end;
run;
%mend;



