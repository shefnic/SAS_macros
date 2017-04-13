# SAS_macros

Here will be where I place macros I write that I think might be generally useful to others.

## M_DISTINCTCOLVAR

This macro I've found useful for searching clinincal datasets where many variables are inter-related but differ by a prefix to the variable name.  The macro creates a dataset that includes the names of the datasets the variables were found in, the name of all matched variables, and the distinct values stored within. 

'''
%distinctcolvar(colvar=, lib=, exact=);
'''
'colvar=' the term you wish to search for

'lib=' the name of the library to search through

'exact=' Y/N, if N is selected then the term need only consist as a portion of the variable name to be selected by the macro.  Otherwise, only exact matches to the term will be returned.  The default value is Y.
