/* SVN header
$Date: 2021-01-28 10:52:30 +0100 (to, 28 jan 2021) $
$Revision: 268 $
$Author: fflb6683 $
$header$
$Id: LPRkoder.sas 268 2021-01-28 09:52:30Z fflb6683 $
*/
/* special cases */
*%include "&macropath/ICD_ATC_codes/LPRriskscores.sas";

/* A */
/* ACUTPAN -  Acute pancreatitis */;
%global LPRACUTPAN LPRACUTPAN_ICD8 LPRLACUTPAN;
%let LPRACUTPAN        = K85;
%let LPRACUTPAN_ICD8   = "";
%let LPRLACUTPAN       = "Acute Pancreatitis";

/* AFLI */
%global LPRAFLi LPRAfli_ICD8 LPRLAfli;
%let LPRAFli          = I48;
%let LPRAfli_ICD8     = 42793 42794;
%let LPRLAfli         = "Atrial Fibrillation";

/* aflis - Atrial Fibbrilation specific */
%ICD_ATCdefines(LPR, aflis,"Atrial Fibrilation - specific", I480 I481 I482 I489B);

/* aflu - Atrial Flutter */
%ICD_ATCdefines(LPR, aflu,"Atril Flutter", I483 I484 I489A);


/* AIDS */;
%global LPRAIDS LPRAIDS_ICD8 LPRLAIDS;
%let LPRAIDS           = B21 B22 B23 B24;
%let LPRAIDS_ICD8      = "";
%let LPRLAIDS          = "HIV/AIDS";

/* Alco */;
*%global LPRalco LPRalco_ICD8 LPRLALCO;
*%let LPRAlco           = E244 E529A F10 G312 G621 G721 I426 K292 K70 K860 L278A O354 T51 Z714 Z721;
*%let LPRAlco_ICD8      = 30309 30319 30320 30328 30329 30390 57110 57710 57301 57710;
*%let LPRLAlco          = "Alcohol";

/* alcopsyk - Alcohol psychosis and alcohol abuse syndrome */
%ICD_ATCdefines(LPR,alcopsyk ,"Alcohol psychosis and acohol abuse syndrom", F102 F103 F104 F105 F106 F107 F108 F109, icd8=29109 29119 29129 29139 29199 30309 30319 30320 30328 30329 30390 30391 30399 );

/* amnsyn - Amnestic syndromes */
%ICD_ATCdefines(LPR,amnsyn,"Amnestic syndromes", D5 D60 D61 D62 D63 D64, icd8=280 281 282 283 284 285 );

/* Anemia */
%global LPRAnemia LPRAnemia_ICD8 LPRLAnemia;
%let LPRAnemia         = D5 D60 D61 D62 D63 D64;
%let LPRAnemia_ICD8    = 280 281 282 283 284 285;
%let LPRLAnemia        = "Anemia";

/* AntiPhos - Antiphospholipid antibody syndrome  */
%global LPRAntiPhos LPRAntiPhos_ICD8 LPRLAntiPhos;
%let LPRAntiPhos        = D686;
%let LPRAntiPhos_ICD8   = "";
%let LPRLAntiPhos       = "Antiphospholipid antibody syndrome";

/* APlaq */;
%global LPRAPlaq LPRAPlaq_ICD8 LPRLAPlaq;
%let LPRAPlaq          = I700;
%let LPRAPlaq_ICD8     = "";
%let LPRLAPlaq         = "Aortic plaque";

/* avblo - AV block */
%ICD_ATCdefines(LPR,avblo,"AV block",I441 I442 I443 );

/* alzdi - Alzheimers Disease */
%ICD_ATCdefines(LPR,alzdi ,"Alzheimers Disease",F00 G30, icd8= 29010 29009 );

/* C */
/* CA */;
%global LPRca LPRca_ICD8 LPRLca;
%let LPRca             = I46;
%let LPRca_ICD8        = 42727;
%let LPRLca            = "Cardiac arrest";

/* Cancer */;
%global LPRCancer LPRCancer_ICD8 LPRLCancer;
%let LPRCancer         = C;
%let LPRCancer_ICD8    = "";
%let LPRLCancer        = "Cancer";

/* Cancer1 - Line/Anette/Ida */;
%global LPRCancer1 LPRCancer1_ICD8 LPRLCancer1;
%let LPRCancer1         = C0 C1 C2 C3 C40 C41 C42 C43 C45 C46 C47 C48 C49 C5 C6 C7 C8 C9;
%let LPRCancer1_ICD8    = 14 15 16 170 171 173 174 175 176 177 178 179 18 19 200 201 202 203 204 205 206 207 208 209;
%let LPRLCancer1        = "Cancer - excluding C44";

/* carmyo - Cardiomyopathy */;
%global LPRCarmyo LPRCarmyo_ICD8 LPRLCarmyo;
%let LPRCarmyo         = I42 I43;
%let LPRCarmyo_ICD8    = "";
%let LPRLCarmyo        = "Cardiomyopathy";

/* CF */
%global LPRCF LPRCF_ICD8 LPRLCF;
%let LPRCF             = E84;
%let LPRCF_ICD8        = "";
%let LPRLCF            = "Cystic fibrosis";

/* CHD */
%global LPRCHD LPRCHD_ICD8 LPRLCHD;
%let LPRCHD            = Q20 Q21 Q22 Q23 Q24 I424A;
%let LPRCHD_ICD8       = "";
%let LPRLCHD           = "medfødte hjerte misdannelser congestive heart disease";

/* chrglome - Chronic glumerolonephritis */
%ICD_ATCdefines(LPR,chrglome, "Chronic glumerolonephritis", 
                              N02 N03 N05 N06 N07, 
                              icd8=582 583);

/* chrtunep - Chronic tubulointestinal nephropathy */
%ICD_ATCdefines(LPR, chrtunep,"Chronic tubulointestinal nephropathy", 
                               N11 N12 N14 N158 N159 N160 N162 N163 N164 N169, 
                               icd8=59009 59320);

/* circdis - other disorders of the circulatory system */
%ICD_ATCdefines(LPR, circdis,"Other disorders of the circolatory system",I870 );

/* Coca - cocaine */
%ICD_ATCdefines(LPR,coca ,"Cocaine",F14, icd8=30449 );


