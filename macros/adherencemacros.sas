    /* dan behandlingsperioder ud fra foreningsm_ngden af periode - alts_  behandling uanset hvilket _gemiddel */
%macro jointrt(outdata,name,list,postfix,inlib=work,indatalist=);
    %local i val vset vstart vend;
    %let i=1;
   %do %while (%scan(&list,&i) ne );
       %let val=%scan(&list,&i);
       %if &indatalist= %then %let vset = &vset &inlib..&val.&postfix;;
       %let vstart=&vstart &val.start;
       %let vend=&vend &val.end;
	   %let i=%eval(&i+1);
       %end;
   %if &indatalist ne %then %let vset=&indatalist;
data &outdata;
    set &vset;
	&name.start=max(%commas(&vstart));
	&name.end=max(%commas(&vend));
	format &name.start &name.end date.;
	keep pnr &name.start &name.end;
    %runquit;
proc sort data=&outdata;
    by pnr &name.start &name.end;
    %runquit;
data &outdata;
    set &outdata;
    retain newstart newend;
    by pnr &name.start;
    if first.pnr then do;newstart=&name.start; newend=.;end;
    if not first.pnr and &name.start>newend then do; output; newstart=&name.start; end;
        if last.pnr then do; newend=max(newend,&name.end); output; end;
            newend=max(newend,&name.end);
            keep pnr newstart newend;
            format newstart newend date.;
            %runquit;
data &outdata; set &outdata;
    rename newstart=&name.start newend=&name.end;
    %runquit;
%mend;


%macro mergeperiods(basedata,perdata,indexdate,pervar,postfix=);
%local per1 per2 per3;
%let per1=%newdatasetname(per1tmp);
%let per2=%newdatasetname(per2tmp);
%let per3=%newdatasetname(per3tmp);
proc sql;
create table &per1 as select a.pnr, b.&indexdate,
       a.&pervar.start as &pervar.stbe&indexdate&postfix label="startdate last &pervar period before &indexdate",
        a.&pervar.end as &pervar.enbe&indexdate&postfix  label="enddate last &pervar period before &indexdate"
	from &perdata a, &basedata b
	where a.pnr=b.pnr and a.&pervar.end<&indexdate
	order by a.pnr, b.&indexdate, a.&pervar.start ;
create table &per2 as select a.pnr, b.&indexdate,
       a.&pervar.start as &pervar.stdu&indexdate&postfix label="Startdate current &pervar period covering &indexdate",
        a.&pervar.end as &pervar.endu&indexdate&postfix  label="enddate current &pervar period covering &indexdate"
	from &perdata a, &basedata b
	where a.pnr=b.pnr and a.&pervar.start<=&indexdate and &indexdate<= a.&pervar.end
	order by a.pnr, b.&indexdate, a.&pervar.start;
create table &per3 as select a.pnr, b.&indexdate,
       a.&pervar.start as &pervar.staf&indexdate&postfix label="startdate first &pervar period after &indexdate",
        a.&pervar.end as &pervar.enaf&indexdate&postfix  label="Enddate first &pervar period after &indexdate"
	from &perdata a, &basedata b
	where a.pnr=b.pnr and a.&pervar.start>&indexdate
	order by a.pnr, b.&indexdate, a.&pervar.start;
%runquit;
data &per1;
set &per1;
by pnr &indexdate;
if last.&indexdate;
%runquit;

data &per3;
set &per3;
by pnr &indexdate;
if first.&indexdate;
%runquit;

data &basedata;
merge &basedata &per1 &per2 &per3;
by pnr &indexdate;
%runquit;
%cleanup(&per1);%cleanup(&per2);%cleanup(&per3);
%mend;

/* beregn antal dage i behandling i en periode */
%macro dayscov(basedata,perdata,outdata,outvar,indexdate,days,pervar,join=true);
    proc sql;
create table &outdata as
select c.pnr, c.&indexdate, sum(c.days) as &outvar from
(
select a.pnr, a.&indexdate,
%if &days<0 %then %do;
    (case when &pervar.end>&indexdate then &indexdate else &pervar.end end) -
    (case when &pervar.start<&indexdate+&days then &indexdate+&days else &pervar.start end)
        %end;
%if &days>0 %then %do;
    (case when &pervar.end> (case when &indexdate+&days<pop_out then &indexdate+&days else pop_out end)
        then (case when &indexdate+&days<pop_out then &indexdate+&days else pop_out end) else &pervar.end end) -
    (case when &pervar.start<&indexdate then &indexdate else &pervar.start end)
        %end;
 as days from
&basedata a full join &perdata b
on a.pnr=b.pnr and (&pervar.start <=
%if &days<0 %then %do;
      &indexdate
%end;
%if &days>0 %then %do;
        &indexdate+&days
%end;
     and &pervar.end >=
%if &days<0 %then %do;
     &indexdate+&days
%end;
%if &days>0 %then %do;
         &indexdate
%end;)
having days >.
) c
group by c.pnr, c.&indexdate;
%if &join=true %then %do;
    data &basedata;
        merge &basedata &outdata;
        by pnr &indexdate;
        %runquit;
    %end;
quit;
%mend;
