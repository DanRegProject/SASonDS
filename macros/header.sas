/* header macro, used for logging where, when and why */
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
