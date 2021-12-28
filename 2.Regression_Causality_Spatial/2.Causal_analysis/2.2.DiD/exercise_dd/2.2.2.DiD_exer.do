
//////////////////////////////////////////////////////////////////////////
// 2020 STATA ECONOMETRICS WINTER SCHOOL								//
// January 20-24, 2020													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

// Diff-in-Diff exercise //


clear all
set more off

capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/2.Causal_analysis/2.2.DiD/exercise_dd"  // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\2.causal_analysis\2.2.DiD\exercise_dd" 		// THIS IS MY WORKING FOLDER



capture log close
log using dd_exer.txt, text replace

****DD IMPLEMENTATION;


use hh_9198

* #1
***Simplest implementation;

gen exptot0=exptot if year==0
egen exptot91=max(exptot0), by(nh)
keep if year==1

gen lexptot91=ln(1+exptot91)
gen lexptot98=ln(1+exptot) 
gen lexptot9891=lexptot98-lexptot91

ttest lexptot9891 , by(dmmfd)
ttest lexptot9891 , by(dfmfd)

* #2
***Regression implementation;

use hh_9198,clear
gen lexptot=ln(1+exptot)

gen dfmfd1=dfmfd==1 & year==1
egen dfmfd98=max(dfmfd1), by(nh)

gen treated = dfmfd98

gen after = year
compress
save /Users/miguelportela/Documents/GitHub/R_Training/regression/hh_9198_v2, replace


gen dfmfdyr=dfmfd98*year

***Basic model;
reg lexptot year dfmfd98 dfmfdyr

** alternatively

reg lexptot i.dfmfd98##i.year


* #3
****Full model;

gen lnland=ln(1+hhland/100)

reg lexptot i.dfmfd98##i.year sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg 

reg lexptot i.dfmfd98##i.year sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg [pw=weight] // taking into account the survey weights

log close