/* Cognit */
%global LPRCognit LPRCognit_ICD8 LPRLCognit;
%let LPRCognit         = F06;
%let LPRCognit_ICD8    = "";
%let LPRLCognit        = "Cognitive impairment";

/* CPD - Chronic Pulmonary Disease - Thygesen et al 2011 (KOL )*/
%global LPRCPD LPRCPD_ICD8 LPRLCPD;
%let LPRCPD            = J40 J41 J42 J43 J44 J45 J46 J47 J60 J61 J62 J63 J64 J65 J67 J684 J701 J703 J841 J920 J961 J982 J983;
%let LPRCPD_ICD8       = "";
%let LPRLCPD           = "Chronic Pulmonary Disease";

/* old name: KOL */;
/* cpd1 - Chronic Pulmonary Disease */;
%global LPRcpd1 LPRcpd1_ICD8 LPRLcpd1;
%let LPRcpd1            = J44;
%let LPRcpd1_ICD8       = "";
%let LPRLcpd1           = "Chronic Pulmonary Disease";

/* CPD2 - Chronic Obstructive Pulmonary Disease  */
%global LPRCPD2 LPRCPD2_ICD8 LPRLCPD2;
%let LPRCPD2        = J40 J41 J42 J43 J44;
%let LPRCPD2_ICD8   = 490 491 492;
%let LPRLCPD2       = "Chronic Obstructive Pulmonary Disease";

/* crenal - chronic kidney disease */
%ICD_ATCdefines(LPR, crenal,"Chronic kidney Disease",
                             E102 E112 E142 I120 I131 I132 I150 I151 N03N05 N07 N08 N110 N14 N15 N16 N18 N19 N26 N280 N391 Q61, 
                             icd8=24902 25002 582 583 584 59009 59320 75309 75310 75311 75319 792 );

/* D */

/* depre - Depression */
%ICD_ATCdefines(LPR, depre,"Depression", F32 F33, icd8= 29609 29629 29699 29809);


/* DiabLPR */;
*%global LPRDiabLPR LPRDiabLPR_ICD8 LPRLDiabLPR;
*%let LPRDiabLPR        = E100 E101 E109 E110 E111 E119;
*%let LPRDiabLPR_ICD8   = 24900 24909 25008 25009;
*%let LPRLDiabLPR       = "Diabetes Mellitus";

/* Diab2LPR */; /* ikke ensrettet med Registreringscentralen og SDS! */
/*
%global LPRDiab2LPR LPRDiab2LPR_ICD8 LPRLDiab2LPR;
%let LPRDiab2LPR       = E10 E11 E12 E13 E14 E781 R73;
%let LPRDiab2LPR_ICD8  = 24900 24908 24909 25000 25008 25009 27201 27901;
%let LPRLDiab2LPR      = "Diabetes mellitus Vadman version"; */

/* Diab2LPR */; /* ÆNDRET! - svarer nu til diab2lpr på registreringscentralen */
%global LPRDiab2LPR LPRDiab2LPR_ICD8 LPRLDiab2LPR;
%let LPRDiab2LPR       = E10 E11;
%let LPRDiab2LPR_ICD8  = 24900 24909 25008 25009;
%let LPRLDiab2LPR      = "Diabetes Mellitus";

/* Diab3LPR */; /* Ændret! svarer nu til diab3lpr på registreringscentralen */
%global LPRDiab3LPR LPRDiab3LPR_ICD8 LPRLDiab3LPR;
%let LPRDiab3LPR       = E10 E11 E14;
%let LPRDiab3LPR_ICD8  = 24900 24901 24902 24903 24904 24905 24906 24907 24908 24909 25000 25001 25002 25003 25004 25005 25006 25007 25008 25009;
%let LPRLDiab3LPR      = "Diabetes mellitus";

/* Diab4LPR - Diabetes Mellitus  */
%global LPRDiab4LPR LPRDiab4LPR_ICD8 LPRLDiab4LPR;
%let LPRDiab4LPR        = E10 E11 E14;
%let LPRDiab4LPR_ICD8   = 7611 250;
%let LPRLDiab4LPR       = "Diabetes Mellitus";

/* Diab5LPR - Diabetes forårsaget af underernæring */
%global LPRDiab5LPR LPRDiab5LPR_ICD8 LPRLDiab5LPR;
%let LPRDiab5LPR        = E12;
%let LPRDiab5LPR_ICD8   = "";
%let LPRLDiab5LPR       = "Diabetes forårsaget af underernæring";

/* Diab6LPR - Diabetes - andre former */
%global LPRDiab6LPR LPRDiab6LPR_ICD8 LPRLDiab6LPR;
%let LPRDiab6LPR        = E13;
%let LPRDiab6LPR_ICD8   = "";
%let LPRLDiab6LPR       = "Diabetes - andre former";

/* Diabgest - gestationel diabetes */;
%global LPRDiabgest LPRDiabgest_ICD8 LPRLDiabgest;
%let LPRDiabgest       = 0244;
%let LPRDiabgest_ICD8  = "";
%let LPRLDiabgest      = "Gestationel Diabetes";

/* Diabkata - Diabetisk katarakt */;
%global LPRDiabkata LPRDiabkata_ICD8 LPRLDiabkata;
%let LPRDiabkata       = H280;
%let LPRDiabkata_ICD8  = "";
%let LPRLDiabkata      = "Diabetisk katarakt";

/* diabnep - Diabetic nephropaty */
%ICD_ATCdefines(LPR,diabnep,"Diabetic Nephropaty",E102 E112 E132 E142 N083, icd8=25002);

/* Diabpoly - Diabetisk polyneuropati */;
%global LPRDiabpoly LPRDiabpoly_ICD8 LPRLDiabpoly;
%let LPRDiabpoly       = G632;
%let LPRDiabpoly_ICD8  = "";
%let LPRLDiabpoly      = "Diabetisk polyneuropati";

/* Diabreti - Diabetisk retinopati */;
%global LPRDiabreti LPRDiabreti_ICD8 LPRLDiabreti;
%let LPRDiabreti       = H360;
%let LPRDiabreti_ICD8  = "";
%let LPRLDiabreti      = "Diabetisk retinopati";

