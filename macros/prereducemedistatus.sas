/*
  macro %prereduceMediStatus
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Klargør til reduktion og omdøber alle inkluderede medicin til samme navn (atc).
                     f.eks.her hvor findingMedi har samlet alt under A10, som default anvender
                     reduceMediStatus unikke atc koder, hvilket ikke ønskes her.
                     %prereduceMediStatus(DiabATC, A10);
  #+CHANGELOG     :  Date        Initials Status
                  :  01-10-15    JNK      ported from DS
                  :
*/

%macro prereduceMediStatus(indata, outdata, grp, atc, IndexDate, ajour=);
%local localdata;
  %let localdata=%NewDatasetName(temp); /* temporært datasætnavn så data i work */

  data localdata;
    set &indata;
	format &grp $10.; /* remove warning */
	ATC=&grp;
	&grp="&atc";
  run;
  %reduceMediStatus(localdata, &outdata, &grp, &indexdate, ATC=ATC, ajour=&ajour);
  %cleanup(&localdata);

%mend;



