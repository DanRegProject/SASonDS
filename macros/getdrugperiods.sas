/* SVN header
$Date: 2019-11-05 13:59:52 +0100 (ti, 05 nov 2019) $
$Revision: 208 $
$Author: wnm6683 $
$Id: getDrugPeriods.sas 208 2019-11-05 12:59:52Z wnm6683 $
*/
%macro getDrugPeriods(drugdata,drug,basedata,basedate,outdata,reduce=TRUE);
    %getMedPeriods(&drugdata,&drug,&basedata,&basedate,&outdata,reduce=&reduce);
    %mend;
%macro getMedPeriods(drugdata,drug,basedata,basedate,outdata,reduce=TRUE);
    %local dstmp1;
    data &outdata;
        merge &basedata(in=A) &drugdata(in=B);
        by pnr;
        if A AND B;
        &drug.before&basedate=(&basedate>&drug.start AND &basedate>&drug.end);
        &drug.during&basedate=(&basedate>&drug.start AND &basedate<=&drug.end);
        &drug.after&basedate=(&basedate<=&drug.start);
        label &drug.before&basedate= "&drug treatment period before &basedate";
        label &drug.during&basedate= "&drug treatment period before and at &basedate";
        label &drug.after&basedate=  "&drug treatment period after or starting at &basedate";
        period=&drug.before&basedate+2*&drug.during&basedate+3*&drug.after&basedate;
    run;
    proc sort data=&outdata;
        by pnr period &drug.start;
    run;
    %let dstmp1 =%NewDatasetName(tmp);
    data &outdata(drop= daysbefore daysduring daysafter
        &drug.before&basedate &drug.during&basedate &drug.after&basedate)
        &dstmp1(keep=pnr daysbefore daysduring daysafter);
        set &outdata;
        retain daysbefore daysduring daysafter;
        by pnr period;
        if first.pnr then do;
            daysbefore=0; daysduring=0; daysafter=0;
            end;
        if &drug.before&basedate then daysbefore+(&drug.end-&drug.start);
        if &drug.during&basedate then daysduring+(&drug.end-&drug.start);
        if &drug.after&basedate then daysafter+(&drug.end-&drug.start);
        if period=1 and last.period then output &outdata;
        if period=2 then output &outdata;
        if period=3 then output &outdata;
        if last.pnr then output &dstmp1;
    run;
    %if &reduce=TRUE %then %do;
        data &outdata;
            merge &outdata(where=(period=1) rename=(&drug.start=&drug.startbefore &drug.end=&drug.endbefore))
                &outdata(where=(period=2) rename=(&drug.start=&drug.startduring &drug.end=&drug.endduring))
                &outdata(where=(period=3) rename=(&drug.start=&drug.startafter &drug.end=&drug.endafter))
                ;
            by pnr;
            if first.pnr;
            drop period  &drug nvisits;
        run;
        %end;
    data  &outdata;
        merge &outdata &dstmp1(rename=(daysbefore=&drug.before&basedate
            daysduring=&drug.during&basedate
            daysafter=&drug.after&basedate));
        by pnr;
        %if &reduce=FALSE %then drop period;;
    run;
    %cleanup(&dstmp1);
    %mend;
