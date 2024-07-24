/************************************************************************************
***** Program: 	Fiscal Year Macro	*****
***** Author:	joshkylepearce      *****
************************************************************************************/

/************************************************************************************
Fiscal Year Macro

Purpose:
Define the start & end of the fiscal year based on user-inputted year of interest.

For an overview of worldwide fiscal years, refer to the following URL:
https://www.britannica.com/money/fiscal-year

Input Parameter:
1.	fiscal_year	- fiscal year of interest.

Output Parameters:
1. 	start_date	- Start date of the fiscal year in date9. format.
2.	end_date	- End date of the fiscal year in date9. format.

Macro Usage:
1.	The	fiscal reporting period varies in jursdictions worldwide. 
	This macro is set to the U.S. fiscal year by default. 
	If the user's fiscal year period is not consistent with the U.S., 
	change the 01OCT & 30SEP to match the fiscal year of interest.
	Ensure that the DDMMM format is retained for compatibility.
2.	Run the ficsal_year macro code.
3. 	Call the ficsal_year macro and enter the input parameters.
	e.g. for U.S. in fiscal year 2024:
	%ficsal_year(fiscal_year=2024);
4.	Calling the macro creates two macro variables: start_date & end_date.
	These macros can be used as filters for querying within the fiscal year.

Notes:
-	Input parameter can be entered with/without quotations. 
	This is handled within the macro so that both options are applicable.
************************************************************************************/

%macro fiscal_year(fiscal_year);

/*macro variables available during the execution of entire SAS session*/
%global start_date end_date;

/*
Input parameters are only compatible with macro if not in quotes.
Account for single & double quotations.
*/
/*Remove double quotes*/
%let fiscal_year = %sysfunc(compress(&fiscal_year., '"'));
/*Remove single quotes*/
%let fiscal_year = %sysfunc(compress(&fiscal_year., "'"));

/*Define current & previous year*/
%let year_b = %sysevalf(&fiscal_year.-1);
%let year_e = &fiscal_year.;

/*Define the start & end dates of the fiscal year*/
%let start_date ="01OCT&year_b."d;
%let end_date   ="30SEP&year_e."d;
/*Write the start & end dates to the SAS log*/
%put &start_date. &end_date.;

%mend;

%fiscal_year(2024);

/************************************************************************************
Examples: Data Setup
************************************************************************************/

/*Fictious dataset representing a taxable income per month*/
%macro monthly_increment(iterations);
data taxable_income_data;
%do i = 0 %to &iterations.;
	month=intnx('month',"31DEC2024"d,-&i.,'s');
	taxable_income=round(rand("normal",1000,100),0.01);
	output;
%end;
format month date9.;
run;
%mend;
%monthly_increment(36);

/************************************************************************************
Example 1: Macro Usage (annual income for U.S. fiscal year 2024)
************************************************************************************/

/*Call macro to define the start & end of U.S. 2024 fiscal year*/
%fiscal_year(2024);

/*Filter on output parameter to extract U.S. 2024 fiscal year*/
data annual_income_2024;
	set taxable_income_data;
	where month between &start_date. and &end_date.;
run;

/************************************************************************************
Example 2: Macro Usage (tax owed for U.S. fiscal year 2023)
************************************************************************************/

/*Call macro to define the start & end of U.S. 2023 fiscal year*/
%fiscal_year(2023);

/*Filter on output parameters to extract U.S. 2023 fiscal year*/
data annual_income_2023;
	set taxable_income_data;
	where month between &start_date. and &end_date.;
run;

/*Calculate annual tax owed (37%) for U.S. 2023 fiscal year*/
proc sql;
select
	sum(taxable_income) as total_income_2023
	,sum(taxable_income)*0.37 as tax_owed_37_percent
from
	annual_income_2023
;
quit;