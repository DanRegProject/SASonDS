/* Ref: SAS Global forum 2007 paper 185-2007
    Local and global optimal proensity score matching
    Marcelo Coca-Perraillon

    fls: corrected error in source code, input dataset not correct specified
    fls: added pscore macro argument;

FLS : Den her macro fejler pga en BUG i sas 64bit som først rettes  i version SAS 9.3 , fuck!
    fls 4/12/2012
    */
%macro PSMatching(datatreatment=, datacontrol=, pscore=, method=, numberofcontrols=, caliber=, replacement=);
    /* create copies of the treated units if N>1 */;
	%local Treat0 Treat1 Contr0 Contr1;
        %let Treat0=%NewDatasetName(Ttmp);
    data &Treat0(drop=i);
        set &datatreatment;
        idT=pnr;
        pscoreT=&pscore;
        do i=1 to &numberofcontrols;
            RandomNumber=ranuni(12345);
            output;
            end;
    run;
    %let Contr0=%NewDatasetName(Ctmp);
    data &Contr0;
        set &datacontrol;
        idC=pnr;
        pscoreC=&pscore;
        RandomNumber=ranuni(56789);
    run;

    /* Randomly sort both datasets */;
    %let Treat1=%NewDatasetName(Ttmp);
    proc sort data=&Treat0 out=&Treat1(drop=RandomNumber);
        by RandomNumber;
    run;

    /* Randomly sort both datasets */;
        %let Contr1=%NewDatasetName(Ctmp);
    proc sort data=&Contr0 out=&Contr1(drop=RandomNumber);
        by RandomNumber;
    run;

    data Matched(keep=IdSelectedControl MatchedToTreatID);
        length pscoreC 8;
        length idC 8;
        /* load control dataset into the hash object */;
        if _N_=1 then do;
            declare hash h(dataset: "&Contr1", ordered: 'no');
            declare hiter iter('h');
            h.defineKey('idC');
            h.defineData('pscoreC', 'idC');
            h.defineDone();
            call missing(idC, pscoreC);
            end;
        /* Open the treatment dataset */;
        set &Treat1;
        %if %upcase(&method) ne RADIUS %then %do;
            retain BestDistance 99;
            %end;
        /* iterate over the hash */;
        rc=iter.first();
        if(rc=0) then BestDistance=99;
        do while (rc=0);
            /* Caliber */;
            %if %upcase(&method)=CALIBER %then %do;
                if (pscoreT-&caliber)<=pscoreC<=(pscoreT+&caliber) then do;
                    ScoreDistance=abs(pscoreT-pscoreC);
                    if ScoreDistance<BestDistance then do;
                        BestDistance=ScoreDistance;
                        IdSelectedControl=idC;
                        MatchedToTreatID=idT;
                        end;
                    end;
                %end;
        /* Nearest Neighbour */;
        %if %upcase(&method)=NN %then %do;
            ScoreDistance=abs(pscoreT-pscoreC);
            if ScoreDistance<BestDistance then do;
                BestDistance=ScoreDistance;
                IdSelectedControl=idC;
                MatchedToTreatID=idT;
                end;
            %end;
        %if %upcase(&method)=NN or %upcase(&method)=CALIBER %then %do;
            rc=iter.next();
            /* output the best control and remove it */;
            if (rc ne 0) and BestDistance ne 99 then do;
                output;
                %if %upcase(&replacement)=NO %then %do;
                    rcl = h.remove(key: IdSelectedControl);
                    %end;
                end;
            %end;
        /* Radius */;
        %if %upcase(&method)=RADIUS %then %do;
            if (pscoreT-&caliber)<=pscoreC<=(pscoreT+&caliber) then do;
                IdSelectedControl=idC;
                MatchedToTreatID=idT;
                output;
                end;
            rc=iter.next();
            %end;
        end;
run;
/* delete temporary tables */;
%cleanup(&Treat0);
%cleanup(&Treat1);
%cleanup(&Contr0);
%cleanup(&Contr1);
%mend;
data treatment;
input pscore pnr;
datalines ;
0.1 1
0.2 2
;
data control;
input pscore pnr;
datalines ;
0.07 3
0.08 4
0.11 5
0.45 6
0.47 7
;

proc discrim data=treatment test=control method=npar k=1 testout=test;
    var pscore;
run;
proc print data=test;
run ;
%PSMatching(datatreatment=treatment,datacontrol=control,pscore=pscore,method=NN, numberofcontrols=2, caliber=, replacement=NO);
