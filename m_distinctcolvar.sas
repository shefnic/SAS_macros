%********************************************************************************************;
%**Author: Nicholas Shefte, 2017;
%********************************************************************************************;

%macro distinctcolvar(colvar=, lib=, exact=Y);

%let colvar=%upcase(&colvar.);
%let lib=%upcase(&lib.);
%let exact=%upcase(&exact.);

%if &exact.=Y %then %do;
	%let sqlcomp=upcase(name) = upcase("&colvar.");
	%let dsetfind=strip(&colvar.);
%end;
%else %if &exact.=N %then %do;
	%let sqlcomp=index(upcase(name), upcase("&colvar."));
%end;

proc sql noprint;

	create table _datasets as
	select memname, name
	from dictionary.columns
	where libname = upcase("&lib.") and &sqlcomp.;

  %let dsid=%sysfunc(open(_datasets));
  %let dnobs=%sysfunc(attrn(&dsid.,nlobs));
  %let rc=%sysfunc(close(&dsid.));

	%if %eval(&dnobs.)=0 %then %do;
		quit;
		proc datasets nolist lib=work; delete _datasets; run;
		%put NOTE: No datasets contain variable &colvar. within library &lib..;
		%goto endmac;
	%end;

		select left(put(count(memname), 8.)) 
		into :libcount
		from _datasets;

	%if &exact.=Y %then %do;
  %********************************************************************************************;
  %** Mode 1: Exact Variable Query **;
  %********************************************************************************************;
		select trim(memname)
		into :ds1 - :ds&libcount
		from _datasets;


		%do i=1 %to &libcount;
			proc sql;
			create table temp&i as
			select distinct catx("::", "&&ds&i", strip(&colvar.)) as results
			from &lib..&&ds&i;
		%end;

		quit;

		data dpgs;
			set temp:;
			length dataset &colvar. $200.;
			dataset = scan(results, 1, "::");
			&colvar. = scan(results, 2, "::");
			keep dataset &colvar.;
		run;
	%end;
	%else %if &exact.=N %then %do;
  %********************************************************************************************;
  %** Mode 2: Inexact Variable Query **;
  %********************************************************************************************;

		select catx('::',trim(memname),trim(name))
		into :ds1 - :ds&libcount
		from _datasets;

		%do i=1 %to &libcount;
			create table temp&i as
			select distinct catx("::",scan("&&ds&i",1,"::"), scan("&&ds&i",2,"::"), %scan(&&ds&i,2,"::")) 
				as results
			from &lib..%scan(&&ds&i,1,"::");
		%end;		

		quit;

		data dpgs;
			set temp:;
			length dataset varname value $200.;
			dataset = scan(results, 1, "::");
			varname = scan(results, 2, "::");
			value = scan(results, 3, '::');
			keep dataset varname value;
		run;

	%end;

		proc datasets nolist lib=work; delete temp1 - temp&libcount _datasets; run;

quit;

%endmac:
%mend distinctcolvar;

%distinctcolvar(colvar=term, lib=sdtm, exact=n);
