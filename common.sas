/* SVN header
$Date: 2021-12-01 11:28:02 +0100 (on, 01 dec 2021) $
$Revision: 310 $
$Author: wnm6683 $
$Id: common.sas 310 2021-12-01 10:28:02Z wnm6683 $
*/


%let ProjectNumber     = 706683; /* remove when everyone are using the latest master.sas template */

%let lastyr = %sysfunc(year("&sysdate"d)); /* will use the year common.sas is executed */
%let lastLPR  = 2018; /* 16/5-2021: sidste kendte LPR opdatering, DS hele 2015 */
%let lastLMDB = 2019; /* 15/11-2016: sidste LMDB opdatering - hele 2015 */
%let lastudda = 2018;
%let lastfaik = 2018;
%let lastbef  = 2018;
%let lastindh = 2017;*2013?;
%let globalend = mdy(12,31,2099);
%let YearInDays = 365.25;

libname master   "D:\data\Workdata\&ProjectNumber/data/SAS/Master"              access=readonly ;
libname charlib  "D:\data\Workdata\&ProjectNumber/data/SAS/Master"              access=readonly ;
libname risklib  "D:\data\Workdata\&ProjectNumber/data/SAS/RISKData2"           access=readonly ;
libname mcolib   "D:\data\Workdata\&ProjectNumber/data/SAS/RISKData2"           access=readonly ;

*----------------------------------------------------*
* Allokering af SAS-formater i Danmarks Statistik.   *
* Hostede forskermaskiner.                           *
*----------------------------------------------------;
/* old solution - not  hosted server
libname fmt '\\srvfsenas1\data\formater\SAS formater i Danmarks Statistik\FORMATKATALOG' access=readonly;
options fmtsearch=(fmt.times_personstatistik fmt.brancher
    fmt.uddannelser fmt.geokoder);
*/
libname fmt '\\srvfsenas3\formater\SAS formater i Danmarks Statistik\FORMATKATALOG' access=readonly;
options fmtsearch=(fmt.times_personstatistik fmt.times_erhvervsstatistik fmt.times_bbr
                   fmt.statistikbank fmt.brancher fmt.uddannelser fmt.disced fmt.disco fmt.sundhed fmt.geokoder);

options compress=YES;
options mprint merror spool;
*options mprint merror symbolgen mlogic;
*options mprint merror nosymbolgen nomlogic;

%let sqlmax = max;

/* use subsetLPR and subsetLMDB macros, only create tables if the macro has not been executed already */
%let DiagInWork  = FALSE; /* create a copy of the files in work, for faster execution when making risk tables */
%let MediInWork  = FALSE;
%global DiagInWork MediInWork;


/* here follows the inclusion of all published macros */
%include "&localmacropath/macros/subsetLMDB.sas";
%include "&localmacropath/macros/subsetLPR.sas";
%include "&localmacropath/macros/getdiag.sas";
%include "&localmacropath/macros/getmedi.sas";
%include "&localmacropath/macros/gethosp.sas";
%include "&localmacropath/macros/getOPR.sas";
*%include "&localmacropath/macros/getUBE.sas"; /* obsolete use getOPR instead */
%include "&localmacropath/macros/getMFR.sas";
%include "&localmacropath/macros/getSocio.sas";
%include "&localmacropath/macros/excldiag.sas";
%include "&localmacropath/macros/baseMedi.sas";
%include "&localmacropath/macros/baseDiag.sas";
%include "&localmacropath/macros/baseOPR.sas";
%include "&localmacropath/macros/reduceMediPeriods.sas";
%include "&localmacropath/macros/prereducemedistatus.sas";
%include "&localmacropath/macros/reducemedistatus.sas";
%include "&localmacropath/macros/reducediag.sas";
%include "&localmacropath/macros/reduceOPR.sas";
*%include "&localmacropath/macros/RiskSetMatch.sas";
%include "&localmacropath/macros/RiskSetMatch2.sas";
%include "&localmacropath/macros/mergediag.sas";
%include "&localmacropath/macros/mergemedi.sas";
%include "&localmacropath/macros/mergeOPR.sas";
%include "&localmacropath/macros/mergeUBE.sas";
%include "&localmacropath/macros/MergePOP.sas";
%include "&localmacropath/macros/mergeSocio.sas";
%include "&localmacropath/macros/qualdiag.sas";
%include "&localmacropath/macros/header.sas";
%include "&localmacropath/macros/list_sas_files_in_dir.sas";
%include "&localmacropath/macros/create_datalist.sas";
%include "&localmacropath/macros/nonrep.sas";
%include "&localmacropath/macros/macroutilities.sas";
%include "&localmacropath/macros/riskmacros.sas";
%include "&localmacropath/macros/charlson.sas";
%include "&localmacropath/macros/multicoscore.sas";
%include "&localmacropath/macros/describeSASchoises.sas";
%include "&localmacropath/macros/smoothhosp.sas";
%include "&localmacropath/macros/genendpoint.sas";
%include "&localmacropath/macros/icd_atcdefines.sas";
%include "&localmacropath/macros/checklog.sas";
%include "&localmacropath/macros/TjekMacro.sas";

%include "&localmacropath/icd_atc_codes/ATCkoder.sas";
%include "&localmacropath/icd_atc_codes/LPRkoder.sas";
%include "&localmacropath/icd_atc_codes/OPRkoder.sas";
%include "&localmacropath/icd_atc_codes/UBEkoder.sas";
%include "&localmacropath/icd_atc_codes/ATCriskscores.sas";
%include "&localmacropath/icd_atc_codes/LPRriskscores.sas";
%include "&localmacropath/icd_atc_codes/Riskscores.sas";

%include "&localmacropath/icd_atc_codes/LPRkoder2020.sas";

%include "&localmacropath/formats/format.sas";

options source2; /*ensures that log from %include is also added to the logfile*/;
options dlcreatedir; /* create directory if not existing when using libname option */
/*
data _null_;
    infile "e:/workdata/703794/code/SAS/1/welcome.txt";
    input;
    put _infile_;
run;
*/