/* DRenal */;
%global LPRDRenal LPRdrenal_icd8 LPRLDRenal;
%let LPRDRenal         = Z992;
%let LPRDrenal_ICD8    = "";
%let LPRLDRenal        = "Dependence on renal dialysis";

/* DVT */;
%global LPRDVT LPRDVT_ICD8 LPRLDVT;
%let LPRDVT            = I801 I802 I803 I808 I809 I819 I636 I676 I822 I823 I828 I829;
%let LPRDVT_ICD8       = 451;
%let LPRLDVT           = "DVT";

/* DVT1 - Deep Venous Thrombosis  */
%global LPRDVT1 LPRDVT1_ICD8 LPRLDVT1;
%let LPRDVT1        = I801 I802 I803 I808 I809 I822 I823 I829;
%let LPRDVT1_ICD8   = "";
%let LPRLDVT1       = "Deep Venous Thrombosis";


/* E */
/* Epi */
%global LPREpi LPREpi_ICD8 LPRLEpi;
%let LPREpi            = G40;
%let LPREpi_ICD8       = "";
%let LPRLEpi           = "Epilepsy";

/* F */

/* G */
/* GBleed */;
%global LPRGBleed LPRGBleed_ICD8 LPRLGBleed;
%let LPRGBleed         = K25 K26 K27 K28 K29;
%let LPRGBleed_ICD8    = 53091 53098 531 532 533 534;
%let LPRLGBleed        = "Gastrointestinal bleeding";

/* GBleed2 */;
%global LPRGBleed2 LPRGBleed2_ICD8 LPRLGBleed2;
%let LPRGBleed2        = K250 K252 K254 K260 K262 K264 K270 K272 K274 K280 K282 K290 K920 K921 K922;
%let LPRGBleed2_ICD8   = 53091 53098 531 532 533 534;
%let LPRLGBleed2       = "Gastrointestinal bleeding, strict version";

/* Genbleed - General bleeding */;
%global LPRGenbleed LPRLGenbleed;
%let LPRGenbleed         = D500 D62 D683 D698 D699 R58 T792A T792B;
%let LPRGenbleed_ICD8    = "";
%let LPRLGenbleed        = "General bleeding";

/* GIbleed - Gastrointestinal bleeding */ /*Skal erstatte Gbleed og Gbleed2 (Okt 2020 - Line)*/;
%global LPRGIbleed LPRLGIbleed;
%let LPRGIbleed         = I850 I864A K226 K228F K250 K252 K254 K256 K260 K262 K264 K266 K270 K272 K274 K276 K280 K282 K284 K286 K290 K298A K625 K638B K638C K661 K838F K868G K920 K921 K922;
%let LPRGIbleed_ICD8    = "";
%let LPRLGIbleed        = "Gastrointestinal bleeding";

/* Gout - Rheumotoid Diseases */;
%global LPRGout LPRGout_ICD8 LPRLGout;
%let LPRGout           = M16 M17;
%let LPRGout_ICD8      = "";
%let LPRLGout          = "Rheumotoid diseases";

/* Gubleed - Genitourinary bleeding */;
%global LPRGubleed LPRLGubleed;
%let LPRGubleed         = N830A N920 N924 N938 N939 N02 R31;
%let LPRGubleed_ICD8    = "";
%let LPRLGubleed        = "Genitourinary bleeding";


/* H */
/* Hbleed - Haematoma bleeding */;
%global LPRHbleed LPRLHbleed;
%let LPRHbleed         = N488D N488E N501A N501B N501C N501D N501E N831A N837 N857 N857A N897A N908D S003A S378A S601A S902A T140D T140K T810A T876D;
%let LPRHbleed_ICD8    = "";
%let LPRLHbleed        = "Haematoma bleeding";

/* Halluc - Hallucinogens */
%ICD_ATCdefines(LPR,halluc ,"Hallucinogens",F13, icd8=30479 );

/* HCImp - Heart or cardiac implants or crafts (brug i kombination med procedurekode */
%global LPRHCImp LPRHCImp_ICD8 LPRLHCImp;
%let LPRHCImp          = Z95;
%let LPRHCImp_ICD8     = "";
%let LPRLHCImp         = "Heart or cardiac implants or crafts";

/* Hemato */;
%global LPRHemato LPRHemato_ICD8 LPRLHemato;
%let LPRHemato         = N02 R319;
%let LPRHemato_ICD8    = "";
%let LPRLHemato        = "hematory";

/* hemi - Hemiplegia */
%ICD_ATCdefines(LPR, hemi ,"Hemiplegia",G81 G82, icd8=344);

/* old name:  HFLPR */;
/* HF - congestive heart failure */;
*%global LPRHF LPRHF_ICD8 LPRLHF;
*%let LPRHF             = I110 I130 I132 I50;
*%let LPRHF_ICD8        = 42709 42710 42711 42719 42899 78249;
*%let LPRLHF            = "Congestive heart failure";

/* old name: HF2LPR */;
/* HF2 */;
%global LPRHF2 LPRHF2_ICD8 LPRLHF2;
%let LPRHF2            = I110 I130 I132 I420 I50;
%let LPRHF2_ICD8       = 42709 42710 42711 42719 42899 78249;
%let LPRLHF2           = "Congestive heart failure";

/* old name: HF3LPR */;
/* HF3 */;
%global LPRHF3 LPRHF3_ICD8 LPRLHF3;
%let LPRHF3            = I34 I35 I36 I37 I42 I43 I50;
%let LPRHF3_ICD8       = 42401 42402 42408 42409 42411 42418 42419 42490 42491 42492 42499 42599 424709 42711 42719;
%let LPRLHF3           = "Congestive heart failure and cardiomyopathy - Vadman version";

/* HF4 */;
%global LPRHF4 LPRHF4_ICD8 LPRLHF4;
%let LPRHF4            = I110 I130 I132 I42 I43 I50;
%let LPRHF4_ICD8       = "";
%let LPRLHF4           = "Congestive heart failure and cardiomyopathy - Lines version";


/* hipfrac - Hipfracture */
%ICD_ATCdefines(LPR,hipfrac ,"Hip Fracture",S72 );

