/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: ATCkoder.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/

/* special cases */
*%include "&macropath/ICD_ATC_codes/ATCriskscores.sas";

/* A */
/* ace - ACE-inhibitor */
%global ATCACE ATCLACE;
%let ATCACE         = C09A;
%let ATCLACE        = "ACE-inhibitors";

/* Aldo */
%global ATCAldo ATCLAldo;
%let ATCAldo         = C03DA;
%let ATCLAldo        = "Aldosterone antagonists";

/* ALFA */
%global ATCalfa ATCLalfa;
%let ATCalfa         = C02A C02B C02C;
%let ATCLalfa        = "Alfa adrenic block";

/* Amio */
%global ATCAmio ATCLAmio;
%let ATCAmio         = C01BD01;
%let ATCLAmio        = "Amiodarone";

/* Antiand - Antiandrogener */
%global ATCantiand ATCLantiand;
%let ATCantiand      = G03HB;
%let ATCLantiand     = "Antiandrogener";

/*Antidem - Anti-dementia medication */
%ICD_ATCdefines(ATC, antidem, "Antiandrogener", N06D);

/* Antithy */
%global ATCAntithy ATCLAntithy;
%let ATCAntiThy      = H03B;
%let ATCLAntiThy     = "Antithyroids";

/* Apixa */
%global ATCApixa ATCLApixa;
%let ATCApixa        = B01AF02;
%let ATCLApixa       = "Apixaban";

/* arb - Angiotension II receptor blockers/antagonists */
%global ATCARB ATCLARB;
%let ATCARB         = C09C;
%let ATCLARB        = "Angiotension II receptor blockers/antagonists";

/* Aroinhib */
%global ATCAroinhib ATCLAroinhib;
%let ATCAroInhib     = L02BG;
%let ATCLAroInhib    = "Aromatase inhibitors";

/* Aspirin */
%global ATCAspirin ATCLAspirin;
%let ATCaspirin      = B01AC06;
%let ATCLaspirin     = "Aspirin";


/* B */
/* Benzo */
%global ATCBenzo ATCLBenzo;
%let ATCBenzo        = N03AE N05BA N05CD N05CF;
%let ATCLBenzo       = "Benzodiazaepines";

/* Beta */
%global ATCBeta ATCLBeta;
%let ATCbeta         = C07;
%let ATCLbeta        = "Beta blocker";

/* Bloodlow - Blood glucose lowering drugs, excluding insulins */
%global ATCbloodlow ATCLbloodlow;
%let ATCbloodlow      = A10B;
%let ATCLbloodlow     = "Blood glucose lowering drugs, excluding insulins";

/* C */
/* Calcium */
%global ATCCalcium ATCLCalcium;
%let ATCcalcium      = C07F C08 C09BB C09DB;
%let ATCLcalcium     = "Calcium Channel blocker";

/* Carba */
%global ATCCarba ATCLCarba;
%let ATCcarba        = N03AF01;
%let ATCLcarba       = "Carbamizipine";

/* Clarit */
%global ATCClarit ATCLClarit;
%let ATCClarit       = J01FA09;
%let ATCLClarit      = "Clarithromycin";

/* clomi - Clomifen */
%global ATCclomi ATCLclomi;
%let ATCclomi        = G03GB02;
%let ATCLclomi       = "Clomifen";

/* Clopi */
%global ATCClopi ATCLClopi;
%let ATCClopi        = B01AC04;
%let ATCLClopi       = "Clopidogrel";

/* Coumarin */
%global ATCCoumarin ATCLCoumarin;
%let ATCCoumarin     = B01AA;
%let ATCLCoumarin    = "Coumarin derivatives (warfarin & phenprocoumon)";

/* Cyclo */
%global ATCCyclo ATCLCyclo;
%let ATCcyclo        = L04AD01;
%let ATCLcyclo       = "Cyclosporine";


/* D */
/* Dbgtran */
%global ATCDbgtran ATCLDbgtran;
%let ATCdbgtran      = B01AE07;
%let ATCLdbgtran     = "Dabigatran";

/* DiabATC - Insuliner og Metformin */
%global ATCDiabATC ATCLDiabATC;
%let ATCdiabatc      = A10;
%let ATCLdiabatc     = "Diabetes Mellitus";

