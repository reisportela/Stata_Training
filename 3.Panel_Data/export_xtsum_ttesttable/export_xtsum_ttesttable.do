//////////////////////////////
// Applied Econometrics		//
// Universidade do Minho	//
// October, 2021			//
// Miguel Portela			//
//////////////////////////////

// STATIC PANEL DATA
	clear all
	set more off
	set matsize 800
	set rmsg on
	
	timer on 1
	
		capture cd "/Users/miguelportela/Dropbox/3.aulas/2021/mestrado/econometria_aplicada/1.aulas/1.panel_static/export_xtsum_ttesttable"

capture log close
log using xtsum_ttesttable.txt, text replace

// command: ttesttable

// use the command ttesttable and export the output to word
capture net install ttesttable.pkg
//h ttesttable

// # 1. example using a system dataset
sysuse auto, clear
	ttesttable price rep78, f(%6.1f) ref(1 2)

// # 2. another example
use data
xtset ccode year,delta(5)
xtserial logrgdpwok education ki
	ttesttable education ki, f(%6.1f) ref(1 2)

// in Stata the unequal sign is defined as ~= or !=
ttesttable education year if year != 1960, f(%6.1f)
ttesttable education year if year ~= 1960, f(%6.1f)
	return list	// return stored results
	
	putexcel set ttesttable.xls, replace
	putexcel C3=matrix(r(diff),  r(t),  r(p)), colwise

// as we are working with different variable, we also change in the starting cell (ex. C3, C8... 5 em 5);
// in excel we will get the formats conditional on p-values


// command: xtsum
xtsum education ki
	ret li // equivalent to return list

tempname tmp //	tempname assigns names to the specified local macro names that may be used as temporary scalar or matrix names
postfile `tmp' str32(var category)/* Post results in Stata dataset
*/  mean sd min max obs using xtsum.dta, replace // use v5_xtsum to save output

foreach var of varlist education ki{ // variables
	qui xtsum  `var'
	post `tmp' ("`var'") ("overall") /*
		*/ (`r(mean)') (r(sd)) (r(min)) /*
		*/ (r(max)) (r(N))
	post `tmp' ("`var'") ("between") /*
		*/ (.) (r(sd_b)) (r(min_b)) /*
		*/ (r(max_b)) (r(n))
	post `tmp' ("`var'") ("within") /*
		*/ (.) (r(sd_w)) (r(min_w)) /*
		*/ (r(max_w)) (r(Tbar))	
}

postclose `tmp'

use xtsum.dta, clear
	list, abbrev(12) noobs sepby(var)

//to spreadsheet!
xmlsave "xtsumfile", doctype(excel) replace
!start xtsumfile.xml	// execute a DOS command == sh start xtsumfile.xml

log close