/* Htrauma - Head trauma */
%ICD_ATCdefines(LPR,htrauma ,"Head Trauma",
                    S06 S020 S021 S027 S029, 
                    icd8= 85099 85129 852 853 854 80099 801 80399 );

/* HypLPR - Hypertension */;
*%global LPRHypLPR LPRHypLPR_ICD8 LPRLHypLPR;
*%let LPRHypLPR         = I10 I11 I12 I13 I15;
*%let LPRHypLPR_ICD8    = 400 401 402 403 404; /*19/5/2017 - 404 tilføjet (af Line)*/
*%let LPRLHypLPR        = "Hypertension";

/* hypnep - Hyperthyroidism */
%ICD_ATCdefines(LPR,hypnep ,"Hyperthyroidism",E05 E06, icd8=24200 24208 24209 24219 24220 24228 24229 );

/* HypThy - Hyperthyroidism */
%global LPRHypThy LPRHypThy_ICD8 LPRLHypThy;
%let LPRHypThy         = E05 E06;
%let LPRHypThy_ICD8    = 24200 24208 24209 24219 24220 24228 24229;
%let LPRLHypThy        = "Hyperthyroidism";


/* I */
/* Ibleed - Haemorrhagic stroke = Intracranial bleeding */;
%global LPRIBleed LPRIBleed_ICD8 LPRLIBleed;
%let LPRIBleed         = I60 I61 I62; /*15/5/17 - I6 rettet til I62 (af Line)*/
%let LPRIBleed_ICD8    = 430 431;
%let LPRLIBleed        = "Haemorrhagic stroke - Intracranial bleeding";

/* Icbleed - Intracranial bleeding *//*Skal erstatte Ibleed (Okt 2020 - Line)*/;
%global LPRIcbleed LPRLIcbleed;
%let LPRIcbleed         = I60 I61 I62 I690 I691 I692;
%let LPRIcbleed_ICD8    = "";
%let LPRLIcbleed        = "Intracranial bleeding";

/* Impbleed - Bleeding in other important organ system*/;
%global LPRImpbleed LPRLImpbleed;
%let LPRImpbleed         = E078B E274B G951A I312 I319A I230 J942 M250 R04 S259A S368A S368B S368D T143C T144A;
%let LPRImpbleed_ICD8    = "";
%let LPRLImpbleed        = "Bleeding in other important organ system";

/* InfBowel */;
%global LPRInfBowel LPRInfBowel_ICD8 LPRLInfBowel;
%let LPRInfBowel       = K50 K51;
%let LPRInfBowel_ICD8  = 563;
%let LPRLInfBowel      = "Inflamatory Bowel disease";

/* ihd - ischemic heart disease */
*%ICD_ATCdefines(LPR,ihd,"Ischemic Heart Disease",I20 I21 I23 I24 I25);

/* intermit- Intermittent claudication */
%ICD_ATCdefines(LPR,intermit,"Intermittent Claudication",I739, icd8=44389 44390 44391 44392 44393 44394 44395 44396 44397 44398 44399 );


/* ISCHD */;
%global LPRISCHD LPRISCHD_ICD8 LPRLISCHD;
%let LPRISCHD          = I20 I21 I22 I23 I24 I25;
%let LPRISCHD_ICD8     = 41009 41099 41109 41199 41209 41299 41309 41399 41409 41499;
%let LPRLISCHD         = "Ischemic heart disease";

/* istroke */ ;
%global LPRistroke LPRistroke_ICD8 LPRListroke;
%let LPRIStroke        = I63 I64;
%let LPRIStroke_ICD8   = 43300 43309 43409 43499 43601 43690;
%let LPRLIStroke       = "Stroke";


/* K */
/* KidtraLPR */
%global LPRKidtraLPR LPRKidtraLPR_ICD8 LPRLKidtraLPR;
%let LPRKidtraLPR      = Z940;
%let LPRKidtraLPR_ICD8 = "";
%let LPRLKidtraLPR     = "Kidney transplantation status";

/* L */
/* Lbleed - Bleeding in respiratory/thorax (LPR)*/;
%global LPRLbleed LPRLLbleed;
%let LPRLbleed         = J942 R04 S259A;
%let LPRLbleed_ICD8    = "";
%let LPRLLbleed        = "Bleeding in respiratory/thorax (LPR)";

/* Liver */;
*%global LPRLiver LPRLiver_ICD8 LPRLLiver;
*%let LPRLiver          = B150 B160 B162 B190 K704 K72 K766 I85;
*%let LPRLiver_ICD8     = 07000 07002 07004 07006 07008 57300 4560;
*%let LPRLLiver         = "Moderate/severe liver Disease";

/* LVD */;
%global LPRLVD LPRLVD_ICD8 LPRLLVD;
%let LPRLVD            = I501 I509;
%let LPRLVD_ICD8       = 4271;
%let LPRLLVD           = "LVD";


/* M */
/* MBleed1 */;
%global LPRMBleed1 LPRMBleed1_ICD8 LPRLMBleed1;
%let LPRMBleed1        = D629 J942 N02 R04 R31 R58;
%let LPRMBleed1_ICD8   = "";
%let LPRLMBleed1       = "Extracranial or unclassified major bleeding version 1";

/* MBleed2 */;
%global LPRMBleed2 LPRMBleed2_ICD8 LPRLMBleed2;
%let LPRMBleed2        = D629 J942 R04 R310 R58;
%let LPRMBleed2_ICD8   = "";
%let LPRLMBleed2       = "Extracranial or unclassified major Bleeding version 2 without hematori";

/* MBleed3 */;
%global LPRMBleed3 LPRMBleed3_ICD8 LPRLMBleed3;
%let LPRMBleed3        = D62 J942 H113 H356 H431 N02 R04 R31 R58;
%let LPRMBleed3_ICD8   = "";
%let LPRLMBleed3       = "Extracranial or unclassified major bleeding version 3";

/* mdrug - Other and multiple drugs */
%ICD_ATCdefines(LPR,mdrug ,"Other and multiple drugs",F18 F19, icd8=30489 30499 );

/* MI - Myocardial infarction I23 er efterforløb komplikationer */
%global LPRMI LPRMI_ICD8 LPRLMI;
%let LPRmi            = I21 I23;
%let LPRmi_ICD8       = 410;
%let LPRLmi           = "Myocardial infarction";

