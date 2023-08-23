/* This file is used to specify multicomorbidity scores, observe entry groups defined by
    LPR hospital discharge information
    CPR demographic information
    OTH other information - entries within here may need specific coding in multicoscore.sas
    in any group, entry postfix
    W assigns weight of entry
    C criterion, in LPR being options for getDIAG, in CPR and OTH definition of entry
        macro variable MCSDate can be used in defition
    LINK is used for potential non-identity link between linear predictor and score,
        macro variable score must be used
    */
%let mcolist = CHARLSON SEGAL HFRS;

/* Charlson:
  ICD10 from http://bmcmedresmethodol.biomedcentralcom/articles/10.1186/1471-2288-11-83,
  The predictive value of ICD-10 diagnostic coding used to assess Charlson comorbidity index conditions
  in the population-based Danish National Registry of Patients */
/* Charlson weight 1 */
%let LPRcharlson1        = I21 I22 I23;
%let LPRcharlson1_ICD8   = 410;
%let LPRLcharlson1       = "Myocardial infarction";
%let LPRcharlson1W       = 1;
%let LPRcharlson2        = I50 I110 I130 I132;
%let LPRcharlson2_ICD8   = 42709 42710 42711 42719 42899 78249;
%let LPRLcharlson2       = "Congestive heart failure";
%let LPRcharlson2W       = 1;
%let LPRcharlson3        = I70 I71 I72 I73 I74 I77;
%let LPRcharlson3_ICD8   = 440 441 442 443 444 445;
%let LPRLcharlson3       = "Peripheral vascular disease";
%let LPRcharlson3W       = 1;
%let LPRcharlson4        = I60 I61 I62 I63 I64 I65 I66 I67 I68 I69 G45 G46;
%let LPRcharlson4_ICD8   = 430 431 432 433 434 435 436 437 438;
%let LPRLcharlson4       = "Cerebrovasvular disease";
%let LPRcharlson4W       = 1;
%let LPRcharlson5        = F00 F01 F02 F03 F051 G30;
%let LPRcharlson5_ICD8   = 29009 29010 29011 29012 29013 29014 29015 29016 29017 29018 29019 29309;
%let LPRLcharlson5       = "Dementia";
%let LPRcharlson5W       = 1;
%let LPRcharlson6        = J40 J41 J42 J43 J44 J45 J46 J47 J60 J61 J62 J63 J64 J65 J66 J67 J684 J701 J703 J841 J920 J961 J982 J983;
%let LPRcharlson6_ICD8   = 490 491 492 493 515 516 517 518;
%let LPRLcharlson6       = "Chronic Pulmonary disease";
%let LPRcharlson6W       = 1;
%let LPRcharlson7        = M05 M06 M08 M09 M30 M31 M32 M33 M34 M35 M36 D86;
%let LPRcharlson7_ICD8   = 712 716 734 446 13599;
%let LPRLcharlson7       = "Connective tissue disease";
%let LPRcharlson7W       = 1;
%let LPRcharlson8        = K221 K25 K26 K27 K28;
%let LPRcharlson8_ICD8   = 53091 53098 531 532 533 534;
%let LPRLcharlson8       = "Ulcer disease";
%let LPRcharlson8W       = 1;
%let LPRcharlson9        = B18 K700 K701 K702 K703 K709 K71 K73 K74 K760;
%let LPRcharlson9_ICD8   = 571 57301 57304;
%let LPRLcharlson9       = "Mild liver disease";
%let LPRcharlson9W       = 1;
%let LPRcharlson10       = E100 E101 E109 E110 E111 E119;
%let LPRcharlson10_ICD8  = 249 250;
%let LPRLcharlson10      = "Diabetes Mellitus";
%let LPRcharlson10W       = 1;
/* Charlson weight 2 */
%let LPRcharlson11        = G81 G82;
%let LPRcharlson11_ICD8   = 344;
%let LPRLcharlson11       = "Hemiplegia";
%let LPRcharlson11W       = 2;
%let LPRcharlson12        = I12 I13 N00 N01 N02 N03 N04 N05 N07 N11 N14 N17 N18 N19 Q61;
%let LPRcharlson12_ICD8   = 403 404 580 581 582 583 584 59009 59319 7531 792;
%let LPRLcharlson12       = "Moderate/severe renal disease";
%let LPRcharlson12W       = 2;
%let LPRcharlson13        = E102 E103 E104 E105 E106 E107 E108 E112 E113 E114 E115 E116 E117 E118;
%let LPRcharlson13_ICD8   = 24901 24902 24903 24904 24905 24908 25001 25002 25003 25004 25005 25008;
%let LPRLcharlson13       = "Diabetes Mellitus with chronic complications";
%let LPRcharlson13W       = 2;
%let LPRcharlson14        = C0 C1 C2 C3 C4 C5 C6 C70 C71 C72 C73 C74 C75;
%let LPRcharlson14_ICD8   = 14 15 16 17 18 190 191 192 193 194;
%let LPRLcharlson14       = "Any tumor";
%let LPRcharlson14W       = 2;
%let LPRcharlson15        = C91 C92 C93 C94 C95;
%let LPRcharlson15_ICD8   = 204 205 206 207;
%let LPRLcharlson15       = "Leukemia";
%let LPRcharlson15W       = 2;
%let LPRcharlson16        = C81 C82 C83 C84 C85 C88 C90 C96;
%let LPRcharlson16_ICD8   = 200 201 202 203 27559;
%let LPRLcharlson16       = "Lymphoma";
%let LPRcharlson16W       = 2;
/* Charlson weight 3 */
%let LPRcharlson17        = B150 B160 B162 B190 K704 K72 K766 I85;
%let LPRcharlson17_ICD8   = 07000 07002 07004 07006 07008 57300 4560;
%let LPRLcharlson17       = "Moderate/severe liver disease";
%let LPRcharlson17W       = 3;
/* Charlson weight 6 */
%let LPRcharlson18        = C76 C77 C78 C79 C80;
%let LPRcharlson18_ICD8   = 195 196 197 198 199;
%let LPRLcharlson18       = "Metastatic solid tumor";
%let LPRcharlson18W       = 6;
%let LPRcharlson19        = B21 B22 B23 B24;
%let LPRcharlson19_ICD8   = 07983;
%let LPRLcharlson19      = "AIDS";
%let LPRcharlson19W       = 6;
%let LPRcharlsonN        = 19; /* 2 diseases with weight 6 each */

