/*
					         immigration   basedate       emigration
	 born ----------------------|------------ |--------------|------------dead
	                            |---------active-------------| output table
                                in                           out
	Output table &output..personer contains the periods the population was registred as active.
*/
%macro getPOP(outdata, basedata);
%let globalstart = mdy(01,01,1920);
proc sql ;
  create table &outdata as
    select
    c.pnr,
    a.c_kon as sex_txt, /* ændre til sex? */
	case
	    when a.c_kon = "M" then 0
		when a.c_kon = "K" then 1
	  else
		2 end
	  as sex,
	  d_fodaar as birthyear,
	  d_fodmaaned as birthmonth,
	  mdy(d_fodmaaned,15,d_fodaar) as birthdate format=date., /* replace date with 15. */
      a.c_status as status,
	case
	    when a.c_status = "90" then "dead"
        when a.c_status = "80" then "out_of_country"
        when a.c_status = "01" then "active"
        when a.c_status = "03" then "active"     /* speciel vejkode */
        when a.c_status = "05" then "active"     /* bopæl i Grønlandsk folkeregister */
        when a.c_status = "07" then "active"     /* Special vejkode i Grønlandsk folkeregister */
	    when a.c_status = "70" then "not_active" /* forsvundet */
        when a.c_status = "60" then "not_active" /* ændret personnummer ved ændring af fødselsdato og køn */
        when a.c_status = "50" then "not_active" /* slettet personnummer ved dobbeltnummer */
        when a.c_status = "30" then "not_active" /* annulleret personnummer */
        when a.c_status = "20" then "not_active" /* uden bopæl i DK/Gl, pnr af skattehensyn */
	  else
        "none of the above" end
      as description,
	case
        when a.c_status = "90" then a.d_status_hen_start
	  else
        . end
      as deathdate format=date9.,
	a.d_status_hen_start as statusdate,
	b.d_udrejse_dato as out_date,
	b.d_indrejse_dato as in_date,
	a.rec_in format=date9.,
    a.rec_out format=date9.
    from
	&basedata c join  /* select pnr from basedata */
    raw.cpr3_t_person a on c.pnr=a.v_pnr_encrypted
    left join
    raw.cpr3_t_adresse_udland_hist b
    on
	a.v_pnr_encrypted=b.v_pnr_encrypted and (b.d_udrejse_dato<b.d_indrejse_dato or b.d_indrejse_dato=.)
	order by pnr, out_date, in_date, statusdate, rec_in;
%sqlquit;
%mend;
