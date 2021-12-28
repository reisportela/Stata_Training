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
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/panel_simulation/logs"

capture log close
log using panel_simulation_full.txt, text replace

global st = "$S_TIME"

mat def mat_seed = .
mat def mat_size = .
mat def mat_beta_educ = .

// 1st seed
set seed 444555666	// specify initial value of random-number seed

// start here

// sample size
local nnn = "1000 2500"		// we will work with two sample sizes
tokenize `nnn'

foreach nobs of local nnn {

// number of simulations for each sample size
foreach v of numlist 1/25 {

clear

// renew 'seed'

		set obs 1
		gen a = int(uniform()*1000000000)
		format %16.0f a
		l a
		sum a
		ret li
			local seed2 = r(mean)

			di _new _new "/////////////////////////////////////////////////////////////////////////////" _new
			display _new _new _new "PARAMETERS:	SIZE: `nobs' SEED: `seed2'" _new _new
			di _new "/////////////////////////////////////////////////////////////////////////////" _new

// generate the variables relevant for the estimations

set obs `nobs'		// set the number of observation in the sample
gen idtrab = int(_n/10.1)+1

bysort idtrab: gen year = _n
sort idtrab year
tsset idtrab year

set seed `seed2'
bysort idtrab (year): gen double ui = runiform() if _n == 1
     bysort idtrab (year): replace ui = ui[_n-1] if _n > 1

// build the instrument

bysort idtrab (year): gen quarter= int(4*uniform()+1) if _n == 1
     bysort idtrab (year): replace quarter = quarter[_n-1] if _n > 1

	gen q1=(quarter==1)
	 
bysort idtrab (year): gen educ= int(25*uniform())*ui if _n == 1		// define education as a function of the specific effect
	bysort idtrab (year): replace educ= educ - 3*q1 if _n == 1		// define education as a function of the instrument

	bysort idtrab (year): replace educ = educ[_n-1] + round(uniform()) if _n > 1		// increase education over time following a random distribution
		sum educ, detail
	
bysort idtrab (year): gen exper= int(20*uniform()) if _n == 1		// define experience fo each worker
	bysort idtrab (year): replace exper = exper[_n-1] + 1 if _n > 1

	gen exper2 = exper^2

// minimum wage = 485 euro
gen double lnwage = ln(485) + 0.06*educ + 0.007*exper - 0.00001*exper2 + 0.02*year + ui + uniform()/ln(485)

// this is the regression we want to estimate

xi: ivreg2 lnwage (educ = q1) exper exper2 year, first
	
	mat mat_size = mat_size\(`nobs')
	mat mat_seed = mat_seed\(`seed2')
	mat mat_beta_educ = mat_beta_educ\_b[educ]
	
}
}

clear


// transform matrices in data/variables


svmat mat_seed, n(mat_seed)
svmat mat_size, n(mat_size)
svmat mat_beta_educ, n(mat_beta_educ)

format %16.0f mat_seed mat_size
format %5.4f mat_beta_educ
drop if mat_size == .
sum
save data_beta_educ, replace

use data_beta_educ, clear

// graph the distribution of betas
kdensity mat_beta_educ, xline(.06)
	twoway kdensity mat_beta_educ1 if mat_size1 == `1',yaxis(1) legend(on label(1 "Sample Size: `1'"))/*
	*/ ytitle("Returns to E ducation") || kdensity mat_beta_educ1 if mat_size1 == `2', yaxis(2) legend(on label(2 "Sample Size: `2'")) /*
	*/ xline(.06) ytitle("Returns to E ducation",axis(2))

	graph export beta_educ1.png, replace

elapse $st

timer off 1
timer list 1

log close
