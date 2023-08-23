%MACRO vwLPR(st,sl);
    %local I;
    proc sql;
    %DO I=&st %TO &sl;
      create view Master.vwLPR&I._hist as
        select a.pnr,a.recnum, a.indate, a.outdate,
        a.pattype,
        a.hospital,
        a.hospitalunit,
        b.diagnose,
        b.diagtype,
        a.aar, a.rec_in, a.rec_out, a.DataValidUntil
        from Master.LPR_IND&I._hist a left join Master.LPR_DIAG&I._hist b
        on a.recnum=b.recnum and a.rec_out=b.rec_out
        where b.diagtype ne '+'
        order by pnr;
     %END;
  quit;
%MEND;


%MACRO aariLPR(st,sl);
    %local I;
    %DO I=&st %TO &sl;
    data Master.LPR_IND&I._hist;
      set Master.LPR_IND&I._hist;
      aar = year(inddto);
    run;
  %END;
%MEND;

%MACRO vwLPRsksopr(st,sl);
    %local I;
    proc sql;
  %DO I=&st %TO &sl;
    create view Master.vwLPRSKSOpr&I._hist as
      select a.pnr,a.recnum, a.indate, a.outdate,
      a.pattype as pattype label="Patienttype",
      a.hospital,
      a.hospitalunit,
      b.opr label="Operationskode",
      b.oprart label="Operationsart",
      b.odto label="Operationsdato",
      b.osgh label="Opererende sygehus",
      b.oafd as oafd label="Opererende afdeling" format=$3.,
      a.aar as year,
      a.rec_in, a.rec_out, a.DataValidUntil
      from Master.LPR_IND&I._hist a
      inner join
      Master.lpr_sksopr&I._hist b
      on a.recnum = b.recnum and a.rec_out=b.rec_out
      where b.oprart ne '+';
  %END;
quit;
%MEND;


%MACRO vwLPRsksube(st,sl);
    %local I;
    proc sql;
  %DO I=&st %TO &sl;
    create view Master.vwLPRSKSUBE&I._hist as
      select a.pnr,a.recnum, a.indate as indate, a.outdate as outdate,
      a.pattype as pattype label="Patienttype",
      a.hospital,
      a.hospitalunit,
      b.opr label="Operationskode",
      b.oprart label="Operationsart",
      b.odto label="Operationsdato",
      b.osgh as osgh label="Opererende sygehus" format=$3.,
      b.oafd as oafd label="Opererende afdeling" format=$3.,
      a.aar as year,
      a.rec_in, a.rec_out, a.DataValidUntil
      from Master.LPR_IND&I._hist a inner join
      Master.lpr_sksube&I._hist b
      on a.recnum = b.recnum  and a.rec_out=b.rec_out
      where b.oprart ne '+';
  %END;
quit;
%MEND;


%MACRO _copyraw(data,idx,rawlib=raw);
    proc sql;
      create table Master.&data._hist as
        select * from
          &rawlib..&data
          order by &idx;
        create index &idx on Master.&data._hist (&idx);
    quit;
%MEND;

%MACRO copyraw(data,idx,st="",sl="",rawlib=raw);
    %IF &st="" %THEN %DO;
        %_copyraw(&data,&idx,rawlib=&rawlib);
        %END;
    %ELSE %DO;
        %DO I= &st %TO &sl;
            %_copyraw(&data&I,&idx,rawlib=&rawlib);
            %END;
        %END;
    %MEND;

  %MACRO _doindex(data,idx,idxlist);
    proc sql;
        create index &idx on &data._hist (%commas(&idxlist));
        quit;
    %MEND;

%MACRO doIndex(data,idx,idxlist,st="",sl="");
    %local I;
    %IF &st="" %THEN %DO;
        %_doindex(&data,&idx,&idxlist);
        %END;
    %ELSE %DO;
        %DO I= &st %TO &sl;
            %_doindex(&data&I,&idx,&idxlist);
            %END;
        %END;
    %MEND;

%MACRO reciLPR(data, st,sl);
    %local I;
    %DO I=&st %TO &sl;
    data &data&I._hist;
    set &data&I._hist;
    rec_in = mdy(12,31,&I);
    rec_out = &globalend;
    format rec_in rec_out date.;
    run;
  %END;
%MEND;

%MACRO LPR_aar_rec(data, st,sl);
  %DO I=&st %TO &sl;
    data &data&I._hist;
    set &data&I._hist;

    aar = year(inddto);
    rec_in = mdy(12,31,&I);
    rec_out = &globalend;
    format rec_in rec_out date.;
    run;
  %END;
%MEND;


%MACRO doIndexlist(data,idx,st="",sl="");
    %local I x nidx;
    %LET nidx=%sysfunc(countw(&idx));

  %IF &st="" %THEN %DO;
    %do x=1 %to &nidx;
      %LET index=%sysfunc(compress(%qscan(&idx,&x)));
      %_doindex(&data,&index,&index);
  %end;
  %END;
  %ELSE %DO;
    %DO I= &st %TO &sl;
      %do x=1 %to &nidx;
        %LET index=%sysfunc(compress(%qscan(&idx,&x)));
        %_doindex(&data&I,&index,&index);
      %END;
    %END;
  %end;
%MEND;


