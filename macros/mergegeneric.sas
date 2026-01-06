%MACRO merge(basedata=,inlib=work,outlib=work,IndexDate=,type=,datevar=,sets=,invar=,outvar=,subset=,postfix=);
  %PUT start merge: %qsysfunc(datetime(),datetime20.3);
  %local I nsets nvar outdat error;
  %LET error=0;
  %IF &basedata= or &inlib= or &outlib= or &type= or &datevar= or &sets= or &invar= or &outvar= %THEN %DO;
      %PUT merge ERROR: Required arguments not specified, basedata, inlib, outlib, type, datevar, sets, invar, outvar;
     %LET error=1;
      %END;
  %IF %sysfunc(countw(&type))>1 %THEN %DO;
      %PUT merge ERROR: Only one type allowed;
      %LET error=1;
  %END;
  %IF %sysfunc(find("LPR LMDB OPR UBE PATO LAB CAR",&type,i))=0 %THEN %DO;
      %PUT merge ERROR: type (&type) not one of : LPR LMDB OPR UBE PATO LAB CAR;
      %LET error=1;
  %END;
  %IF %sysfunc(countw(&invar))-%sysfunc(countw(&outvar)) ne 0  %THEN %DO;
      %PUT merge ERROR: number of variables for input and output not equal.;
      %LET error=1;
  %END;
  %IF &error=0 %THEN %DO;
          %LET outdat=%NewDatasetName(outdattmp); /* fls 26-06-15 tilføjet temporært datasætnavn så data i work ikke overskrives */;
          %LET nsets=%sysfunc(countw(&sets));
          %LET nvar=%sysfunc(countw(&invar));
          %IF &nsets gt 2 %THEN %DO; /* reduce list */
              %nonrep(mvar=sets, outvar=newsets);
              %LET sets = &newsets;
              %LET nsets = %sysfunc(countw(&newsets));
          %END;

         %DO i=1 %TO &nsets;
             %LET var=%sysfunc(compress(%qscan(&sets,&i)));
             %IF %sysfunc(exist(&inlib..&type&var.ALL))=0 %THEN
                 %PUT merge WARNING: &inlib..&type&var.ALL data set not available.;
             %else %DO;
            proc sql;
	    create table &outdat as
                select a.*, b.&indexDate
                from &inlib..&type&var.ALL a, &basedata b
                where a.pnr=b.pnr
                order by b.pnr, b.&indexdate, a.&datevar;
            %runquit;
            data &outdat;
                set &outdat;
                %IF %isBlank(%superq(subset))=0 %THEN where &subset;;
                keep pnr &indexdate &invar;
                rename
                    %DO v=1 %TO &nvar;
                    %sysfunc(compress(%qscan(&invar,&v))) = %sysfunc(compress(%qscan(&outvar,&v)))
                    %END;
                  ;
            %RunQuit;

            %reduce(&outdat, &outlib..&type&var&postfix&Indexdate, &type, &var&postfix, &IndexDate, &outvar, &datevar);
  %END;
%END;
      proc sort data=&basedata;
        by pnr &IndexDate;
      run;
      data &basedata;
        merge &basedata(in=A)
        %DO i=1 %TO &nsets;
          %LET var=%sysfunc(compress(%qscan(&sets,&i)));
   	     &outlib..&type&var&postfix&Indexdate
          %END;
        ;
   by pnr &IndexDate;
   if A;
   %RunQuit;
   %cleanup(&outdat);
%END;
        %mend;

