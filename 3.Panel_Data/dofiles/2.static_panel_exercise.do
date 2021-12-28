//////////////////////////////
// Applied Econometrics		//
// Universidade do Minho	//
// October, 2021			//
// Miguel Portela			//
//////////////////////////////

// STATIC PANEL DATA: exercise

	clear all
	set more off
	set matsize 800
	set rmsg on
	
	timer on 1
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/logs"

capture log close
log using static_panel_exercise.txt, text replace

// ########################################################################### //

// # 1. exercise under file 'panel_exercise.pdf'

use ../data/growth_data, clear

// # 1.a
	keep country year isocode rgdpwok education ki kg kc openk

// # 1.b
	gen logrgdpwok=log(rgdpwok)
		label var logrgdpwok "Log of GDP per Worker"
		label var education "Av Education (years)"
	
// # 1.c
	// reshaping the data
	
	reshape wide rgdpwok education ki kg kc openk logrgdpwok, i(country) j(year)
	reshape long rgdpwok@ education@ ki@ kg@ kc@ openk@ logrgdpwok@, i(country) j(year)

// # 1.d
	// as the variable 'country' is a string variable we need to generate a numeric variable based on it
	// the solution is to use the command 'encode'
	// it creates a new variable, 'ccode', which is numeric and has the labels of country on it
	encode country, gen(ccode)

	// xtset & tsset perform an identical task
	tsset ccode year
	xtset ccode year, delta(5)	// our data is on a 5 year interval, so we have to specify the delta

	// alternatively, we could generate a sequencial variable within country based on year
	
	gen double year_num = group(year) // generate the new variable in double format
	
	save ../data/data, replace	// save the data as we are going to use it several times in the following tasks
	save ../export_xtsum_ttesttable/data, replace

// # 1.e

	xtdes	// describe the panel data
	sum		// summarize the panel data
	xtsum
	
	// replicate the values in the Table xtsum using, among others, the command collapse

// # 1.f

	reg logrgdpwok education ki kg kc openk
		est store OLS

	reg logrgdpwok education ki kg kc openk i.ccode
		est store LSDV

	// produce different output tables combining 2 or more regressions
	// look for the example on how to output the results using outreg2
	
	estimates table OLS LSDV, keep(education ki kg kc openk) b(%7.4f) se(%7.4f) stats(N r2_a)
	
	estimates table OLS LSDV, keep(education ki kg kc openk) b(%7.4f) star stats(N r2_a)

// # 1.g

	xtreg logrgdpwok education ki kg kc openk, fe
		est store FE
	
	// first-differences estimation using the time operators (the data must be tsset)
	// l. == stands for lag
	
	sum l.education l2.education
	sum l(1/2).education

	// d. == first-differences
	sum d.education l.d.education
	
	// l.d. ==performs the lag of first differences
	reg d.logrgdpwok d.education d.ki d.kg d.kc d.openk

// # 1.h

	xtreg logrgdpwok education ki kg kc openk, be
		est store BE

	estimates table OLS LSDV FE BE, keep(education ki kg kc openk) b(%7.4f) star stats(N r2_a)

// # 1.i
	xtreg logrgdpwok education ki kg kc openk, re
		est store RE

	estimates table OLS LSDV FE BE RE, keep(education ki kg kc openk) b(%7.4f) star stats(N r2_a)

// # 1.j

	// test the validity of the RE estimator
	// the null hypothesis implies that the RE is not rejected
	// in the hausman command you first wright the consistent model, FE, and latter the efficient, lower variance, model, RE
	
	hausman FE RE



// ########################################################################### //

// additional elements applied to panel data //

// ########################################################################### //


// # 2. generate "random numbers"
	
	preserve
		clear
		set obs 100
		set seed 444555666
		gen x = uniform()
		list in 1/10
	restore


// ########################################################################### //


// # 3. random sampling (5%)

	use ../data/data, clear	
		set seed 345345345	// its mandatory to define the seed in order to able to replicate your analysis in the future, or by other researchers
		sample 5
		unique ccode
		xtsum

		// this is not the correct solution under panel data
		
	reg logrgdpwok openk
	xtreg logrgdpwok openk, fe cluster(ccode)

	use ../data/data, clear	
		set seed 345345345
		
		//findit sample2 ====> to install the command the first time
		
		sample2 5, cluster(ccode) // correct sample solution for panel data
		// it samples units and keeps all its observations
		unique ccode
		xtsum

	reg logrgdpwok openk
	xtreg logrgdpwok openk, fe cluster(ccode)

		// compare the estimation results after sample and sample2


// ########################################################################### //


// # 4. explore the command bysort

	use ../data/data, clear
		drop if ki == .
		list ccode year ki in 1/10
		bysort ccode year: gen obs_number = _n	// run the command within the pair ccode & year
			list ccode year ki obs_number in 1/10
		
		bysort ccode (year): gen obs_number2 = _n	// run the command within ccode, but sort
													// the data by year
		
			list ccode year ki obs_number obs_number2 in 1/10


// ########################################################################### //

// # 5. use of dummy variables

	tab ccode
	tab ccode, nol
	reg logrgdpwok education ki kg kc openk b9.ccode	// define the base category of ccode as category 9
	reg logrgdpwok education ki kg kc openk b9.ccode i.year	// let Stata choose the base category
														// it usually defines it as the 1st category, or the most common

	reg logrgdpwok education ki kg kc openk b9.ccode i.year, nocons	// estimate a model without a constant

// ########################################################################### //

timer off 1
timer list 1

log close
clear all