/* MI2 */;
%global LPRMI2 LPRMI2_ICD8 LPRLMI2;
%let LPRMI2            = I21;
%let LPRMI2_ICD8       = 410;
%let LPRLMI2           = "Myocardial infarction";

/* Minbleed - Other/minor bleeding */;
%global LPRMinbleed LPRLMinbleed;
%let LPRMinbleed         = H922 K089A K645 N921 N950 S098A;
%let LPRMinbleed_ICD8    = "";
%let LPRLMinbleed        = "Other/minor bleeding";

/* Mitsten */
%global LPRMitsten LPRMitsten_ICD8 LPRLMitsten;
%let LPRMitsten       = I05;
%let LPRMitsten_ICD8  = "";
%let LPRLMitsten      = "Mitral Stenosis";

/* MRenal */
%global LPRMRenal LPRMRenal_ICD8 LPRLMRenal;
%let LPRMRenal         = R809;
%let LPRMRenal_ICD8    = "";
%let LPRLMRenal        = "Proteinuria - mild renal impairment";

/* Muscu */
%global LPRMuscu LPRMuscu_ICD8 LPRLMuscu;
%let LPRMuscu          = G71;
%let LPRMuscu_ICD8     = "";
%let LPRLMuscu         = "Muscular impairment";

/* MyeloDis - Myeloproliferative disorders (polycythemia vera, essential thrombocytemia)  */
%global LPRMyeloDis LPRMyeloDis_ICD8 LPRLMyeloDis;
%let LPRMyeloDis        = D45 D473; 
%let LPRMyeloDis_ICD8   = 208 2871;
%let LPRLMyeloDis       = "Myeloproliferative disorders (polycythemia vera, essential thrombocytemia)";

/* N */
/* Neoplasm -  */
%ICD_ATCdefines(LPR,neoplasm,"Neoplasm",
                 C0 C1 C2 C3 C4 C5 C6 C7 C8 C90 C91 C92 C93 C94 C95 C96, 
                 icd8=14 15 16 17 18 19 200 201 202 203 204 205 206 207 208 209 );

/* NephSyndr - Neprhotic syndrome   */
%global LPRNephSyndr LPRNephSyndr_ICD8 LPRLNephSyndr;
%let LPRNephSyndr        = N04;
%let LPRNephSyndr_ICD8   = "";
%let LPRLNephSyndr       = "Neprhotic syndrome";

/* neschren - Non-end-stage chronic renal disease */
%ICD_ATCdefines(LPR,neschren ,"Non-end-stage chronic renal disease",
                          E102 E112 E132 E142 I120 M321B M300 M313 M319 N02 N03 N04 N05 N06 N07 N08 N11 N12 N14 N158 N160 N162 N163 N164 N168 N18 N19 N26 Q612 Q613 Q615 Q619 , 
                          icd8=25002 40039 403 404 581 582 583 584 59009 59320 75310 75311 75319);


/* O */
/* OAcutHD */;
%global LPROAcutHD LPROAcutHD_ICD8 LPRLOAcutHD;
%let LPROAcutHD        = I24;
%let LPROAcutHD_ICD8   = "";
%let LPRLOAcutHD       = "Other acute heart diseases";

/* Obese   */
%global LPRObese LPRObese_ICD8 LPRLObese;
%let LPRObese          = E65 E66;
%let LPRObese_ICD8     = 27799;
%let LPRLObese         = "Obesity";

/* Obese1  */
%global LPRObese1 LPRObese1_ICD8 LPRLObese1;
%let LPRObese1         = E660B E660C E660D E660E E660F E660G E660H;
%let LPRObese1_ICD8    = 277;
%let LPRLObese1        = "Obesity";

/* Obese2  */
%global LPRObese2 LPRObese2_ICD8 LPRLObese2;
%let LPRObese2         = E65 E66 E67 E68;
%let LPRObese2_ICD8    = "";
%let LPRLObese2        = "Obesity";

/* Ocbleed - Intraocular bleeding */;
%global LPROcbleed LPRLOcbleed;
%let LPROcbleed         = H052A H313 H356 H431 H450;
%let LPROcbleed_ICD8    = "";
%let LPRLOcbleed        = "Intraocular bleeding";

/* OFracW */
%global LPROFracW LPROFracW_ICD8 LPRLOFracW;
%let LPROFracW         = M809C;
%let LPROFracW_ICD8    = "";
%let LPRLOFracW        = "Osteoporotic fracture - wrist";

/* OFracH */
%global LPROFracH LPROFracH_ICD8 LPRLOFracH;
%let LPROFracH         = M809B;
%let LPROFracH_ICD8    = "";
%let LPRLOFracH        = "Osteoporotic fracture - hip";

/* OFracV */
%global LPROFracV LPROFracV_ICD8 LPRLOFracV;
%let LPROFracV         = M809A;
%let LPROFracV_ICD8    = "";
%let LPRLOFracV        = "Osteoporotic fracture - vertebra";

/* OFrac */
%global LPROFrac LPROFrac_ICD8 LPRLOFrac;
%let LPROFrac          = M80;
%let LPROFrac_ICD8     = "";
%let LPRLOFrac         = "Osteoporotic fracture - general";

/* Opbleed - Peroperative and postoperative bleeding */;
%global LPROpbleed LPRLOpbleed;
%let LPROpbleed         = T810B T810C T810E T810F T810G T810H T810I T810J T810K T811A T811B T818F;
%let LPROpbleed_ICD8    = "";
%let LPRLOpbleed        = "Peroperative and postoperative bleeding";

/* opio - Opioids */
%ICD_ATCdefines(LPR,opio ,"opioids",F11, icd8=30409 30419);

/* Ost */
%global LPROst LPROst_ICD8 LPRLOst;
%let LPROst            = M81 M82;
%let LPROst_ICD8       = "";
%let LPRLOst           = "Osteoporosis";

/* othcedis - other cerebrovascular disease */
%ICD_ATCdefines(LPR,othcedis ,"Other cerebrovascular disease",I62 I65 I66 I67 I68 I69 G46, 
                   icd8= 432 437 438);