%MACRO reduce(indata,outdata,type,outcome,IndexDate,varlist,datevar);
  %local i temp var varnar varcar nrep format;
  %PUT start reduce: %qsysfunc(datetime(), datetime20.3);
  %LET temp=%NewDatasetName(temp);
  proc sql;
    create table &temp as
      select a.*, %IF &IndexDate ne %THEN (a.&IndexDate<a.&datevar); %else 1;  as afterbase_local
      from &indata a
      order by a.pnr, %IF &IndexDate ne %THEN  &IndexDate,; a.&datevar;
    %sqlquit;

    %LET nvar=%sysfunc(countw(&varlist));

    %DO I=1 %TO &nvar;
        %LET var=%sysfunc(compress(%qscan(&varlist,&i)));
        %IF %varexist(&temp,&var,type)=C %THEN %LET varcar = &varcar &var;
                                         %else %LET varnar = &varnar &var;
        %END;
    %IF &indexDate ne %THEN %LET nrep=3; %else nrep=1;
    %LET ncvar=%sysfunc(countw(&varcar));
    %LET nnvar=%sysfunc(countw(&varnar));
    %LET nncvar=&nrep*&ncvar;
    %LET nnnvar=&nrep*&nnvar;
    data &outdata ;
      array varc{&ncvar,&nrep}  $
         %DO i=1 %TO &ncvar;
             %LET var=%sysfunc(compress(%qscan(&varcar,&i)));
		%IF &IndexDate ne %THEN &outcome.FI&var.Be&IndexDate   ;
		%IF &IndexDate ne %THEN &outcome.LA&var.Be&IndexDate   ;
                &outcome.&var.AF&IndexDate
        %END;
      (&nncvar*""); /* automatisk retain ved initialisering */
      array varn{&nnvar,&nrep}
         %DO i=1 %TO &nnvar;
             %LET var=%sysfunc(compress(%qscan(&varnar,&i)));
	     %IF &IndexDate ne %THEN &outcome.Fi&var.Be&IndexDate    ;
	     %IF &IndexDate ne %THEN &outcome.LA&var.Be&IndexDate    ;
             &outcome.&var.AF&IndexDate
         %END;
	(&nnnvar*.);
        set &temp end=end;
        array invarc{&ncvar} $ &varcar;
        array invarn{&nnvar}   &varnar;
        by pnr %IF &IndexDate ne %THEN &IndexDate; afterbase_local;
   /* initialisering pr person eller dato indenfor person */
        if %IF &IndexDate ne %THEN first.&IndexDate;
           %else first.pnr;
        then do;
            do i=1 to dim1(varc);
                do j=1 to dim2(varc);
                    varc{i,j}="";
                end;
	    end;
	    do i=1 to dim1(varn);
                do j=1 to dim2(varn);
			varn{i,j}=.;
		end;
   	    end;
    end;
    %IF &IndexDate ne %THEN %DO;
      if first.afterbase_local and afterbase_local=0 then do;
	    do j=1 to dim1(varc);
                varc{j,1}=invarc{j};
		end;
        do j=1 to dim1(varn);
            varn{j,1}=invarn{j};
		end;
      end;
      if last.afterbase_local and afterbase_local=0 then do;
          do j=1 to dim1(varc);
              varc{j,2}=invarc{j};
          end;
          do j=1 to dim1(varn);
		varn{j,2}=invarn{j};
  	  end;
     end;
    %END;
    if first.afterbase_local and afterbase_local=1 then do;
        do j=1 to dim1(varc);
            varc{j,&nrep}=invarc{j};
        end;
        do j=1 to dim1(varn);
            varn{j,&nrep}=invarn{j};
	end;
      end;
    if %IF &IndexDate ne %THEN last.&IndexDate; %IF &IndexDate = %THEN last.pnr; then output;
    keep pnr &indexdate
        %DO i=1 %TO &ncvar;
             %LET var=%sysfunc(compress(%qscan(&varcar,&i)));
		%IF &IndexDate ne %THEN &outcome.FI&var.Be&IndexDate
		&outcome.LA&var.Be&IndexDate;
                &outcome.&var.AF&IndexDate
        %END;
        %DO i=1 %TO &nnvar;
             %LET var=%sysfunc(compress(%qscan(&varnar,&i)));
	     %IF &IndexDate ne %THEN &outcome.Fi&var.Be&IndexDate
	     &outcome.LA&var.Be&IndexDate;
             &outcome.&var.AF&IndexDate
         %END;
    ;
        %DO i=1 %TO &ncvar;
             %LET var=%sysfunc(compress(%qscan(&varcar,&i)));
             %IF &IndexDate ne %THEN %DO;
                label &outcome.FI&var.Be&IndexDate = "First &var for &outcome of &type before inclusion event, &IndexDate";
                label &outcome.LA&var.Be&IndexDate = "Last &var for &outcome of &type before inclusion event, &IndexDate";
             %END;
             label &outcome.&var.AF&IndexDate   = "First &var for &outcome of &type after inclusion event, &IndexDate";
        %END;
         %DO i=1 %TO &nnvar;
             %LET var=%sysfunc(compress(%qscan(&varnar,&i)));
             %IF &IndexDate ne %THEN %DO;
                 label &outcome.Fi&var.Be&IndexDate  = "First &var for &outcome of &type before inclusion event, &IndexDate";
                 label &outcome.LA&var.Be&IndexDate  = "Last &var for &outcome of &type before inclusion event, &IndexDate";
             %END;
             label &outcome.&var.AF&IndexDate    = "First &var for &outcome of &type after inclusion event, &IndexDate";
         %END;

     %DO i=1 %TO &nnvar;
         %LET var=%sysfunc(compress(%qscan(&varnar,&i)));
         %PUT &var;
         %LET format = %varexist(&temp,&var,fmt);
         %PUT format1 &format;
         %IF %length(&format) %THEN %LET format=%sysfunc(substrn(&format,1,%sysfunc(findc(&format,.,-49,sdk))));
         %PUT format2 &format;
         %IF %length(&format) %THEN %LET format=%sysfunc(fmtinfo(&format,cat));
         %PUT format3 &format;
         %IF &format=date %THEN %DO;
             %IF &IndexDate ne %THEN %DO;
                 format &outcome.Fi&var.Be&IndexDate date10.;
                 format &outcome.LA&var.Be&IndexDate date10.;
             %END;
             format &outcome.&var.AF&IndexDate date10.;
             %END;
      %END;
    run;
    %cleanup(&temp); /* ryd op i work */
  %mend;

