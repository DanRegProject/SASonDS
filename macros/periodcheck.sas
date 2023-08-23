%macro periodcheck(outfile,lib,file,key);
    proc sql;
        create table &outfile as
		select "&lib..&file" as file, %commas(&key), max_out, b.rec_tot-(b.rec_sum+n-1) as dif
		from (
			select %commas(&key), max(a.rec_out) as max_out, max(a.rec_out)-min(a.rec_in) as rec_tot, sum(a.rec_dif) as rec_sum, count(*) as n
			from (
				select %commas(&key), rec_in, rec_out, rec_out-rec_in as rec_dif from &lib..&file
				  ) a
				group by %commas(&key)
			  ) b
            having dif ne 0 or max_out<today()
            order by %commas(&key);
			quit;
    %mend;
/*
   quotelst
*/
%macro quotelst(str, quote=%str(%"),delim=%str( ));
  %local i quotelst;
  %let i=1;
  %do %while(%length(%qscan(&str, &i, %str( ))) GT 0);
    %if %length(&quotelst) EQ 0 %then %let quotelst = &quote.%qscan(&str, &i, %str( ))&quote;
	%else %let quotelst=&quotelst.&quote.%qscan(&str,&i, %str( ))&quote;
	%let i=%eval(&i + 1);
	%if %length(%qscan(&str,&i,%str( ))) GT 0 %then %let quotelst=&quotelst.&delim;
	%end;
  %unquote(&quotelst)
%mend; /* quotelst */
/*
   commas
   convert at string of words to a string of comma separated words
*/
%macro commas(str);
  %quotelst(&str, quote=%str(), delim=%str(, ))
%mend; /* commas */
*options mprint merror;
/*
 libname raw "f:/Projekter/PDB00001220/FSEID00001577/outputdata" access=readonly;
 libname raw "f:/Projekter/PDB00001220/masterdata/raw" access=readonly;
*/
%periodcheck(work.test,raw,lms_epikur2016,cpr_encrypted eksd atc vnr apk doso indo);

*%periodcheck(work.test,raw,lms_laegemiddeloplysninger,vnr);