/* Othdem - Other dementia */
%ICD_ATCdefines(LPR,othdem,"Other Dementia",F02 F03 F1073 F1173 F1273 F1373 F1473 F1573 F1673 F1873 F1973 G231 G310A G310B G311 G318B G318E G3185, 
                     icd8= 09419 29011 29012 29013 29014 29015 29016 29017 29018 29019);

/* OtherHD */;
%global LPROtherHD LPROtherHD_ICD8 LPRLOtherHD;
%let LPROtherHD        = I3 I4 I50 I51 I52;
%let LPROtherHD_ICD8   = "";
%let LPRLOtherHD       = "Other heart diseases disease";

/* othstim - Other stimulants */
%ICD_ATCdefines(LPR,othstim ,"Other Stimulants",F15, icd8=30469 );

/* P */
/* PAD */;
%global LPRPAD LPRPAD_ICD8 LPRLPAD;
%let LPRPAD            = I70 I71 I72 I73 I74 I77;
%let LPRPAD_ICD8       = 440 441 442 443 444 445;
%let LPRLPAD           = "Peripheral vascular/ischemic disease";

/* PAD2 */
%global LPRPAD2 LPRPAD2_ICD8 LPRLPAD2;
%let LPRPAD2           = I702 I703 I704 I705 I706 I707 I708 I709 I71 I739 I74;
%let LPRPAD2_ICD8      = 440 441 442 443 444 445;
%let LPRLPAD2          = "Peripheral vascular/ischemic disease";

/* PAD3 -  version 3 for VASc in CHADSVASc */;
%global LPRPAD3 LPRPAD3_ICD8 LPRLPAD3;
%let LPRPAD3           = I702 I703 I704 I705 I706 I707 I708 I709 I71 I739;
%let LPRPAD3_ICD8      = 440 441 442 443 444 445;
%let LPRLPAD3          = "Peripheral vascular/ischemic disease";

/* Pain */
%ICD_ATCdefines(LPR,pain ,"Pain",M796);


/* PCOS - Polycystic ovarian syndrome */;
%global LPRPCOS LPRPCOS_ICD8 LPRLPCOS;
%let LPRPCOS           = E282;
%let LPRPCOS_ICD8      = "";
%let LPRLPCOS          = "PCOS - Polycystic ovarian syndrome";

/* PE */;
%global LPRPE LPRPE_ICD8 LPRLPE;
%let LPRPE             = I26;
%let LPRPE_ICD8        = 450;
%let LPRLPE            = "Pulmonary embolism";

/* peta - Perikardie tamponade */
%ICD_ATCdefines(LPR, peta,"Perikardie tamponade",I30 I312 I313);

/* Plate */
%global LPRPlate LPRPlate_ICD8 LPRLPlate;
%let LPRPlate          = D65 D66 D67 D68 D69;
%let LPRPlate_ICD8     = 286 287 288 289;
%let LPRLPlate         = "Plate, Coagulation defects";

/* PMICD */
%global LPRPMICD LPRPMICD_ICD8 LPRLPMICD;
%let LPRPMICD          = Z950;
%let LPRPMICD_ICD8     = "";
%let LPRLPMICD         = "Heart or cardiac implants or crafts";

/* Pneu - Pneumonia   */
*%global LPRPneu LPRPneu_ICD8 LPRLPneu;
*%let LPRPneu        = J12 J13 J14 J15 J16 J17 J18 A481 A709;
*%let LPRPneu_ICD8   = 480 481 482 483 484 485 486 073 471;
*%let LPRLPneu       = "Pneumonia";

/* Pneu1 - Pneumonia   */
%global LPRPneu1 LPRPneu1_ICD8 LPRLPneu1;
%let LPRPneu1        = J12 J13 J14 J15 J16 J17 J18 /*A481 A709*/;
%let LPRPneu1_ICD8   = 480 481 482 483 484 485 486 073 471;
%let LPRLPneu1       = "Pneumonia";

/* Pneu2 - Pneumonia   */
%global LPRPneu2 LPRPneu2_ICD8 LPRLPneu2;
%let LPRPneu2        = J12 J13 J14 J15 J16 J17;
%let LPRPneu2_ICD8   = "";
%let LPRLPneu2       = "Pneumonia";

/* PNH - Paroxysmal noctural hemoglobinuria  */
%global LPRPNH LPRPNH_ICD8 LPRLPNH;
%let LPRPNH        = D595;
%let LPRPNH_ICD8   = "";
%let LPRLPNH       = "Paroxysmal noctural hemoglobinuria  ";

/* polyren - Adult polycystic renal disease*/
%ICD_ATCdefines(LPR, polyren,"Adult Polycystic renal Disease",Q612 Q613 Q619, icd8= 75310 75319);

/* Pregbleed - Pregnancy-related bleeding */;
%global LPRPregbleed LPRLPregbleed;
%let LPRPregbleed         = O081G O208 O209 O441 O438E O469 O717 O72 O902;
%let LPRPregbleed_ICD8    = "";
%let LPRLPregbleed        = "Pregnancy-related bleeding";

/* pregnacy */
%ICD_ATCdefines(LPR, pregnacy,"Pregnacy",O0 O1 O2 O3 O4 O5 O6 O7 O8 O9, icd8=63 68);

/* PregPuer - Pregnacy or puerperium  */
%global LPRPregPuer LPRPregPuer_ICD8 LPRLPregPuer;
%let LPRPregPuer        = Z33 O0 O1 O20 O21 O20 O21 O220 O221 O222 O224 O226 O227 O228 O3 O4 O5 O6 O7 O80 O81 O82 O83 O84 O85 O86 O870 O872 O874 O875 O876 O877 O878 O9 ;
%let LPRPregPuer_ICD8   = "";
%let LPRLPregPuer       = "Pregnacy or puerperium";

/* PregVTE - Pregnacy related VTE  */
%global LPRPregVTE LPRPregVTE_ICD8 LPRLPregVTE;
%let LPRPregVTE        = O223 O229 O871 O879 O882;
%let LPRPregVTE_ICD8   = "";
%let LPRLPregVTE       = "Pregnacy related VTE";

/* Probleed - Procedure-related bleeding (LPR)*/;
%global LPRProbleed LPRLProbleed;
%let LPRProbleed         = J950C N986;
%let LPRProbleed_ICD8    = "";
%let LPRLProbleed        = "Procedure-related bleeding (LPR)";


