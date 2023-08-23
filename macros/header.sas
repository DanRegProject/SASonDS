/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: header.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
%macro header(path=, ajour=, dataset=, initials=, reason=);
 %put ;
  %put *********************************** HEADER **************************************;
  %put Dataset           : &dataset;
  %put Ajour             : &ajour;
  %put Path              : &path;
  %put Today             : %qsysfunc(datetime(), datetime20.3);
  %put Updated by        : &initials;
  %put Reason for update : &reason;
  %put *********************************************************************************;
%mend;
