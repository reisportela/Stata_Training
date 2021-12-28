
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
capture cd "C:\fep2018\day2\2.Causal_analysis\2.3.iv" // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2018\day2\2.Causal_analysis\2.3.iv" // MOVE TO YOUR WORKING FOLDER

capture log close
log using logs/iv_exercise.txt, text replace

// REPLICATE TABLES 2 & 3 FROM THE PAPER using the original data

use data/data_card_proximity, clear
	describe
	sum
	
	// Table 2, OLS regressions

	gen exp76 = age76 - ed76 - 6
	gen exp762 = (exp76^2)/100
	
		reg lwage76 ed76 exp76 exp762 black reg76r smsa76r
			est store OLS1
			outreg2 using logs/output_iv_base, dec(4) nocons/*
				*/ word label addnote(Source: Card, proximity paper,) replace ctitle(OLS1) /*
				*/ adds(R-squared, e(r2))
	
		reg lwage76 ed76 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
			est store OLS2
			outreg2 using logs/output_iv_base, dec(4) nocons/*
				*/ word label addnote(Source: Card, proximity paper,) append ctitle(OLS2) /*
				*/ adds(R-squared, e(r2))
	
		reg lwage76 ed76 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed
			est store OLS3
			outreg2 using logs/output_iv_base, dec(4) nocons/*
				*/ word label addnote(Source: Card, proximity paper,) append ctitle(OLS3) /*
				*/ adds(R-squared, e(r2))
				
				test daded momed nodaded nomomed
	
		reg lwage76 ed76 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed
			est store OLS4
			outreg2 using logs/output_iv_base, dec(4) nocons/*
				*/ word label addnote(Source: Card, proximity paper,) append ctitle(OLS4) /*
				*/ adds(R-squared, e(r2))
				
				testparm daded momed nodaded nomomed i.famed
	
		reg lwage76 ed76 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed momdad14 sinmom14
			est store OLS5
			outreg2 using logs/output_iv_base, dec(4) nocons/*
				*/ word label addnote(Source: Card, proximity paper,) append ctitle(OLS5) /*
				*/ adds(R-squared, e(r2))
				
				testparm daded momed nodaded nomomed b1.famed momdad14 sinmom14
	
	estimates table OLS1 OLS2 OLS3 OLS4 OLS5, keep(ed76 exp76 exp762 black reg76r smsa76r) b(%7.3f) se(%7.3f) stats(N r2)
				
				keep if e(sample)
				sum

	// Table 3, reduced form and structural estimates of education and earnings models
	
		tab famed, ge(fe)
		gen age762 = age76^2
	
	// Panel A.
	reg ed76 nearc4 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r1
		
	reg ed76 nearc4 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed momdad14 sinmom14
		est store r2
		
	reg lwage76 nearc4 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r3
		
	reg lwage76 nearc4 exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed momdad14 sinmom14
		est store r4
	
	ivreg2 lwage76 (ed76 = nearc4) exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r5
		
	ivreg2 lwage76 (ed76 = nearc4) exp76 exp762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed fe2 fe3 fe4 fe5 fe6 fe7 fe8 fe9 momdad14 sinmom14
		est store r6
		
		estimates table r1 r2 r3 r4 r5 r6, keep(nearc4 ed76) b(%7.3f) se(%7.3f) stats(N r2)

	// Panel B.
	reg ed76 nearc4 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r1
		
	reg ed76 nearc4 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed momdad14 sinmom14
		est store r2
		
	reg lwage76 nearc4 age76 age762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r3
		
	reg lwage76 nearc4 age76 age762 black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed b1.famed momdad14 sinmom14
		est store r4
	
	ivreg2 lwage76 (ed76 exp76 exp762 = nearc4 age76 age762) black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r
		est store r5
		
	ivreg2 lwage76 (ed76 exp76 exp762 = nearc4 age76 age762) black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed fe2 fe3 fe4 fe5 fe6 fe7 fe8 fe9 momdad14 sinmom14
		est store r6
				
		estimates table r1 r2 r3 r4 r5 r6, keep(nearc4 ed76) b(%7.3f) se(%7.3f) stats(N r2)

	
	ivreg2 lwage76 (ed76 exp76 exp762 = nearc4 age76 age762) black reg76r smsa76r reg661 reg662 reg663 reg664 reg665 reg666 reg667 reg668 smsa66r daded momed nodaded nomomed fe2 fe3 fe4 fe5 fe6 fe7 fe8 fe9 momdad14 sinmom14, first robust


log close