/* R */
/* RArtrit */;
%global LPRRArtrit LPRRArtrit_ICD8 LPRLRArtrit;
%let LPRRArtrit        = M05 M06;
%let LPRRArtrit_ICD8   = "";
%let LPRLRArtrit       = "Reumatoid Artritis";

/* Renal */;
*%global LPRRenal LPRRenal_ICD8 LPRLRenal;
*%let LPRRenal          = I12 I13 N00 N01 N02 N03 N04 N05 N07 N11 N14 N17 N18 N19 Q61;
*%let LPRRenal_ICD8     = 581 582 583 584 59009 59320 59321 59322;
*%let LPRLRenal         = "Moderate/severe renal Disease";

/* Renal2 - Lines version (bl.a. fra Olesen 2012 NEJM)*/;
%global LPRRenal2 LPRRenal2_ICD8 LPRLRenal2;
%let LPRRenal2         = I12 I13 N00 N01 N02 N03 N04 N05 N07 N08 N11 N12 N140 N141 N142 N143 N144 N158 N160 N162 N163 N164 N168 N17 N18 N19 Q61 E102 E112 E132 E142;
%let LPRRenal2_ICD8    = 581 582 583 584 59009 59320 59321 59322;
%let LPRLRenal2        = "Moderate/severe renal disease";

/* renal3 - Renal Disease (old name renaldis) */;
%global LPRRenal3 LPRRenal3_ICD8 LPRLRenal3;
%let LPRRenal3         = I12 I13 I150 I151 N00 N01 N03 N05 N07 N08 N11 N14 N15 N16 N18 N19 N26 N27 Q611 Q162 Q163 Q164;
%let LPRRenal3_ICD8    = 582 583 584 5900 5901 5932;
%let LPRLRenal3        = "Renal Disease";

/* Renalstage1 */;
%global LPRRenalst1 LPRRenalst1_ICD8 LPRLRenalst1;
%let LPRRenalst1         = N181;
%let LPRRenalst1_ICD8    = "";
%let LPRLRenalst1        = "Chronic kidney disease, stage 1";

/* Renalstage2 */;
%global LPRRenalst2 LPRRenalst2_ICD8 LPRLRenalst2;
%let LPRRenalst2         = N182;
%let LPRRenalst2_ICD8    = "";
%let LPRLRenalst2        = "Chronic kidney disease, stage 2";

/* Renalstage3 */;
%global LPRRenalst3 LPRRenalst3_ICD8 LPRLRenalst3;
%let LPRRenalst3         = N183;
%let LPRRenalst3_ICD8    = "";
%let LPRLRenalst3        = "Chronic kidney disease, stage 3";

/* Renalstage4 */;
%global LPRRenalst4 LPRRenalst4_ICD8 LPRLRenalst4;
%let LPRRenalst4         = N184;
%let LPRRenalst4_ICD8    = "";
%let LPRLRenalst4        = "Chronic kidney disease, stage 4";

/* Renalstage5 */;
%global LPRRenalst5 LPRRenalst5_ICD8 LPRLRenalst5;
%let LPRRenalst5         = N185;
%let LPRRenalst5_ICD8    = "";
%let LPRLRenalst5        = "Chronic kidney disease, stage 5";

/* Renalstage9 */;
%global LPRRenalst9 LPRRenalst9_ICD8 LPRLRenalst9;
%let LPRRenalst9         = N189;
%let LPRRenalst9_ICD8    = "";
%let LPRLRenalst9        = "Chronic kidney disease, unspecified";

/* RheuDis - Rheumatic disorder   */
%global LPRRheuDis LPRRheuDis_ICD8 LPRLRheuDis;
%let LPRRheuDis        = M00 M01 M02 M03 M05 M06 M07 M08 M09 M10 M11 M12 M13 M14 M46 M47;
%let LPRRheuDis_ICD8   = "";
%let LPRLRheuDis       = "Rheumatic disorder";

/* S */
/* SE */;
%global LPRSE LPRSE_ICD8 LPRLSE;
%let LPRSE             = I74;
%let LPRSE_ICD8        = 444;
%let LPRLSE            = "systemic embolism";

/* sedat - Sedative/hypnotics */
%ICD_ATCdefines(LPR, sedat,"Sedative/hypnotics",F13, icd8=30429 30439);

/* SenHB */;
%global LPRSenHB LPRSenHB_ICD8 LPRLSenHB;
%let LPRSenHB          = I690 I691 I692;
%let LPRSenHB_ICD8     = "";
%let LPRLSenHB         = "Senfølge hjerneblødning";

/* Sepsis */
/* used in T051 project */
%global LPRSepsis LPRSepsis_ICD8 LPRLSepsis;
%let LPRSepsis        = A021 A282B A267 A327 A392 A392A A394 A400 A401 A402 A403 A408 A409 A41 A410 A411 A411A A412 A413 A414 A415 A418 A419 A427 A499A B377 B499A R572;
%let LPRSepsis_ICD8   = "";
%let LPRLSepsis       = "Sepsis";

/* Sepsis1 */
%global LPRSepsis1 LPRSepsis1_ICD8 LPRLSepsis1;
%let LPRSepsis1        = A40 A41;
%let LPRSepsis1_ICD8   = "";
%let LPRLSepsis1      = "Sepsis";

/* sevsepsis - Severe Sepsis */
/* used in T051 project */
%global LPRSevSepsis LPRSevSepsis_ICD8 LPRLSevSepsis;
%let LPRSevSepsis      = A419C R572;
%let LPRSevSepsis_ICD8 = "";
%let LPRLSevSepsis     = "Severe Sepsis and septic shock";

/* smoke - Active smoking */
%ICD_ATCdefines(LPR, smoke,"Active smoking",Z720 F17);

/* sliver - Sever Liver disease(FSEID00001577 t011) */
%ICD_ATCdefines(LPR, sliver,"Sever Liver Disease",B150 B160 B162 B190 K704 K72 K766 I85
                      icd8=07000 07002 07004 07006 07008 57300 4560);

/* Stroke - kombination af istroke og ibleed */  
%global LPRstroke LPRstroke_ICD8 LPRLstroke;
%let LPRstroke        = I60 I61 I62 I64;
%let LPRstroke_ICD8   = "";
%let LPRLstroke       = "Stroke";