/* Segal et al, Development of a claims-based frailty indicator anchored to a well-established frailty phenotype. Med care 2017 jul 55(7) 716-722 */
%let LINKsegal        = 1/(1+exp(-&score&MCSDate)); /*IGNORE THE WARNING. Placeholder. Used in multicoscores.sas*/
%let LPRsegal1        = G20;
%let LPRsegal1_ICD8   = ;
%let LPRLsegal1       = "Parkinson";
%let LPRsegal1W       = 0.5;
%let LPRsegal2        = R26 Z74 Z75 Z993;
%let LPRsegal2_ICD8   = ;
%let LPRLsegal2       = "Impaired mobility";
%let LPRsegal2W        = 1.24;
%let LPRsegal3        = F204 F251 F31 F32 F33 F341 F38 F41 F43 F44 F920 T43 Y490 Y492;
%let LPRsegal3_ICD8   = ;
%let LPRLsegal3       = "Depression, wide def.";
%let LPRsegal3W        = 0.54;
%let LPRsegal4        = &LPRhf2;
%let LPRsegal4_ICD8   = ;
%let LPRLsegal4       = &LPRLhf2;
%let LPRsegal4W       = 0.50;
%let LPRsegal5        = M0 M1 M20 M21 M22 M23 M24 M32 M33 M34 M35 M36 M43 M6 M70 M71 M72 M75 M76 M77 M78 M79 R26 R29 Z87;
%let LPRsegal5_ICD8   = ;
%let LPRLsegal5       = "Arthritis (any type)";
%let LPRsegal5W       = 0.43;
%let LPRsegal6        = F0 G30 G31 R41 R46 Z032;
%let LPRsegal6_ICD8   = ;
%let LPRLsegal6       = "Cognitive impairment";
%let LPRsegal6W       = 0.33;
%let LPRsegal7        = I6;
%let LPRsegal7_ICD8   = ;
%let LPRLsegal7       = "Stroke (wide def)";
%let LPRsegal7W       = 0.28;
%let LPRsegal8        = F06 f20 F21 F22 F23 F24 F25 F28 F29 F32 F33 F44 F600;
%let LPRsegal8_ICD8   = ;
%let LPRLsegal8       = "Paranoia";
%let LPRsegal8W       = 0.24;
%let LPRsegal9        = L89 L97 L98;
%let LPRsegal9_ICD8   = ;
%let LPRLsegal9       = "Chronic skin ulcer";
%let LPRsegal9W       = 0.23;
%let LPRsegal10        = A221 A37 A481 B250 B440 B778 J1 J69;
%let LPRsegal10_ICD8   = ;
%let LPRLsegal10       = "Pneumonia (wide def)";
%let LPRsegal10W       = 0.21;
%let LPRsegal11        = A20 A21 A22 A31 A36 A46 L0 L10 L88 L98 K12 E83;
%let LPRsegal11_ICD8   = ;
%let LPRLsegal11       = "Skin and soft tissue infection";
%let LPRsegal11W       = 0.18;
%let LPRsegal12        = B35 B36 B37 B38 B39 B4;
%let LPRsegal12_ICD8   = ;
%let LPRLsegal12       = "Mycoses";
%let LPRsegal12W       = 0.14;
%let LPRsegal13        = M10 M11 N20;
%let LPRsegal13_ICD8   = ;
%let LPRLsegal13       = "Gout or other crystal-induced arthopathy";
%let LPRsegal13W       = 0.08;
%let LPRsegal14        = W0 W1;
%let LPRsegal14_ICD8   = ;
%let LPRLsegal14       = "Falls";
%let LPRsegal14W       = 0.08;
%let LPRsegal15        = E106F E116F G45 M R29 Z783;
%let LPRsegal15_ICD8   = ;
%let LPRLsegal15       = "Muscoloskeletal problems";
%let LPRsegal15W       = 0.05;
%let LPRsegal16        = A368 N10 N11 N12 N15 N16 N288 N30 N34 N35 N390;
%let LPRsegal16_ICD8   = ;
%let LPRLsegal16       = "Urinary tract infection (wide def)";
%let LPRsegal16W       = 0.05;
%let LPRsegalN         = 16;

