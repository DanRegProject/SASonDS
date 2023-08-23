/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: prereduceMediStatus.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
%macro prereduceMedistatus(indata,outdata,grp,atc,IndexDate, ajour=);
/*
klarg�r til reduction og omd�ber alle inkluderede medicin til samme navn (atc)
fx her hvor findingMediperiods har samlet alt under A10, som default anvender reducerMediperiods unikke atc koder, hvilket ikke �nskes her.
%prereducerFA3(DiabATC,A10);
*/
%local localdata;
  %let localdata=%NewDatasetName(temp); /* tempor�rt datas�tnavn s� data i work */
  data localdata;
    set &indata;
  	format &grp $10.; /* remove warning */
  	ATC=&grp;
  	&grp="&atc";
  run;
  %reduceMediStatus(localdata, &outdata, &grp, &indexdate, ATC=ATC, ajour=&ajour);
  %cleanup(&localdata);
%mend;