/* SysLupus */;
%global LPRSysLupus LPRSysLupus_ICD8 LPRLSysLupus;
%let LPRSysLupus       = L93 M32;
%let LPRSysLupus_ICD8  = "";
%let LPRLSysLupus      = "Systemic Lupus";

/* Old name: SLE */
/* syslupus1 - Lupus Erythematosus   */
%global LPRSysLupus1 LPRSysLupus1_ICD8 LPRLSysLupus1;
%let LPRSyslupus1      = L93;
%let LPRSyslupus1_ICD8 = 6954;
%let LPRLSyslupus1     = "Lupus Erythematosus";

/* swe1 - Swelling of the limb */
%ICD_ATCdefines(LPR, swe1,"Swelling of the limb",R600 R224 R223);


/* T */
/* Tachy -  Atrial tachycardia */
%global LPRTachy LPRTachy_ICD8 LPRLTachy;
%let LPRTachy         = I471 I479;
%let LPRTachy_ICD8    = 42790 42794;
%let LPRLTachy        = "Atrial Tachycardia";

/* Tbleed - Traumatic CNS bleeding *//*Skal erstatte TIbleed (Okt 2020 - Line)*/;
%global LPRTbleed LPRLTbleed;
%let LPRTbleed         = S063C S064 S065 S066 S068B S068D S141C S141D S141E S241D S241E S241F S341D S341E S341F;
%let LPRTbleed_ICD8    = "";
%let LPRLTbleed        = "Traumatic CNS bleeding";

/* TendFall */
%global LPRTendFall LPRTendFall_ICD8 LPRLTendFall;
%let LPRTendFall       = R296;
%let LPRTendFall_ICD8  = "";
%let LPRLTendFall      = "Tendency to fall";

/* Thromphi - Inherited thrombophilia  */
%global LPRThromphi LPRThromphi_ICD8 LPRLThromphi;
%let LPRThromphi        = D685;
%let LPRThromphi_ICD8   = "";
%let LPRLThromphi       = "Inherited thrombophilia";

/* TIA - Transient Ischemic disease */;
%global LPRTIA LPRTIA_ICD8 LPRLTIA;
%let LPRTIA            = G45;
%let LPRTIA_ICD8       = 43509 43599;
%let LPRLTIA           = "Transient ischemic disease";

/* TIBleed */;
%global LPRTIBleed LPRTIBleed_ICD8 LPRLTIBleed;
%let LPRTIBleed        = S063C S064 S065 S066;
%let LPRTIBleed_ICD8   = "";
%let LPRLTIBleed       = "Traumatic intercranial bleeding";

/* Tobleed - Other traumatic bleeding */;
%global LPRTobleed LPRLTobleed;
%let LPRTobleed         = S003A S098A S259A S368A S368B S368D S378A T143C T792A T792B;
%let LPRTobleed_ICD8    = "";
%let LPRLTobleed        = "Other traumatic bleeding";

/* old name: FracTrau - Fracture/Trauma   */
/* trauma - Fracture/Trauma   */
%global LPRTrauma LPRTrauma_ICD8 LPRLTrauma;
%let LPRTrauma         = S T0 T11 T12 T13 T14 ;
%let LPRTrauma_ICD8    = 8 90 91 920 921 922 923 934 935 936 937 938 929 950 951 952 953 954 955 956 957 958 959;
%let LPRLTrauma        = "Fracture/Trauma";


/* U */
/* UA - Unstable Angina */;
%global LPRUA LPRUA_ICD8 LPRLUA;
%let LPRUA             = I20;
%let LPRUA_ICD8        = 413;
%let LPRLUA            = "Unstable Angina";

/* Ulcer - Ulcer disease */
%ICD_ATCdefines(LPR, ulcer,"Ulcer Disease",K221 K25 K26 K27 K28, icd8=53091 53098 531 532 533 534);

/* Unsnep - Unknown type Necropathy */
%ICD_ATCdefines(LPR, unsnep,"Unknown type Necropathy",N04 N18 N19 N26, icd8=581 584);

/* ustroke - Unspecified stroke */
%ICD_ATCdefines(LPR,ustroke,"Unspecified stroke",I64, icd8=436);

/* uti - urinary tract infection  */
%ICD_ATCdefines(LPR, uti,"Urinary Tract Infection",N30);

/* V */
/* VALVE  Bør verificeres med procedurekode som ofte ligger tidligere */
%global LPRVALVE LPRVALVE_ICD8 LPRLVALVE;
%let LPRvalve          = Z952 Z953 Z954;
%let LPRvalve_ICD8     = "";
%let LPRLvalve         = "Mechanical Heart Valve";

/* varice - lower extremity varicose veins */
%ICD_ATCdefines(LPR, varice,"Lower extremity varicose veins",I830 I831 I832 I839);

/* VariVein - Varicose veins  */
%global LPRVariVein LPRVariVein_ICD8 LPRLVariVein;
%let LPRVariVein        = I83;
%let LPRVariVein_ICD8   = 454;
%let LPRLVariVein       = "Varicose veins";

/* vascdem - vascular dementia */
%ICD_ATCdefines(LPR, vascdem,"vascular dementia",F01, icd8=29309 29319);

/* VTE */
%global LPRVTE LPRVTE_ICD8 LPRLVTE;
%let LPRvte            = I26 I801 I802 I803 I808 I809 I828 I829 I81 I822 I823 I636 I676 H348E H348F O882 O223 O229 O871 O879 O225 K751 O873;
%let LPRvte_ICD8       = 450 45100 45108 45109 45190 45192 45199 45299 45302 45304 321 67101 67102 67103 67108 67109 67309 67319 67399;
%let LPRLvte           = "Venous Thromboemolism";

/* VTE1 - Venous Thromboemobolism  */
%global LPRVTE1 LPRVTE1_ICD8 LPRLVTE1;
%let LPRVTE1        = I26 I801 I802 I803 I808 I809 I828 I829 I822 I823 O223 O229 O871 O879 O882;
%let LPRVTE1_ICD8   = "";
%let LPRLVTE1       = "Venous Thromboemobolism";