%let CPRLsegal1       = "Age";
%let CPRsegal1C       = (&MCSDate-birthdate)/365; /*IGNORE THE WARNING. Placeholder. Used in multicoscores.sas*/
%let CPRsegal1W       = 0.09;
%let CPRLsegal2       = "Male sex";
%let CPRsegal2C       = sex=0;
%let CPRsegal2W       = -0.19;
%let CPRLsegal3       = "White Race";
%let CPRsegal3W       = -0.49;
%let CPRsegal3C       = 1; /* all defined as white race*/
%let CPRsegalN         = 3;

%let OTHLsegal1       = "Intercept";
%let OTHsegal1W       = -9;
%let OTHsegal1C       = 1;
%let OTHLsegal2       = "Admission past 6 mo";
%let OTHsegal2W       = 0.09;
%let OTHsegal2C       = (&MCSDate-indate)/30.4<6; /* tweak in multicoscore to include date of last hospitalisation */ /*IGNORE THE WARNING. Placeholder. Used in multicoscores.sas*/
%let OTHLsegal3       = "Charlson >0";
%let OTHsegal3W       = 0.31;
%let OTHsegal3C       = (Charlson&MCSDate >0); /*IGNORE THE WARNING. Placeholder. Used in multicoscores.sas*/
%let OTHsegalN         = 3;


/*Hospital Frailty Risk Score(HFRS)*/
%let OTHLHFRS1       = "Intercept";
%let OTHHFRS1W       = 0;
%let OTHHFRS1C       = 1;
%let OTHHFRSN        = 1;

