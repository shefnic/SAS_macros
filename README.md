# SAS_macros

Here will be where I place macros I write that I think might be generally useful to others.

### M_DISTINCTCOLVAR

The macro creates a new dataset that includes the name of each dataset the variables were found in, the name of all matched variables, and the distinct values stored within them. I've found this macro useful for searching clinical CDISC-compliant datasets where many variables are inter-related but differ by a prefix to the variable name.

```
%distinctcolvar(colvar=, lib=, exact=);
```
`colvar=` the term you wish to search for

`lib=` the name of the library to search through

`exact=` OPTIONAL - Y/N, if N is selected then the term need only consist as a portion of the variable name to be selected by the macro.  Otherwise, only exact matches to the term will be returned.  The default value is Y.


### M_SORTVARS

This macro sorts all, or a subset, of variables within a given dataset. I've found it useful when I need to keep track of a growing number of variables while merging many datasets together.

```
%sortvars(lib=, dset=, suffix=, sort=, start=, end=);
```

`lib=` OPTIONAL - Name of the library that contains the dataset to be sorted.  Defaults to WORK.

`dset=` The name of the dataset to be sorted.

`suffix=` OPTIONAL - Characters to be included at the end of the name of the output sorted dataset.  Defaults to _SORTED.

`sort=` OPTIONAL - DESCENDING or `null` only.  This determines how the variables are to be sorted.  Defaults to `null`, and sorts ascending.

`start=` OPTIONAL - The index, starting with 1, of the left most subset to be sorted.

`end=` OPTIONAL - The index of the right most subset to be sorted.

Note: Start and End default to 0.  When both are 0, all variables in the data set are sorted.
