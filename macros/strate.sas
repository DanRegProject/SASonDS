/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: strate.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
%macro strate(indata,endpoints,per=1000);
/* This require data prepared with %genEndpoints and %TimeAtRisk;
%strate(minedata,death AMI ISTROKE);
*/
    %local dstmp1 dstmp2;
    %let dstmp1 =%NewDatasetName(tmp);
    data &dstmp1; set &indata;
        %if &where ne %then &where;;
        length Endpoint $15.;
        %let elstcnt = %sysfunc(countw(&endpoints));
        %DO I=1 %to &elstcnt;
            %let eval =%sysfunc(compress( %qscan(&endpoints,&i)));
            TAR =  &eval.TAR;
            TARs = &eval.TAR/&per*100;
            Endpoint="&eval";
            Status= &eval.Status;
            output;
            %end;
    run;
    proc tabulate data=&dstmp1;
        class endpoint;
        var TAR TARs Status;
        table endpoint, TAR="Time at Risk"*sum=""
            Status="Events"*sum=""*f=best10.0
            Status="Event Rate per &per"*pctsum<TARs>="";
    run;
    %cleanup(&dstmp1);
    %mend;