%let LPRHFRS1        = A04;
%let LPRHFRS1_ICD8   = ;
%let LPRLHFRS1       = "Bacterial intest infect";
%let LPRHFRS1W      = 1.1;

%let LPRHFRS2        = A09;
%let LPRHFRS2_ICD8   = ;
%let LPRLHFRS2       = "Diarrhoea infectious";
%let LPRHFRS2W      = 1.1;

%let LPRHFRS3        = A41;
%let LPRHFRS3_ICD8   = ;
%let LPRLHFRS3       = "Other Septicaemia";
%let LPRHFRS3W       = 1.6;

%let LPRHFRS4        = B95;
%let LPRHFRS4_ICD8   = ;
%let LPRLHFRS4		  = "Streptococcus";
%let LPRHFRS4W       = 1.7;

%let LPRHFRS5        = B96;
%let LPRHFRS5_ICD8   = ;
%let LPRLHFRS5       = "Other bacterial agents as cause";
%let LPRHFRS5W       = 2.9;
%let LPRHFRS5C       = diagtype="B";

%let LPRHFRS6        = D64;
%let LPRHFRS6_ICD8   = ;
%let LPRLHFRS6       = "Other anaemias";
%let LPRHFRS6W       = 0.4;

%let LPRHFRS7        = E05;
%let LPRHFRS7_ICD8   = ;
%let LPRLHFRS7       = "Thyrotoxicosis";
%let LPRHFRS7W       = 0.9;

%let LPRHFRS8        = E16;
%let LPRHFRS8_ICD8   = ;
%let LPRLHFRS8       = "Pancreatic internal secretion";
%let LPRHFRS8W       = 1.4;

%let LPRHFRS9        = E53;
%let LPRHFRS9_ICD8   = ;
%let LPRLHFRS9       = "Vitamin B deficiency";
%let LPRHFRS9W       = 1.9;

%let LPRHFRS10        = E55;
%let LPRHFRS10_ICD8   = ;
%let LPRLHFRS10       = "Vitamin D deficiency";
%let LPRHFRS10W       = 1;

%let LPRHFRS11        = E83;
%let LPRHFRS11_ICD8   = ;
%let LPRLHFRS11       = "Disorders of mineral metabolism";
%let LPRHFRS11W       = 0.4;

%let LPRHFRS12        = E86;
%let LPRHFRS12_ICD8   = ;
%let LPRLHFRS12       = "Volume depletion";
%let LPRHFRS12W       = 2.3;

%let LPRHFRS13        = E87;
%let LPRHFRS13_ICD8   = ;
%let LPRLHFRS13       = "Fluid electrolyte balance disorders";
%let LPRHFRS13W       = 2.3;

%let LPRHFRS14        = F00;
%let LPRHFRS14_ICD8   = ;
%let LPRLHFRS14       = "Alzheimer Dementia";
%let LPRHFRS14W       = 7.1;

%let LPRHFRS15        = F01;
%let LPRHFRS15_ICD8   = ;
%let LPRLHFRS15       = "Vascular dementia";
%let LPRHFRS15W       = 2;

%let LPRHFRS16        = F03;
%let LPRHFRS16_ICD8   = ;
%let LPRLHFRS16       = "Unspecified dementia";
%let LPRHFRS16W       = 2.1;

%let LPRHFRS17        = F05;
%let LPRHFRS17_ICD8   = ;
%let LPRLHFRS17       = "Delerium";
%let LPRHFRS17W       = 3.2;

%let LPRHFRS18        = F10;
%let LPRHFRS18_ICD8   = ;
%let LPRLHFRS18       = "Alcohol related mental disorders";
%let LPRHFRS18W       = 0.7;

%let LPRHFRS19        = F32;
%let LPRHFRS19_ICD8   = ;
%let LPRLHFRS19       = "Depressive episode";
%let LPRHFRS19W       = 0.5;

