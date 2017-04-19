%*****************************************************************;
%**Author: Nicholas Shefte, 2017;
%*****************************************************************;


%macro sortvars(lib=WORK, dset=, suffix=_SORTED, sort=, start=0, end=0);

%if not %sysfunc(exist(&lib..&dset.)) %then %do;
                %put %str(ER)ROR: &lib..&dset does not exist;
                %goto endmac;
%end;

proc sql noprint;
	create table varnames_unsorted as
	select name
	from sashelp.vcolumn
	where libname = strip(upcase("&lib."))
		and memname = strip(upcase("&dset."));

	select count(name) into :numvars
	from varnames_unsorted;

quit;


**Where start and end are default values, sort the entire dataset**;
%if &start. = 0 and &end. = 0 %then %do;
	proc sort data=varnames_unsorted out=varnames_sorted;
		by &sort. name;
	run;
%end;

/*Check for legal indices when provided*/
%else %if &start. < 1 and &end. < 2 %then %do;
	%put %str(ER)ROR: (m_sortvars) START &start. and END &end. do not correspond to a legal range in &lib..&dset.;
	%goto endmac;
%end;

%else %if &end. > &numvars. %then %do;
	%put %str(ER)ROR: (m_sortvars) END index &end. is greater than the number of variables %cmpres(&numvars.) in &lib..&dset.;
	%goto endmac;
%end;

%else %if &start. = &end. %then %do;
	%put %str(NO)TE: (m_sortvars) START index &start. equals END index &end.;
	%goto endmac;
%end;

%else %if &start. > &end. and &end. ^= 0 %then %do;
	%put %str(ER)ROR: (m_sortvars) START index &start. greater than END index &end.;
	%goto endmac;
%end;

/*If indices are legal, subset names, sort, then recombine*/
%else %do;
	data temp_start temp_end temp_sortrange;
		set varnames_unsorted;

		if _N_ < &start. then output temp_start;
		else if _N_ > &end. then output temp_end;
		else output temp_sortrange;
	run;

	proc sort data=temp_sortrange;
		by &sort. name;
	run;

	data varnames_sorted;
		set temp_start temp_sortrange temp_end;
	run;

	proc datasets nolist lib=work;
		delete
			temp_start
			temp_sortrange
			temp_end;
	run;

%end;


proc sql noprint;
	select name into :vars separated by " "
	from varnames_sorted;
quit;

data &dset.&suffix.;
	retain &vars.;
	set &dset.;
run;

proc datasets nolist lib=work;
	delete
		varnames_unsorted
		varnames_sorted;
run;

%endmac:
%mend sortvars;
%sortvars(dset=testdat);