%macro upd_SSI_lpr(st, sl, nr, validuntil);
    %local I;
    %do I=&st %to &sl;

    proc sql;
        create table work.lpr_ind&I._notused as
          select a.pnr, a.recnum format=$14., a.D_inddto as indate, a.d_uddto - a.D_inddto as sengdage, YEAR(D_inddto) as
          aar, a.d_uddto as outdate, input(a.c_pattype,8.) as pattype, a.v_indtime as indtime, a.v_indminut as indminut,
          a.c_SGH as hospital, a.c_AFD as hospitalunit, input(b.c_diag,$20.) as adiag,
          case when substr(b.c_diag,1,1)="D" then substr(b.c_diag,2,length(b.c_diag))
          else b.c_diag end as ADIAG1, &&raw&nr.dat as rec_in, &globalend as  rec_out
          from raw&nr..T_ADM a, raw&nr..t_diag b
          where a.recnum=b.recnum and YEAR(a.D_inddto) = &I and b.c_diagtype="A";

        create table work.lpr_ind&I._hist as
          select a.pnr, a.recnum format=$14., a.D_inddto as indate, YEAR(D_inddto) as
          aar, a.d_uddto as outdate, input(a.c_pattype,8.) as pattype,
          a.c_SGH as hospital, a.c_AFD as hospitalunit, input(b.c_diag,$20.) as ADIAG,
          &&raw&nr.dat as rec_in, &globalend as  rec_out,
          &validuntil as DataValidUntil format=date.
          from raw&nr..T_ADM a, raw&nr..t_diag b
          where a.recnum=b.recnum and YEAR(a.D_inddto) = &I and b.c_diagtype="A";

      create table work.lpr_diag&I._hist as
          select b.recnum format=$14.,
          b.c_diagtype as diagtype, b.c_tildiag as tildiag,
          case when substr(b.c_diag,1,1)="D" then substr(b.c_diag,2,length(b.c_diag))
          else b.c_diag end as diagnose, &&raw&nr.dat as rec_in, &globalend as  rec_out ,
          &validuntil as DataValidUntil format=date.
          from work.lpr_ind&I._hist a, raw&nr..t_diag b
          where a.recnum=b.recnum;

        create table work.lpr_sksube&I._hist as
          select b.recnum format=$14., b.c_OPR as OPR, b.c_OPRART as OPRART, b.c_TILOPR as TILOPR,
          b.D_ODTO as ODTO, b.V_OTIME as OTIME, b.V_OMINUT as OMINUT, "" as OSGH, "" as OAFD ,
          &&raw&nr.dat as rec_in, &globalend as  rec_out ,
          &validuntil as DataValidUntil format=date.
          from work.lpr_ind&I._hist a, raw&nr..t_sksube b
          where a.recnum=b.recnum;

        create table work.lpr_sksopr&I._hist as
          select b.recnum format=$14., b.c_OPR as OPR, b.c_OPRART as OPRART, b.c_TILOPR as TILOPR,
          b.D_ODTO as ODTO, b.V_OTIME as OTIME, b.V_OMINUT as OMINUT, "" as OSGH, "" as OAFD,
          &&raw&nr.dat as rec_in, &globalend as  rec_out ,
          &validuntil as DataValidUntil format=date.
          from work.lpr_ind&I._hist a, raw&nr..t_sksopr b
          where a.recnum=b.recnum;
     quit;

     data master.lpr_ind&I._notused;
       set work.lpr_ind&I._notused master.lpr_ind&I._notused (in=a);
         format rec_in rec_out date.;

       if (a and rec_out=&globalend) then rec_out = &&raw&nr.dat -1;
       else ;
     %runquit;

     data master.lpr_ind&I._hist;
       set work.lpr_ind&I._hist master.lpr_ind&I._hist (in=a);
         format rec_in rec_out date.;

       if (a and rec_out=&globalend) then rec_out = &&raw&nr.dat -1;
       else ;
     %runquit;

     proc sort data=master.lpr_ind&I._hist;
       by pnr rec_out rec_in  ;
     %runquit;

     data master.lpr_diag&I._hist;
       set work.lpr_diag&I._hist master.lpr_diag&I._hist (in=a);
         format rec_in rec_out date.;

       if (a and rec_out=&globalend) then rec_out = &&raw&nr.dat -1;
       else ;
     %runquit;

     proc sort data=master.lpr_diag&I._hist;
       by recnum rec_out rec_in ;
     %runquit;

     data master.lpr_sksube&I._hist;
       set work.lpr_sksube&I._hist master.lpr_sksube&I._hist (in=a);
         format rec_in rec_out date.;

       if (a and rec_out=&globalend ) then rec_out = &&raw&nr.dat -1;
       else ;
     %runquit;

     proc sort data=master.lpr_sksube&I._hist;
       by recnum rec_out rec_in ;
     %runquit;

     data master.lpr_sksopr&I._hist;
       set work.lpr_sksopr&I._hist master.lpr_sksopr&I._hist (in=a);
         format rec_in rec_out date.;

       if (a and rec_out=&globalend ) then rec_out = &&raw&nr.dat -1;
       else ;
     %runquit;

     proc sort data=master.lpr_sksopr&I._hist;
       by recnum rec_out rec_in ;
     %runquit;
   %end;
 %mend;
