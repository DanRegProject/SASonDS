/* SVN header
$Date: 2021-01-28 10:52:52 +0100 (to, 28 jan 2021) $
$Revision: 269 $
$Author: fflb6683 $
$Id: OPRkoder.sas 269 2021-01-28 09:52:52Z fflb6683 $
*/
/* Operation codes, use OPR and OPRL prefix', Official codes has prefix K which is omitted */
/* 26/6-2017 removing opr at the end (equal to version on SDS) */
/* A */
/* all - all operations */
%global OPRAll OPRLAll;
%let OPRAll        = KA KB KF KG KH KJ KK KL KM KN KP;
%let OPRLAll       = "All operations";

/* Arrhyo - heart arrhythm operations */
%global OPRArrhyo OPRLArrhyo;
%let OPRArrhyo      = KFP;
%let OPRLArrhyo     = "heart arrhythm operations";

/* Arrhyt - hjerte rytme operationer */
%global OPRArrhyt OPRLArrhyt;
%let OPRArrhyt      = KFPA KFPB KFPD KFPW;
%let OPRLArrhyt     = "Hjerte rytme operationer";

/* B */
/* C */
/* cabg - Coronary artery bypass graft */
%global OPRcabg OPRLcabg;
%let OPRCABG        = KFNA KFNC KFND KFNE;
%let OPRLCABG       = "Coronary artery bypass graft";

/* Caesar / Caesarian section  */
%global OPRCaesar OPRLCaesar;
%let OPRCaesar        = KMCA;
%let OPRLCaesar       = "Caesarian section";

/* F */
/* fn */
%global OPRfn OPRLfn;
%let OPRfn          = KFN;
%let OPRLfn         = "Percutanious coronary intervention or coronary artery bypass craft";

/* K */
/* kidtra */
%global OPRKidtra OPRLKidtra;
%let OPRKidtra      = KKAS00 KKAS10 KKAS20;
%let OPRLKidtra     = "Kidney transplantation";

/* kneehip - knæ og hofte operation */
%global OPRkneehip OPRLkneehip;
%let OPRkneehip     = KNGB KNGC KNGU KNFB KNFC KNFU;
%let OPRLkneehip    = "knæ og hofte operation"; 

/* L */
/* Lbleedopr - Bleeding in respiratory/thorax (OPR) (LINE)*/;
%global OPRLbleedopr OPRLLbleedopr;
%let OPRLbleedopr      = KGWD KGWD02 KGWE;
%let OPRLLbleedopr     = "Bleeding in respiratory/thorax (OPR)";

/* M  */
/* msurg */
%global OPRMSurg OPRLMSurg;
%let OPRMSurg       = KA KB KD KF KG KH KJ KK KL KM KN KP;
%let OPRLMSurg      = "Major surgery";

/* P */
/* pci */
%global OPRpci OPRLpci;
%let OPRpci         = KFNG;
%let OPRLpci        = "Percutanious coronary intervention";

/* pmicd */
%global OPRPMICd OPRLLpmicd;
%let OPRPMICD       = KFPG KFPE;
%let OPRLPMICD      = "Pacemaker / ICD operation Kode ophører i brug pr 2001";

/* Probleedopr - Procedure-related bleeding (OPR) (LINE)*/;
%global OPRProbleedopr OPRLProbleedopr;
%let OPRProbleedopr      = KAAB30 KAAD00 KAAD05 KAAD10 KAAD15 KABB40 KAWD KAWD00A KAWE KBWD KBWE KCKD90 KCWD KCWE KDWD KDWE KEWD KEWE KFWD KFWE KGWD KGWD02 KGWE KHWD KHWE KJWD KJWE KKEV KKEV02 KKWD KKWE KLWD KLWE KMBC40 KMWD KMWE KNAW79 KNAW89 KNBW79 KNBW89 KNCW79 KNCW89 KNDW79 KNDW89 KNEW79 KNEW89 KNFW79 KNFW89 KNGW79 KNGW89 KNHW79 KNHW89 KPWD KPWE KQWD KQWE;
%let OPRLProbleedopr     = "Procedure-related bleeding (OPR)";

/* V */
/* valveo */
%global OPRvalveo OPRLvalveo;
%let OPRValveo      = KFG KFK KFM;
%let OPRLValveo     = "Heart valve operation";

  
/*mechvalve - mechanical valve prothesis*/
%let oprmechvalve = kfge00 kfkd00 kfjf00 kfmd00;
%let oprlmechvalve = "mechanical valve prothesis";
