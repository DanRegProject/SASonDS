/* SVN header
$Date: 2017-07-03 15:11:08 +0200 (ma, 03 jul 2017) $
$Revision: 11 $
$Author: FCNI6683 $
$Id: ATCriskscores.sas 11 2017-07-03 13:11:08Z FCNI6683 $
*/
/* special cases */
/* chads2Vasc */
%let RISKLChads2Vasc = "CHA2DS2-VASc";

/* Hypertension for risk calculation */
%global RISKhyp RISKLhyp RISKhypN RISKhypW;
%let RISKhyp    = alfa nonloop vaso beta calcium renin;
%let RISKLhyp   = "Hypertension: (Alfa + Nonloop + Vaso + Beta + Calcium + Renin)>1";
%let RISKhypN   = %sysfunc(countw(&RISKhyp)); /* number of groups */
%let RISKhypW   = 1; /* weight of each group */

/* combination drugs - weight 2 */
%global RISKhypComp1 RISKLHypComp1 RISKhypComp2 RISKLHypComp2 RISKhypComp3 RISKLHypComp3 RISKhypComp4 RISKLHypComp4 RISKhypComp5 RISKLHypComp5 RISKhypComp6 RISKLHypComp6;
%let RISKhypComp1    = C09BB04;
%let RISKLhypComp1   = "Combination of ACE inhibitors and calcium antagonists";
%let RISKhypComp2    = C09DA;
%let RISKLhypComp2   = "Combination of Angiotensin II antagonists and thiazide";
%let RISKhypComp3    = C09DB;
%let RISKLhypComp3   = "Combination of Angiotensin II receptor antagonists and calcium antagonists";
%let RISKhypComp4    = C09DX01;
%let RISKLhypComp4   = "Combination of Angiotensin II receptor antagonists, calcium antagonists and hydrochlorthiazid";
%let RISKhypComp5    = C09DX04;
%let RISKLhypComp5   = "Combination of Angiotensin II receptor antagonists and neprilysin inhibitor";
%let RISKhypComp6    = C07B;
%let RISKLhypComp6   = "Combination of beta blocker and thiazid";

%global RISKhypComp RISKhypCompN RISKLhypComp RISKhypCompW;
%let RISKhypComp     = hypComp1 hypComp2 hypComp3 hypComp4 hypComp5 hypComp6;
%let RISKhypCompN    = %sysfunc(countw(&RISKhypComp)); /* number of combination drugs */
%let RISKLhypComp    = "hypertension combination drugs";
%let RISKhypCompW    = 2; /* each combination drug counts double */

/* special cases */
%global ATCchads2 ATCLchads2 ATCha2dsvasc ATCLcha2dsvasc ATChasbled ATCLhasbled ATCLhasbled;
%let ATCchads2      = hfatc alfa nonloop vaso beta calcium renin diabatc;
%let ATCLchads2     = "CHADS2";
%let ATCha2dsvasc   = hfatc alfa nonloop vaso beta calcium renin diabatc;
%let ATCLcha2dsvasc = "CHA2DS2VASc";
%let ATChasbled     = alfa nonloop vaso beta calcium renin aspirin clopi nsaid;
%let ATCLhasbled    = "HAS-BLED";