%let LPRHFRS20        = G20;
%let LPRHFRS20_ICD8   = ;
%let LPRLHFRS20       = "Parkinson";
%let LPRHFRS20W       = 1.8;

%let LPRHFRS21        = G30;
%let LPRHFRS21_ICD8   = ;
%let LPRLHFRS21       = "Alzheimers";
%let LPRHFRS21W       = 4;

%let LPRHFRS22        = G31;
%let LPRHFRS22_ICD8   = ;
%let LPRLHFRS22       = "Other degenerative disease";
%let LPRHFRS22W       = 1.2;

%let LPRHFRS23        = G40;
%let LPRHFRS23_ICD8   = ;
%let LPRLHFRS23       = "Epilepsy";
%let LPRHFRS23W       = 1.4;

%let LPRHFRS24        = G45;
%let LPRHFRS24_ICD8   = ;
%let LPRLHFRS24       = "TIA";
%let LPRHFRS24W       = 1.2;

%let LPRHFRS25        = G81;
%let LPRHFRS25_ICD8   = ;
%let LPRLHFRS25       = "Hemiplegia";
%let LPRHFRS25W       = 4.4;

%let LPRHFRS26        = H54;
%let LPRHFRS26_ICD8   = ;
%let LPRLHFRS26       = "Blidness";
%let LPRHFRS26W       = 1.9;

%let LPRHFRS27        = H91;
%let LPRHFRS27_ICD8   = ;
%let LPRLHFRS27       = "Hearing loss";
%let LPRHFRS27W       = 0.9;

%let LPRHFRS28        = I63;
%let LPRHFRS28_ICD8   = ;
%let LPRLHFRS28       = "Istroke";
%let LPRHFRS28W       = 0.8;

%let LPRHFRS29        = I67;
%let LPRHFRS29_ICD8   = ;
%let LPRLHFRS29       = "Cerebrovascular disease";
%let LPRHFRS29W       = 2.6;

%let LPRHFRS30        = I69;
%let LPRHFRS30_ICD8   = ;
%let LPRLHFRS30       = "Sequale cerebrovas dis";
%let LPRHFRS30W       = 3.7;

%let LPRHFRS31        = I95;
%let LPRHFRS31_ICD8   = ;
%let LPRLHFRS31       = "Hypotension";
%let LPRHFRS31W       = 1.6;

%let LPRHFRS32        = J18;
%let LPRHFRS32_ICD8   = ;
%let LPRLHFRS32       = "Pneumonia";
%let LPRHFRS32W       = 1.1;

%let LPRHFRS33        = J22;
%let LPRHFRS33_ICD8   = ;
%let LPRLHFRS33       = "Low resp infection";
%let LPRHFRS33W       = 0.7;

%let LPRHFRS34        = J69;
%let LPRHFRS34_ICD8   = ;
%let LPRLHFRS34       = "Pneumonitis";
%let LPRHFRS34W       = 1;

%let LPRHFRS35        = J96;
%let LPRHFRS35_ICD8   = ;
%let LPRLHFRS35       = "Resp failure";
%let LPRHFRS35W       = 1.5;

%let LPRHFRS36        = K26;
%let LPRHFRS36_ICD8   = ;
%let LPRLHFRS36       = "Duodenal ulcer";
%let LPRHFRS36W       = 1.6;

%let LPRHFRS37        = K52;
%let LPRHFRS37_ICD8   = ;
%let LPRLHFRS37       = "Gastroenteritis";
%let LPRHFRS37W       = 0.3;

%let LPRHFRS38        = K59;
%let LPRHFRS38_ICD8   = ;
%let LPRLHFRS38       = "Other intestinal dis";
%let LPRHFRS38W       = 1.8;

%let LPRHFRS39        = K92;
%let LPRHFRS39_ICD8   = ;
%let LPRLHFRS39       = "Other digestive diseases";
%let LPRHFRS39W       = 0.8;

%let LPRHFRS40        = L03;
%let LPRHFRS40_ICD8   = ;
%let LPRLHFRS40       = "Cellulitis";
%let LPRHFRS40W       = 2;

