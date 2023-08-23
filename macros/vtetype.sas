/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: vtetype.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
* 1=PE,2=DVT,3=pregnancy-related PE, 4=pregnancy-releated DVT;
%MACRO vtetype(indata,outdata,varname);
	proc sql undo_policy=none;
	create table &outdata as
	select *,
	case
	when (&varname like "I26%"
    	          or &varname like "450%"
   	 ) then 1
	when (&varname like "I801%"
	      or &varname like "I802%"
	      or &varname like "I803%"
	      or &varname like "I808%"
	      or &varname like "I809%"
	      or &varname like "I828%"
	      or &varname like "I829%"
	      or &varname like "I81%"
	      or &varname like "I822%"
	      or &varname like "I823%"
	      or &varname like "I636%"
	      or &varname like "I676%"
	      or &varname like "H348E%"
	      or &varname like "H348F%"
              or &varname like "45100%"
              or &varname like "45108%"
    	      or &varname like "45109%"
	      or &varname like "45190%"
	      or &varname like "45192%"
	      or &varname like "45199%"
	      or &varname like "45299%"
    	      or &varname like "45302%"
	      or &varname like "45304%"
	      or &varname like "321%"
    ) then 2
	when (&varname like "O882%"
    	      or &varname like "67309%"
    	      or &varname like "67319%"
    	      or &varname like "67399%"
     ) then 3
	when (&varname like "O223%"
             or &varname like "O229%"
	      or &varname like "O871%"
              or &varname like "O879%"
	      or &varname like "O225%"
	      or &varname like "K751%"
	      or &varname like "O873%"
    	      or &varname like "67101%"
	      or &varname like "67102%"
	      or &varname like "67103%"
    	      or &varname like "67108%"
	      or &varname like "67109%"
    ) then 4
	end
	as vteType label="Type of VTE"
	from &indata;
	quit;
%MEND;