/* Digoxin */
%global ATCDigoxin ATCLDigoxin;
%let ATCDigoxin      = C01AA05;
%let ATCLDigoxin     = "Digoxin";

/* Donep - Donepzil */
%ICD_ATCdefines(ATC, donep, "Donepezil", N06DA02);

/* Drone */
%global ATCDrone ATCLDrone;
%let ATCDrone        = C01BD07;
%let ATCLDrone       = "Dronedarone";


/* E */
/* edoxa */
%global ATCedoxa ATCLedoxa;
%let ATCedoxa        = B01AF03;
%let ATCLedoxa       = "Edoxaban";


/* F */
/* Fleca - Flecainid */
%ICD_ATCdefines(ATC, fleca, "Flecainid", C01BC04);

/* Fluco - Fluconazol */
%ICD_ATCdefines(ATC, fluco, "Fluconazol", J02AC01);

/* Fonda */
%global ATCFonda ATCLFonda;
%let ATCFonda        = B01AX05;
%let ATCLFonda       = "Fondaparinux";


/* G */
/* Galant - Galantamin */
%ICD_ATCdefines(ATC, galant, "Galantamin", N06DA04);

/* GP */
%global ATCGP ATCLGP;
%let ATCGP           = B01AC16;
%let ATCLGP          = "GPIIb/IIIa antagonists (eptifibatide)";


/* H  */
/* H2 */
%global ATCH2 ATCLH2;
%let ATCH2           = A02BA;
%let ATCLH2          = "H2-receptor antagonistis";

/* heparins */
%global ATCheparins ATCLheparins;
%let ATCHeparins     = B01AB;
%let ATCLHeparins    = "Low molecular weight heparins";

/* HFatc - Congestive heart failure - HFatc */
%global ATCHFatc ATCLHFatc;
%let ATCHFATC        = C03C;
%let ATCLHFATC       = "Congestive heart failure";

/* hypATC removed */

/* Hivprot - HIV_proteasehæmmere */
%ICD_ATCdefines(ATC, hivprot, "HIV-protease inhibitors", J05AE10 J05AE08 J05AR14 J05AR15);

/* HormCnt - Hormonal contraceptives   */
%global ATCHormCnt ATCLHormCnt;
%let ATCHormCnt        = G03A;
%let ATCLHormCnt       = "Hormonal contraceptives";

/* HRT - Hormone replacement therapy */
%global ATCHRT ATCLHRT;
%let ATCHRT        = G03C G03F;
%let ATCLHRT       = "Hormone replacement therapy";


/* I */
/* Insulin - Insulins and analogues*/
%global ATCinsulin ATCLinsulin;
%let ATCinsulin      = A10A;
%let ATCLinsulin     = "Insulin and analogues";

/* Itracon */
%global ATCItracon ATCLItracon;
%let ATCItracon      = J02AC02;
%let ATCLItracon     = "Itraconazole";

/* Ivabrad */
%global ATCIvabrad ATCLIvabrad;
%let ATCIvabrad      = C01EB17;
%let ATCLIvabrad     = "Ivabradin";


/* K */
/* keto */
%global ATCketo ATCLketo;
%let ATCKeto         = J02AB02;
%let ATCLKeto        = "Systemic ketoconazole";

/* L */
/* Loop */
%global ATCLoop ATCLLoop;
%let ATCLoop         = C03C C03EB;
%let ATCLLoop        = "Loop diuretics";

/* M */
/* Mecil - Mecillinam */
%ICD_ATCdefines(ATC, mecil, "Mecillinam", J01CA08);

/* Mema - Memantin */
%ICD_ATCdefines(ATC, mema, "Memantin", N06DX01);

/* metform - Metformin */
%global ATCmetform ATCLmetform;
%let ATCmetform      = A10BA02;
%let ATCLmetform     = "Metformin";

/* N */

/* Nitro - Nitrofurantoin */
%ICD_ATCdefines(ATC, nitro, "Nitrofurantoin", J01XE01);

/* Nonloop */
%global ATCNonloop ATCLNonloop;
%let ATCNonLoop      = C02DA C02L C03A C03B C03D C03EA C03X C07C C07D C08G C09BA C09DA C09XA52;
%let ATCLNonLoop     = "Non-loop diuretics";

/* NSAID */
%global ATCNSAID ATCLNSAID;
%let ATCNSAID        = M01AA M01AB M01AC M01AE M01AG M01AH M01AX01 ;
%let ATCLNSAID       = "NSAIDs";