%let LPRHFRS41        = L08;
%let LPRHFRS41_ICD8   = ;
%let LPRLHFRS41       = "Other skin infections";
%let LPRHFRS41W       = 0.4;

%let LPRHFRS42        = L89;
%let LPRHFRS42_ICD8   = ;
%let LPRLHFRS42       = "Decubitus ulcer";
%let LPRHFRS42W       = 1.7;

%let LPRHFRS43        = L97;
%let LPRHFRS43_ICD8   = ;
%let LPRLHFRS43       = "Leg ulcer";
%let LPRHFRS43W       = 1.6;

%let LPRHFRS44        = M15;
%let LPRHFRS44_ICD8   = ;
%let LPRLHFRS44       = "Polyarthrosis";
%let LPRHFRS44W       = 0.4;

%let LPRHFRS45        = M19;
%let LPRHFRS45_ICD8   = ;
%let LPRLHFRS45       = "Other arthrosis";
%let LPRHFRS45W       = 1.5;

%let LPRHFRS46        = M25;
%let LPRHFRS46_ICD8   = ;
%let LPRLHFRS46       = "Other joint disorders";
%let LPRHFRS46W       = 2.3;

%let LPRHFRS47        = M41;
%let LPRHFRS47_ICD8   = ;
%let LPRLHFRS47       = "Scolosis";
%let LPRHFRS47W       = 0.9;

%let LPRHFRS48        = M48;
%let LPRHFRS48_ICD8   = ;
%let LPRLHFRS48       = "Spinal stenosis";
%let LPRHFRS48W       = 0.5;
%let LPRHFRS48C       = diagtype="B";

%let LPRHFRS49        = M79;
%let LPRHFRS49_ICD8   = ;
%let LPRLHFRS49       = "Soft tissue disorder";
%let LPRHFRS49W       = 1.1;

%let LPRHFRS50        = M80;
%let LPRHFRS50_ICD8   = ;
%let LPRLHFRS50       = "Osteoporosis with facture";
%let LPRHFRS50W       = 0.8;

%let LPRHFRS51        = M81;
%let LPRHFRS51_ICD8   = ;
%let LPRLHFRS51       = "Osteoporosis without facture";
%let LPRHFRS51W       = 1.4;

%let LPRHFRS52        = N17;
%let LPRHFRS52_ICD8   = ;
%let LPRLHFRS52       = "Acute renal failure";
%let LPRHFRS52W       = 1.8;

%let LPRHFRS53        = N18;
%let LPRHFRS53_ICD8   = ;
%let LPRLHFRS53       = "Chronic renal failure";
%let LPRHFRS53W       = 1.4;

%let LPRHFRS54        = N19;
%let LPRHFRS54_ICD8   = ;
%let LPRLHFRS54       = "Unspecific renal failure";
%let LPRHFRS54W       = 1.6;

%let LPRHFRS55        = N20;
%let LPRHFRS55_ICD8   = ;
%let LPRLHFRS55       = "Kidney ureter stones";
%let LPRHFRS55W       = 0.7;

%let LPRHFRS56        = N28;
%let LPRHFRS56_ICD8   = ;
%let LPRLHFRS56       = "Other kidney dis";
%let LPRHFRS56W       = 1.3;

%let LPRHFRS57        = N39;
%let LPRHFRS57_ICD8   = ;
%let LPRLHFRS57       = "Urinary disorders UTI UIC";
%let LPRHFRS57W       = 3.2;

%let LPRHFRS58        = R00;
%let LPRHFRS58_ICD8   = ;
%let LPRLHFRS58       = "Heart beat abnorm";
%let LPRHFRS58W       = 0.7;

%let LPRHFRS59        = R02;
%let LPRHFRS59_ICD8   = ;
%let LPRLHFRS59       = "Gangrene";
%let LPRHFRS59W       = 1;

%let LPRHFRS60        = R11;
%let LPRHFRS60_ICD8   = ;
%let LPRLHFRS60       = "Nausea vomiting";
%let LPRHFRS60W       = 0.3;

