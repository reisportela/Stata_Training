
//////////////////////////////////////////////////////////////////////////
// 2018 STATA ECONOMETRICS WINTER SCHOOL								//
// January 22-26, 2018													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////


// Propensity Scores

clear all
set more off
set rmsg on

capture cd "/Users/miguelportela/Dropbox/statafep2018/day2/2.Causal_analysis/2.4.pscores"
capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/2.Causal_analysis/2.4.PSCORES" // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2018\day2\2.Causal_analysis\2.4.pscores" // MOVE TO YOUR WORKING FOLDER

capture log close
log using psm.txt, text replace

use hh_98
gen lexptot=ln(1+exptot)
gen lnland=ln(1+hhland/100)
capture drop ps98 blockf1 comsup

****Impacts of program participation

***Male participants
****pscore equation

// net install st0026_2.pkg,from("http://www.stata-journal.com/software/sj5-3/") replace

pscore dmmfd sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg [pw=weight], ///
		pscore(ps98) blockid(blockf1) comsup level(0.001) detail
	   
		drop ps98 blockf1
pscore dmmfd sexhead agehead educhead vaccess pcirr rice wheat milk oil [pw=weight], ///
       pscore(ps98) blockid(blockf1) comsup   level(0.001)
	   
twoway (kdensity ps98 if dmmfd==1 || kdensity ps98 if dmmfd==0) // compare distribution of treated and control	   
	   
	   

****Nearest Neighbor Matching;
attnd lexptot dmmfd [pweight=weight], pscore(ps98) comsup

****Stratification Matching;
atts lexptot dmmfd, pscore(ps98) blockid(blockf1) comsup


****Radius Matching;
attr lexptot dmmfd, pscore(ps98) radius(0.001) comsup


****Kernel Matching;
attk lexptot dmmfd, pscore(ps98) comsup bootstrap reps(50)

drop ps98 blockf1

***Female participants; 
****pscore equation;

pscore dfmfd sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg [pw=weight], pscore(ps98) blockid(blockf1) comsup level(0.001)
	   
	   twoway (kdensity ps98 if dmmfd==1 || kdensity ps98 if dmmfd==0) // compare distribution of treated and control	   


****Nearest Neighbor Matching;
attnd lexptot dfmfd [pweight=weight], pscore(ps98) comsup

****Stratification Matching;
atts lexptot dfmfd, pscore(ps98) blockid(blockf1) comsup


****Radius Matching;
attr lexptot dfmfd, pscore(ps98) radius(0.001) comsup

****Kernel Matching;
attk lexptot dfmfd, pscore(ps98) comsup bootstrap reps(50)

****Direct Matching using Nearest neighbor;

// net install nnmatch.pkg,from("http://fmwww.bc.edu/RePEc/bocode/n/") replace

nnmatch lexptot dmmfd sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg [pw=weight], tc(att) m(1)
nnmatch lexptot dfmfd sexhead agehead educhead lnland vaccess pcirr rice wheat milk oil egg [pw=weight], tc(att) m(1)

log close
