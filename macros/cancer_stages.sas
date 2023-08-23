/* SVN header
$Date:  $
$Revision:  $
$Author: $
$Id:  $
*/
/* input dataset has been reduced to information up until idate, use cstageALL (tildiag=TRUE pattype= "+") as input table  */
%macro cancer_stages(input, output);
data temp;
  set &input;
  by pnr;
  where &ProjectDate between rec_in and rec_out;
  retain t n m;
  format t n m $4.;
  if first.pnr then do;
    t = .;
	n = .;
	m = .;
  end;
    if diagnose =: "AZCD10" then t=0;
    if (diagnose =: "AZCD13") or (diagnose =: "AZCD11") or (diagnose =: "AZCD12") then t=1;
    if diagnose =: "AZCD14" then t=2;
    if diagnose =: "AZCD15" then t=3;
    if diagnose =: "AZCD16" then t=4;
    if diagnose =: "AZCD19" then t=88; /* x */
    if diagnose =: "AZCD30" then n=0;
    if diagnose =: "AZCD31" then n=1;
    if diagnose =: "AZCD32" then n=2;
    if diagnose =: "AZCD39" then n=88; /* x */
    if diagnose =: "AZCD40" then m=0;
    if diagnose =: "AZCD41" then m=1;
    if diagnose =: "AZCD49" then m=88; /* x */
  if last.pnr then output;
  keep pnr idate2 t n m ;
%runquit;
data &output;
  set temp;
  by pnr ;
  label stage = "local=1, regional=2, spred=3, unknown = 4";
  if m ne . and n ne . and t ne . ; /* keep only if all information is present */
  if m=1 then stage = 3;
  else
  if n=1 or n=2 or n=3 then stage = 2;
  else
  if t>=2 and n=88 or t>2 then stage = 4;
  else stage=1;
  keep pnr stage;
 %runquit;
%mend;