%let LPRHFRS61        = R13;
%let LPRHFRS61_ICD8   = ;
%let LPRLHFRS61       = "Dysphagia";
%let LPRHFRS61W       = 0.8;

%let LPRHFRS62        = R26;
%let LPRHFRS62_ICD8   = ;
%let LPRLHFRS62       = "Gait and mobility abnorm";
%let LPRHFRS62W       = 2.6;

%let LPRHFRS63        = R29;
%let LPRHFRS63_ICD8   = ;
%let LPRLHFRS63       = "Tendency to fall";
%let LPRHFRS63W       = 3.6;

%let LPRHFRS64        = R31;
%let LPRHFRS64_ICD8   = ;
%let LPRLHFRS64       = "Haematuria";
%let LPRHFRS64W       = 3;

%let LPRHFRS65        = R32;
%let LPRHFRS65_ICD8   = ;
%let LPRLHFRS65       = "Urinary incontinence";
%let LPRHFRS65W       = 1.2;

%let LPRHFRS66        = R33;
%let LPRHFRS66_ICD8   = ;
%let LPRLHFRS66       = "Urinary retention";
%let LPRHFRS66W       = 1.3;

%let LPRHFRS67        = R40;
%let LPRHFRS67_ICD8   = ;
%let LPRLHFRS67       = "Coma stupor";
%let LPRHFRS67W       = 2.5;

%let LPRHFRS68        = R41;
%let LPRHFRS68_ICD8   = ;
%let LPRLHFRS68       = "Cognitive function";
%let LPRHFRS68W       = 2.7;

%let LPRHFRS69        = R44;
%let LPRHFRS69_ICD8   = ;
%let LPRLHFRS69       = "General sensation perception";
%let LPRHFRS69W       = 1.6;

%let LPRHFRS70        = R45;
%let LPRHFRS70_ICD8   = ;
%let LPRLHFRS70       = "Emotional state";
%let LPRHFRS70W       = 1.2;

%let LPRHFRS71        = R47;
%let LPRHFRS71_ICD8   = ;
%let LPRLHFRS71       = "Speach disturbances";
%let LPRHFRS71W       = 1;

%let LPRHFRS72        = R50;
%let LPRHFRS72_ICD8   = ;
%let LPRLHFRS72       = "Fever";
%let LPRHFRS72W       = 0.1;

%let LPRHFRS73        = R54;
%let LPRHFRS73_ICD8   = ;
%let LPRLHFRS73       = "Senility";
%let LPRHFRS73W       = 2.2;

%let LPRHFRS74        = R55;
%let LPRHFRS74_ICD8   = ;
%let LPRLHFRS74       = "Sencope";
%let LPRHFRS74W       = 1.8;

%let LPRHFRS75        = R56;
%let LPRHFRS75_ICD8   = ;
%let LPRLHFRS75       = "Convulsions";
%let LPRHFRS75W       = 2.6;

%let LPRHFRS76        = R63;
%let LPRHFRS76_ICD8   = ;
%let LPRLHFRS76       = "Food and fluid intake";
%let LPRHFRS76W       = 0.9;

%let LPRHFRS77        = R69;
%let LPRHFRS77_ICD8   = ;
%let LPRLHFRS77       = "Unknown causes of morbidity";
%let LPRHFRS77W       = 1.3;

%let LPRHFRS78        = R79;
%let LPRHFRS78_ICD8   = ;
%let LPRLHFRS78       = "Abnormal blood chemistry";
%let LPRHFRS78W       = 0.6;

%let LPRHFRS79        = R94;
%let LPRHFRS79_ICD8   = ;
%let LPRLHFRS79       = "Abnormal function";
%let LPRHFRS79W       = 1.4;

%let LPRHFRS80        = S00;
%let LPRHFRS80_ICD8   = ;
%let LPRLHFRS80       = "Superficial injury of head";
%let LPRHFRS80W       = 3.2;

%let LPRHFRS81        = S01;
%let LPRHFRS81_ICD8   = ;
%let LPRLHFRS81       = "Open head wound";
%let LPRHFRS81W       = 1.1;