/* O */
/* OtherDiab */
%global ATCOtherDiab ATCLOtherDiab;
%let ATCOtherDiab    = A10X;
%let ATCLOtherDiab   = "Other drugs used in diabetes";


/* P */
/* Persantin */
%global ATCPersantin ATCLPersantin;
%let ATCPersantin    = B01AC07;
%let ATCLPersantin   = "Persantin";

/* Phen */
%global ATCPhen ATCLPhen;
%let ATCPhen         = B01AA04;
%let ATCLPhen        = "Phenprocoumon";

/* prasu - Prasugrel */
%ICD_ATCdefines(ATC, prasu, "Prasugrel", B01AC22);

/* Proton */
%global ATCProton ATCLProton;
%let ATCProton       = A02BC;
%let ATCLProton      = "Proton-pump inhibitors";


/* Q */
/* Quin */
%global ATCQuin ATCLQuin;
%let ATCQuin         = C01BA01;
%let ATCLQuin        = "Quinidine";


/* R */
/* Renin */
%global ATCRenin ATCLRenin;
%let ATCRenin        = C09;
%let ATCLRenin       = "Renin-angiotensin inhibitor (ARB or ACE inhibitor)";

/* riva -  Rivarox */
%global ATCRiva ATCLRiva;
%let ATCRiva         = B01AF01;
%let ATCLRiva        = "Rivaroxaban";

/* rivast - Rivastigmin */
%ICD_ATCdefines(ATC, rivast, "Rivastigmin", N06DA03);

/* S */
/* Sota - Sotalol */
%ICD_ATCdefines(ATC, sota, "Sotalol", C07AA07);

/* SSRI */
%global ATCSSRI ATCLSSRI;
%let ATCSSRI         = N06AB;
%let ATCLSSRI        = "Selective serotonin reuptake inhibitors";

/* Statins */
%global ATCStatins ATCLStatins;
%let ATCStatins      = C10;
%let ATCLStatins     = "Statins";

/* sulfa - Sulfamethiozole */
%ICD_ATCdefines(ATC, sulfa, "Sulfamethiozole", J01EB02);


/* Sulfin */
%global ATCSulfin ATCLSulfin;
%let ATCSulfin       = M04;
%let ATCLSulfin      = "Sulfinpyrazone";

/* Syscort */
%global ATCSyscort ATCLSyscort;
%let ATCSysCort      = H02;
%let ATCLSysCort     = "Systemic corticosteroids";


/* T */
/* Tacrol */
%global ATCTacrol ATCLTacrol;
%let ATCTacrol       = L04AD02;
%let ATCLTacrol      = "Tacrolimus";

/* TAThaLe - Tamoxifen Thalidomide Lenalidomide */
%global ATCTAThaLe ATCLTAThaLe;
%let ATCTAThaLe        = L02BA01 L04AX04 L04AX02;
%let ATCLTAThaLe       = "Tamoxifen Thalidomide Lenalidomide";

/* Thiazol */
%global ATCThiazol ATCLThiazol;
%let ATCThiazol      = A10BG;
%let ATCLThiazol     = "Thiazolidinediones";

/* Thien */
%global ATCThien ATCLThien;
%let ATCThien        = B01AC04 B01AC24 B01AC22; /*15/5/17 - tilføjet B01AC24 og B01AC22 (af Line)*/
%let ATCLThien       = "Thienopyridines (clopidogel, tricagrelor, prasugrel";

/* Tica - Ticagrelor */
%ICD_ATCdefines(ATC, tica, "Ticagrelor", B01AC24);

/* TMP - Trimethoprim */
%ICD_ATCdefines(ATC, tmp, "Trimetroprim", J01EA01);


/* V */
/* Vaso */
%global ATCVaso ATCLVaso;
%let ATCVaso         = C02DB C02DD C02DG C04 C05;
%let ATCLVaso        = "Vasodilator";

/* Vera */
%global ATCVera ATCLVera;
%let ATCVera         = C08DA01;
%let ATCLVera        = "Verapamil";


/* W */
/* Warfarin */
%global ATCWarfarin ATCLWarfarin;
%let ATCWarfarin     = B01AA03;
%let ATCLWarfarin    = "Warfarin";
