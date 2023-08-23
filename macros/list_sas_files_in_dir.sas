/* SVN header
$Date: 2018-03-15 12:39:34 +0100 (to, 15 mar 2018) $
$Revision: 93 $
$Author: FCNI6683 $
$Id: list_sas_files_in_dir.sas 93 2018-03-15 11:39:34Z FCNI6683 $
*/
/* macro copied from www.wuss.org/proceedings12/55.pdf: obtaining a list of files in a directory using SAS functions */
/*
   List_sas_files_in_dir;
   input:
   path    = path to directory where sas files are present
   outname = name of sas.table with the files listed. will default be called filelist and placed in work
*/
%macro list_sas_files_in_dir(path=, outname=filelist);
  data &outname;
    keep  filename;
    length fref $8 filename $80;
    rc = filename(fref,&path );
    if rc = 0 then do;
      did = dopen(fref);
      rc = filename(fref);
    end;
    else do;
      length msg $200.;
      msg = sysmsg();
      put msg=;
      did = .;
    end;
    if did <= 0 then putlog 'unable to open dir';
      dnum = dnum(did);
      do i=1 to dnum;
        filename = dread(did,i);
      /* if entry is a file, then output */
        fid = mopen (did, filename);
        if fid>0 then output;
      end;
    rc = dclose(did);
  %runquit;
  proc sort data= &outname;
    by filename;
  %runquit;
  data &outname;
    set &outname;
    /* check the file is a sas table: */
    type = scan(filename,-1); /* -1 means scan backwards to delimiter . */
     if type='sas7bdat' then do;
      /* remove file extention */
      filename = substr(filename, 1, length(filename)-9); /* 9=length of .sas7bdat */
      output; /* store sasfiles in list */
    end;
  %runquit;
%mend;
/*
   make_macrolist_from_sas_table;
   input:
   list = name of resulting macrolist
   table = input sas table with the filenames (filename) as variable
*/
%macro make_macrolist_from_sas_table(list, table);
  /* convert sas file to a macrolist */
  proc sql;
    select filename into :looplist separated by " "
    from &table;
  quit;
  %put &list = &looplist;
%mend;
/*
  merge_with_old_files;
  input:
  newdatedir = directory with the newest sas tables;
  olddatedir = directory with the previous version of the sas tables;
  outdir     = output directory. Will probably be olddatedir after proper testing
  listtable  = input sas table with a list of sasfile-names that are present in new- and olddatedir
  newdate    = date of merging files. Replace rec_in with &newdate in newdatedir, and replace rec_out with &newdate-1 in olddatedir
*/
%macro merge_with_old_files(newdatedir, olddatedir, outdir, listtable, newdate);
  %local i next_name looplist;
  /* store macrolist in looplist. Select variables from listtable */
  %make_macrolist_from_sas_table(looplist, &listtable);
  %do i=1 %to %sysfunc(countw(&looplist));
  %let next_name = %scan(&looplist, &i);
  data &outdir..&next_name;
     set &newdatedir..&next_name (in=a) &olddatedir..&next_name (in=b);
     if b and rec_out >= &newdate then rec_out = &newdate -1;
  %runquit;
  %end;
%mend;