%let LPRHFRS82        = S06;
%let LPRHFRS82_ICD8   = ;
%let LPRLHFRS82       = "Intracranial injury";
%let LPRHFRS82W       = 2.4;

%let LPRHFRS83        = S09;
%let LPRHFRS83_ICD8   = ;
%let LPRLHFRS83       = "Unspecified head injury";
%let LPRHFRS83W       = 1.2;

%let LPRHFRS84        = S22;
%let LPRHFRS84_ICD8   = ;
%let LPRLHFRS84       = "Rib fracture";
%let LPRHFRS84W       = 1.8;

%let LPRHFRS85        = S32;
%let LPRHFRS85_ICD8   = ;
%let LPRLHFRS85       = "Spine and pelvis fracture";
%let LPRHFRS85W       = 1.4;

%let LPRHFRS86        = S42;
%let LPRHFRS86_ICD8   = ;
%let LPRLHFRS86       = "Shoulder fracture";
%let LPRHFRS86W       = 2.3;

%let LPRHFRS87        = S51;
%let LPRHFRS87_ICD8   = ;
%let LPRLHFRS87       = "Open forarm wound";
%let LPRHFRS87W       = 0.5;

%let LPRHFRS88        = S72;
%let LPRHFRS88_ICD8   = ;
%let LPRLHFRS88       = "Femur fracture";
%let LPRHFRS88W       = 1.4;

%let LPRHFRS89        = S80;
%let LPRHFRS89_ICD8   = ;
%let LPRLHFRS89       = "Lower leg superfecial injury";
%let LPRHFRS89W       = 2;

%let LPRHFRS90        = T83;
%let LPRHFRS90_ICD8   = ;
%let LPRLHFRS90       = "Complica urogenital implants";
%let LPRHFRS90W       = 2.4;

%let LPRHFRS91        = T89;
%let LPRHFRS91_ICD8   = ;
%let LPRLHFRS91       = "Nosocomial infect";
%let LPRHFRS91W       = 1.2;

%let LPRHFRS92        = Z22;
%let LPRHFRS92_ICD8   = ;
%let LPRLHFRS92       = "Carrier infect dis";
%let LPRHFRS92W       = 1.7;

%let LPRHFRS93        = Z50;
%let LPRHFRS93_ICD8   = ;
%let LPRLHFRS93       = "Rehabilitation";
%let LPRHFRS93W       = 2.1;

%let LPRHFRS94        = Z60;
%let LPRHFRS94_ICD8   = ;
%let LPRLHFRS94       = "Social problems";
%let LPRHFRS94W       = 1.8;

%let LPRHFRS95        = Z73;
%let LPRHFRS95_ICD8   = ;
%let LPRLHFRS95       = "Life management difficulty";
%let LPRHFRS95W       = 0.6;

%let LPRHFRS96        = Z74;
%let LPRHFRS96_ICD8   = ;
%let LPRLHFRS96       = "Care provider dependency";
%let LPRHFRS96W       = 1.1;

%let LPRHFRS97        = Z75;
%let LPRHFRS97_ICD8   = ;
%let LPRLHFRS97       = "Medical facilities problems";
%let LPRHFRS97W       = 2;

%let LPRHFRS98        = Z87;
%let LPRHFRS98_ICD8   = ;
%let LPRLHFRS98       = "History of other disease";
%let LPRHFRS98W       = 1.5;

%let LPRHFRS99        = Z91;
%let LPRHFRS99_ICD8   = ;
%let LPRLHFRS99       = "History of risk factor";
%let LPRHFRS99W       = 0.5;

%let LPRHFRS100        = Z93;
%let LPRHFRS100_ICD8   = ;
%let LPRLHFRS100       = "Artificial opening status";
%let LPRHFRS100W       = 1;

%let LPRHFRS101        = Z99;
%let LPRHFRS101_ICD8   = ;
%let LPRLHFRS101       = "Enabling devices dependency";
%let LPRHFRS101W       = 0.8;

%let LPRHFRSN         = 101;
