
//////////////////////////////////////////////////////////////////////////
// 2020 STATA ECONOMETRICS WINTER SCHOOL								//
// January 20-24, 2020													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

// Regression exercise //

clear all
set more off

capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/1.Linear_regression/exercise/logs"                           // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\1.Linear_regression\exercise" 		// THIS IS MY WORKING FOLDER


capture log close
log using regression_exer.txt, text replace

capture use http://fmwww.bc.edu/ec-p/data/wooldridge/cps78_85.dta, clear //THE DESCRIPTION OF VARIABLES IS AT "http://fmwww.bc.edu/ec-p/data/wooldridge/cps78_85.des"
capture save cps78_85, replace

use cps78_85, clear

** 1
describe
summarize

sum, det

** 2
reg  lwage educ exper expersq union female if year==78
	est store W78

reg  lwage educ exper expersq union female  if year==85
	est store W85

est table W78 W85, b(%7.4f) se(%7.4f) stats(N r2_a) 
	
	outreg2 [W78 W85] using exer_reg_w, bdec(4) sdec(4) word excel tex replace
	
* alternatively, use the command asdoc	

ssc install asdoc
	
asdoc reg lwage educ exper expersq union female if year==78, nest save(Table_1.doc) replace
asdoc reg lwage educ exper expersq union female if year==85, nest append save(Table_1.doc)


* explore the new command putdocx

putdocx begin

putdocx paragraph
putdocx text ("Regression Results, Exercise 1")	

reg  lwage educ exper expersq union female  if year==85

putdocx table mytable = etable(1)
putdocx paragraph
putdocx text ("Note: Made by me")	

putdocx save myresults.docx, replace
putdocx clear	
	
** 3
reg  lwage educ exper expersq union female  if year==85
	test exper expersq

** 4
reg  lwage educ c.exper##c.exper union female  if year==85
	margins, dydx(exper)
	
** 4

margins, dydx(exper) at(exper=(0 (5) 55))	
	marginsplot
	
	

** 5
reg  lwage  educ c.exper##c.exper union  i.y85##i.female

di _b[1.y85]+_b[1.y85#1.female]
di exp( _b[1.y85]+_b[1.y85#1.female])-1 // exact variation

log close
