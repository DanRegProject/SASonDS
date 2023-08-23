/* Ref:
%macro test;
%mend;
%test;

    fls 4/12/2012
    */
%macro myPSMatching(datatreatment=, datacontrol=, pscore=, method=, numberofcontrols=, caliber=, replacement=FALSE);
    /* create copies of the treated units if N>1 */;
	%local Treat0 Treat1 Contr0 Contr1 comb0 comb1 ndim i matched0 rc;
        %let Treat0=%NewDatasetName(Ttmp);
    data &treat0;
        set &datatreatment;
    run;
    %let Contr0=%NewDatasetName(Ctmp);
    data &Contr0;
        set &datacontrol;
    run;

    %let ndim=%sysfunc(countw(&pscore));
        %if &ndim>1 %then %do;
            %let comb0=%NewDatasetName(Ttmp);
        data &comb0;
            set &treat0 &contr0;
            keep pnr &pscore;
        run;
        %let comb2=%NewDatasetName(Ttmp);
        proc princomp data=&comb0 std out=&comb2 noprint;
            var &pscore;
        run;

        proc sort data=&treat0;
            by pnr;
        run;
        proc sort data=&contr0;
            by pnr;
        run;
        proc sort data=&comb2;
            by pnr;
        run;
        data &treat0;
            merge &treat0(in=a) &comb2;
            by pnr;
            if a;
        run;
        data &Contr0;
            merge &contr0(in=a) &comb2;
            by pnr;
            if a;
        run;
        %end;
    data &Treat0(drop=i);
        set &treat0 end=end;
        %if &ndim=1 %then %do;
            pscoreT1=&pscore;
            %end;
        %if &ndim>1 %then %do;
            %do i=1 %to &ndim;
            pscoreT&i=prin&i;
            %end;
        %end;
        idT=pnr;
        _id=1;
        do i=1 to &numberofcontrols;
            RandomNumber=ranuni(12345);
            output;
            end;

    run;
    data _null_; set &treat0 end=end;
        if end then call symput("Ntreat",_N_);
    run;
    %put &Ntreat;

    data &Contr0;
        set &contr0 end=end;
        %if &ndim=1 %then %do;
            pscoreC1=&pscore;
            %end;
        %if &ndim>1 %then %do;
            %do i=1 %to &ndim;
            pscoreC&i=prin&i;
            %end;
        %end;
        RandomNumber=ranuni(56789);
        idC=pnr;
        _id=1;
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
    %let Matched0=%NewDatasetName(mat);
    %do rc=1 %to &Ntreat;
        %if rc>2 %then %do; options nomprint; %end;
        data &Matched0(keep=IdSelectedControl MatchedToTreatID BestDistance
  /*          %do i=1 %to &ndim;
            scoreSelectedControl&i scoreMatchedTreat&i
                %end;
    */        );

*    length idSelectedContol $12.;
            merge  &treat1(firstobs=&rc obs=&rc) &contr1 end=lastobs;
            by _id;
            if _n_=0 then do;
                idSelectedControl=idT;
                end;

            retain idSelectedControl;
            retain BestDistance 99999
                %do i=1 %to &ndim;
            scoreSelectedControl&i 0
                %end;
                ;
            /* euclidian distance metric on the principal component scores
                this gives the mahaloanobis distance */;
                dist=sqrt(
                %do i=1 %to &ndim;
                    (pscoreT&i - pscoreC&i )**2
                    %if &ndim ne 1 and &i ne &ndim %then +;
                 %end;
              );

              MatchedToTreatID=idT;
              %do i=1 %to &ndim;
                  scoreMatchedTreat&i = pscoreT&i;
                  %end;
            /* Caliber */;
            %if %upcase(&method)=CALIBER %then %do;
                if dist<=&caliber then do;
                    if dist<BestDistance then do;
                        BestDistance=dist;
                        IdSelectedControl=idC;
                        %do i=1 %to &ndim;
                            scoreSelectedControl&i = pscoreC&i;
                            %end;
                        end;
                    end;
                %end;
        /* Nearest Neighbour */;
        %if %upcase(&method)=NN %then %do;
            if dist<BestDistance then do;
                BestDistance=dist;
                IdSelectedControl=idC;
                %do i=1 %to &ndim;
                    scoreSelectedControl&i = pscoreC&i;
                    %end;
                end;
            %end;
        %if %upcase(&method)=NN or %upcase(&method)=CALIBER %then %do;
            if lastobs then output;
            %end;
        /* Radius */;
        %if %upcase(&method)=RADIUS %then %do;
            if dist<=&caliber then do;
                IdSelectedControl=idC;
                MatchedToTreatID=idT;
                %do i=1 %to &ndim;
                    scoreSelectedControl&i = pscoreC&i;
                    %end;
                if lastobs=0 then output;
                lastobs=1;
                end;
            %end;
        run;
        %if %upcase(&replacement)=FALSE %then %do;
            proc sql;
                delete from &contr1 where idC in (select IdSelectedControl from &matched0);
                quit;
        %end;

        %if &rc=1 %then %do;
            data matched;
                set &matched0;
            run;
            %end;
        %if &rc gt 1 %then %do;
            data matched;
                set matched &matched0;
            run;
            %end;
        %end;


    run;
/* delete temporary tables */;
%cleanup(&Treat0);
%cleanup(&Treat1);
%cleanup(&Contr0);
%cleanup(&Contr1);
%cleanup(&matched0);
%mend;
/*
data treatment;
input pscore pscore2 pnr;
datalines ;
0.1 0.03 1
0.2 0.25 2
;
data control;
input pscore pscore2  pnr;
datalines ;
0.07 0.23 3
0.08 0.021 4
0.11 0.23 5
0.45 0.12 6
0.47 0.21 7
;

%myPSMatching(datatreatment=treatment,datacontrol=control,pscore=pscore pscore2,method=NN, numberofcontrols=2, caliber=, replacement=FALSE);
proc print data=matched; run;
*/
