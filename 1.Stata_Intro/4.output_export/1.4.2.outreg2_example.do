//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
	set more off											// ALLOW SCREENS TO PASS BY
	set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND
	
	timer on 1
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export"

// EXAMPLE ON IMPORTING TAB DELIMITED DATA

capture log close
log using logs/outreg2_example.txt, text replace

	use data/tablef7_1, clear

gen lncost=ln(c)
gen lnoutput=ln(q)
gen lnoutput2=lnoutput^2
gen lnfuelprice=ln(pf)

	label var lnoutput "Output"
	label var lnfuelprice "Fuel Price"
	label var lf "Load Factor"

// OLS
reg lncost lnoutput lnfuelprice lf
	est store OLS
	outreg2 using logs/mainregs, dec(4) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf) keep(lnoutput lnfuelprice lf) nocons/*
		*/	word label addnote(Source: Own computations; Greene, 2008) replace ctitle(OLS) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

// LSDV
reg lncost lnoutput lnfuelprice lf i.i
	est store LSDV
	outreg2 using logs/mainregs, dec(4) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
		*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(LSDV) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

// FIXED-EFFECTS
xtset i t
xtreg lncost lnoutput lnfuelprice lf, fe
	est store FE
	outreg2 using logs/mainregs, dec(4) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
		*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(FE) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll), F test that all u_i=0, e(F_f))

// BETWEEN-GROUPS ESTIMATOR
xtreg lncost lnoutput lnfuelprice lf, be
	est store BE
	outreg2 using logs/mainregs, dec(4) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
		*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(BE) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

// INTRODUCE TIME EFFECTS
xtreg lncost lnoutput lnfuelprice lf i.t, i(i) fe
	est store FE_time
	outreg2 using logs/mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
		*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(FE_time) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll), F test that all u_i=0, e(F_f))

// RANDOM EFFECTS ESTIMATOR
xtreg lncost lnoutput lnfuelprice lf, re
	est store RE
	outreg2 using logs/mainregs, dec(6) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
		*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(RE) /*
		*/ adds(RMSE, e(rmse), rho, e(rho))
		
		// SEE OUTPUT TABLE: click on the link 'mainregs.rtf' in the output window
		// help outreg2; explore further the command

// ALTERNATIVE IMPLEMENTATION OF 'outreg2' & EXPLORATION OF 'estimates'
	
	// help outreg2
	// help estimates
	
	estimates dir
	estimates query
	estimates describe
	
	estimates restore OLS
	estimates query
	estimates describe
	
	estimates replay FE
	estimates query

	estimates table LSDV FE

	estimates stats LSDV FE
	
	estimates table OLS LSDV FE BE FE_time RE, keep(lnoutput lnfuelprice lf) b(%7.4f) se(%7.4f) stats(N r2_a)
	estimates table OLS LSDV FE BE FE_time RE, keep(lnoutput lnfuelprice lf) b(%7.4f) star stats(N r2_a)
	
	// EXPORT THE OUTPUT

	// WORD output file

	outreg2 [OLS LSDV FE BE FE_time RE] using logs/mainregs_alternative, replace dec(3) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf) /*
		*/ keep(lnoutput lnfuelprice lf) nocons /*
		*/ word label addnote(Source: Own computations; Greene, 2008)

	// EXCEL output file

	outreg2 [OLS LSDV FE BE FE_time RE] using logs/mainregs_alternative, replace dec(3) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf) /*
		*/ keep(lnoutput lnfuelprice lf) nocons /*
		*/ excel label addnote(Source: Own computations; Greene, 2008)
	
	// LATEX output file

	outreg2 [OLS LSDV FE BE FE_time RE] using logs/mainregs_alternative, replace dec(3) alpha(0.001, 0.01, 0.05) sortvar(lnoutput lnfuelprice lf) /*
		*/ keep(lnoutput lnfuelprice lf) nocons /*
		*/ tex label addnote(Source: Own computations; Greene, 2008)

timer off 1
timer list 1
				
log close
