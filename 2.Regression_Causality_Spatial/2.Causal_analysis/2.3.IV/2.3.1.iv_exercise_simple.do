
//////////////////////////////////////////////////////////////////////////
// 2018 STATA ECONOMETRICS WINTER SCHOOL								//
// January 22-26, 2018													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

// IV EXERCISE //

// BASED ON "Using Geographic Variation in College Proximity to Estimate the Return to Schooling."
// In L.N. Christofides, E.K. Grant, and R. Swidinsky, editors, Aspects of Labor Market Behaviour:
// Essays in Honour of John Vanderkamp Toronto: University of Toronto Press, 1995. 
// NBER working paper No. 4483 (1993)

clear all
set more off
set rmsg on

capture cd "/Users/miguelportela/Dropbox/statafep2018/day2/2.Causal_analysis/2.3.iv"
capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/2.Causal_analysis/2.3.IV" // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2018\day2\2.Causal_analysis\2.3.iv" // MOVE TO YOUR WORKING FOLDER

capture log close
log using logs/iv_exercise_simple.txt, text replace


// Wooldridge's data
// use http://fmwww.bc.edu/ec-p/data/wooldridge/card.dta, clear // THE DESCRIPTION OF VARIABLES IS AT http://fmwww.bc.edu/ec-p/data/wooldridge/card.DES
// save data\card, replace

use data/card, clear
	
****** 1
*** first step    
	regress educ exper nearc4
	predict educ_hat, xb

*** second step
	reg lwage educ_hat exper

*** ivregress command
	ivregress 2sls lwage (educ=nearc4) exper
	estat firststage
	capture estat overid	// if you have overidentifying restrictions - more excluded instruments than endogenous variables 

****** Wald estimator

	reg educ nearc4 exper
		loc p=_b[nearc4]
	reg lwage  nearc4 exper
		loc g=_b[nearc4]
		
		di `g'/`p'

**** example with ivreg2

	loc x exper* smsa* south mar black reg662-reg669
	reg lw educ `x'
	ivreg2 lw `x' (educ=nearc2 nearc4), first endog(educ)
	ivreg2 lw `x' (educ=nearc2 nearc4), liml

log close
