/* Restricted Cubic Spline Macro  */;
/* Frank Harrell                  */

%macro
	RCSPLINE(x,knot1,knot2,knot3,knot4,knot5,knot6,knot7,knot8,knot9,knot10,norm=2);
	%local j k tk tkl t k1 k2;
	%* get no of knots, last knot, next to last knot;
	%do k=1 %to 10;
	%if %quote(&&knot&k) =  %then %goto nomorek;
	%end;
	%let k=11;
	%nomorek: %let k=%eval(&k-1);
	%let k1=%eval(&k-1);
	%let k2=%eval(&k-2);
	%if &k lt 3 %then %put ERROR: less than 3 knots given. No spline variables created.;
	%else %do;
	%let tk=&&knot&k;
	%let tk1=&&knot&k1;
	drop _kd_;
	_kd_= %if &norm=0 %then 1;
		%else %if &norm=1 %then &tk - &tk1;
		%else (&tk - &knot1)**.66666666666; ;
		%do j=1 %to &k2;
		%let t=&&knot&j;
		&x&j=max((&x-&t)/_kd_,0)**3+((&tk1-&t)*max((&x-&tk)/_kd_,0)**3
		-(&tk-&t)*max((&x-&tk1)/_kd_,0)**3)/(&tk-&tk1)%STR(;);
		%end;
		%end;
    %mend;

%macro myRCSPLINE(indata,outdata,var,nknots,by=);
    %let min=%sysevalf(100/(&nknots+1));
    %let max=%sysevalf(101-&min);
    proc univariate data=&indata noprint;
        %if &by ne %then by &by;;
        var &var ;
        output out=_sp1_ pctlpre=P pctlname=%do i=1 %to &nknots; _&i  %end; pctlpts=&min to &max by &min;
run;
proc print data=_sp1_;
    title "spline knots for &var";
run;
data &outdata;
    %if &by = %then %do;
        retain  %do i=1 %to &nknots; P_&i %end;;
        set &indata;
        if _N_=1 then merge _sp1_;
        %end;
    %if &by ne %then %do;
        merge &indata _sp1_;
    %if &by ne %then by &by;;
    %end;
/*    %RCSPLINE(age,63.1, 66.6, 73.4, 77.9, 82.9);*/;
    drop _kd1_ _kd2_ _kd3_ _kd4_ %do i=1 %to &nknots; P_&i %end; ;
    _kd1_ = (P_&nknots - P_1)**(2/3);
    if _kd1_>0 then do;
        _kd2_ = max((&var-P_&nknots)/_kd1_,0)**3;
        _kd3_ = max((&var-P_%eval(&nknots-1))/_kd1_,0)**3;
        _kd4_ = P_&nknots-P_%eval(&nknots-1);

        %do i =1 %to %eval(&nknots-2);
            &var&i =max((&var-P_&i)/_kd1_,0)**3+((P_%eval(&nknots-1)-P_&i)*_kd2_
                -(P_&nknots-P_&i)* _kd3_)/_kd4_;
            %end;
        end;
    else do;
        %do i =1 %to %eval(&nknots-2); &var&i = 0; %end;
        end;
run;
/*
    MPRINT(RCSPLINE):   drop _kd_;
    MPRINT(RCSPLINE):   _kd_= (82.9 - 63.1)**.66666666666 ;
    MPRINT(RCSPLINE):    age1=max((age-63.1)/_kd_,0)**3+((77.9-63.1)*max((age-82.9)/_kd_,0)**3
        -(82.9-63.1)*max((age-77.9)/_kd_,0)**3)/(82.9-77.9);
    MPRINT(RCSPLINE):  ;
    MPRINT(RCSPLINE):   age2=max((age-66.6)/_kd_,0)**3+((77.9-66.6)*max((age-82.9)/_kd_,0)**3
        -(82.9-66.6)*max((age-77.9)/_kd_,0)**3)/(82.9-77.9);
    MPRINT(RCSPLINE):  ;
    MPRINT(RCSPLINE):   age3=max((age-73.4)/_kd_,0)**3+((77.9-73.4)*max((age-82.9)/_kd_,0)**3
        -(82.9-73.4)*max((age-77.9)/_kd_,0)**3)/(82.9-77.9);
    */
%mend;
