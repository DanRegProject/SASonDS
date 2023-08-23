/* SVN header
$Date: 2018-07-13 11:31:45 +0200 (fr, 13 jul 2018) $
$Revision: 115 $
$Author: FCNI6683 $
$Id: UBEkoder.sas 115 2018-07-13 09:31:45Z FCNI6683 $
*/
/* procedure codes, use UBE and UBEL prefix', use full code */
/* getOPR is used to extract data, with option type=UBE */

/* old version 
%global UBEabla UBELabla;
%let UBEAbla        = BFFB0 BFFB1 BFFB3 BFFB4 BFFB5;
%let UBELAbla       = "Ablation";
*/
/* abla - Ablation */
%global UBEabla UBELabla;
%let UBEAbla        = BFFB;
%let UBELAbla       = "Ablation";

/* afliab - Atrial fibrillation ablation  */
%global UBEafliab UBELafliab;
%let UBEafliab        = BFFB04;
%let UBELafliab       = "Atrial Fibrillation Ablation";

/* afluab - Atrial flutter ablation  */
%global UBEafluab UBELafluab;
%let UBEafluab        = BFFB03;
%let UBELafluab       = "Atrial Flutter Ablation";

/* Angio - Angiography  */
%global UBEAngio UBELAngio;
%let UBEAngio        = UXAG UXAC10;
%let UBELAngio       = "Angiography";

/* cag - coronary angiography - kranspulsåreundersøgelse */
%global UBECAG UBELCAG;
%let UBECAG         = UXAC85;
%let UBELCAG        = "Coronary angiography";

/* CT - CT-scan   */
%global UBEct UBELct;
%let UBEct        = UXC;
%let UBELct       = "CT-scan";

/* CT1 - CT-scan   */
%global UBEct1 UBELct1;
%let UBEct1       = UXCG UXCC;
%let UBELct1      = "CT-scan";

/* CVK - Central venous catheter */
%global UBECVK UBELCVK;
%let UBECVK        = BMBZ61 BMBZ71 BMBZ51 BMLA01 BMBLA02 BMBLA03;
%let UBELCVK       = "Central venous catheter";

/* dc - dc konvertering */
%global UBEDC UBELDC;
%let UBEDC          = BFFA01;
%let UBELDC         = "DC-konvertering";

/* dialys - Acute and chronic dialysis, haemo & peritoneal */
%global UBEdialys UBELdialys;
%let UBEdialys      = BJFD;
%let UBELdialys     = "Acute and chronic dialysis, haemo & peritoneal";

/* dialys2 - Dialysis in Chronic kidney disease, haemo & peritoneal */
%global UBEdialys2 UBELdialys2;
%let UBEdialys2      = BJFD2;
%let UBELdialys2     = "Dialysis in Chronic kidney disease, haemo & peritoneal";

/* ec - Electrical cardioversion */
%global UBEec UBELec;
%let UBEEC          = BFFA00 BFFA01 BFFA04;
%let UBELEC         = "Electrical cardioversion";

/* Ecco - Ultrasonograpy including echocardiography   */
%global UBEEcco UBELEcco;
%let UBEEcco        = UXUC80 UXUC81;
%let UBELEcco       = "Ultrasonograpy including echocardiography";

/* HRTUBE - Hormone replacement therapy */
%global UBEHRTUBE UBELHRTUBE;
%let UBEHRTUBE        = BBHG0;
%let UBEHRTUBE_ICD8   = "";
%let UBELHRTUBE       = "Hormone replacement therapy";

/* MRveno - MR venography - tillægskode! */
%global UBEMRveno UBELMRveno;
%let UBEMRveno        = UXZ52;
%let UBELMRveno       = "MR venography";

/* MyeloSKS - Myeloproliferative disorders (polycythemia vera, essential thrombocytemia)  */
%global UBEMyeloSKS UBELMyeloSKS;
%let UBEMyeloSKS        = ZM99503 ZM99623;
%let UBELMyeloSKS       = "Myeloproliferative disorders (polycythemia vera, essential thrombocytemia)";

/* ObesUBE  - behandlings- og plejeklassifikation */
%global UBEObesube UBELObesube;
%let UBEObesube     = BQFT03 BQFS01;
%let UBELObesube       = "Obesity";

/* pm - Pacemaker */
%global UBEPM UBELPM;
%let UBEPM          = BFCA0 BFCA6 BFCA9;
%let UBELPM         = "Pacemaker";

/* old name: ullow */
/* ullow - Ultrasonography UE  - Klassifikation af undersøgelser */
%global UBEullow UBELullow;
%let UBEullow        = UXUG;
%let UBELullow       = "Ultrasonography UE";

/* VentPerf - Ventilation-perfusion examination  - klassifikation af undersøgelser */
%global UBEVentPerf UBELVentPerf;
%let UBEVentPerf        = WLHGS;
%let UBELVentPerf       = "Ventilation-perfusion examination";
