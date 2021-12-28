//////////////////////////////////////////////////////////////////////////
// 2018 STATA ECONOMETRICS WINTER SCHOOL								//
// January 22-26, 2018													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

// ivreg2, exercise: Christopher Baum

clear all
set more off
set rmsg on

capture cd "/Users/miguelportela/Dropbox/statafep2018/day2/2.Causal_analysis/2.3.iv"
capture cd "C:\fep2018\day2\2.Causal_analysis\2.3.iv" // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2018\day2\2.Causal_analysis\2.3.iv" // MOVE TO YOUR WORKING FOLDER

capture log close
log using logs/iv_exercise.txt, text replace

// IVREG2

// The following discussion follows the help file of the command 'ivreg2'

		// ivreg2, ivregress, ivreg, newey
		// overid, ivendog, ivhettest, ivreset, xtivreg2, xtoverid, ranktest, condivreg
		// rivtest, cgmreg
		// xtscc

		// ssc install xtoverid
		// net install st0033_2.pkg
		// net install st0171_1.pkg
		// 'cgmreg': available here: http://www.econ.ucdavis.edu/faculty/dlmiller/statafiles/
		// ssc install xtscc

// Data: Griliches, Zvi (1976), "Wages of Very Young Men", The Journal of Political Economy,
// Vol. 84, No. 4, Part 2: Essays in Labor Economics in Honor of
// H. Gregg Lewis. (Aug., 1976), pp. S69-S86

capture use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta, clear
	note: "Wages of Very Young Men, Zvi Griliches, J.Pol.Ec. 1976; downloaded june 2015"
	notes
	capture save data/griliches76, replace
	
capture use data/griliches76, clear

// the data

keep lw s expr tenure rns smsa year iq med kww age mrt
	describe
	sum
	inspect rns-lw
	codebook lw tenure s
	l s in 1/10
	tab s
	tab s smsa, row
	tab s smsa, sum(lw) means
	tabstat lw,by(s) stat(mean sd p10 p50 p90 p95)

// OLS model
xi i.year

reg lw s expr tenure rns smsa _I*
	est store OLS
		outreg2 using logs/iv_regressions, dec(4) alpha(0.001, 0.01, 0.05) /*
		*/ keep(iq s expr tenure rns smsa) sortvar(iq s expr tenure rns smsa) nocons/*
		*/ word label addnote(Source: Own computations; Griliches 1976's data.) /*
		*/ replace ctitle(OLS) adds(RMSE, e(rmse), LogLikelihood, e(ll))

// IV models
ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt)
	ereturn list

	est store IV1
	outreg2 using logs/iv_regressions, dec(4) alpha(0.001, 0.01, 0.05) /*
		*/ keep(iq s expr tenure rns smsa) sortvar(iq s expr tenure rns smsa) nocons/*
		*/ word label addnote(Source: Own computations; Griliches 1976's data.) /*
		*/ append ctitle(IV1) adds(RMSE, e(rmse), LogLikelihood, e(ll))
	
// endogeneity tests

	// Hausman test: validity of the OLS model
	
		hausman IV1 OLS, sigmaless
		
	// compare with the result below for 'ivendog'

		// equivalence of DWH endogeneity test when regressor is endogenous...
			ivendog

		// ...endogeneity test using the endog option
			ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt), endog(s)

		// ...and C-test of exogeneity when regressor is exogenous, using the orthog option
			ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt), orthog(iq)
			ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt), orthog(kww)
			ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt), orthog(iq kww)

			ivreg2 lw expr tenure rns smsa _I* (s = iq kww)

	// Sargan-Basmann tests of overidentifying restrictions for IV estimation
			ivreg2 lw expr tenure rns smsa _I* (s = iq kww)
				
				overid, all

	// Tests of exogeneity and endogeneity

		// Test the exogeneity of one regressor
			ivreg2 lw expr tenure rns smsa _I* (s = iq kww), gmm2s orthog(iq)

		// Test the exogeneity of two excluded instruments
			ivreg2 lw expr tenure rns smsa _I* (s = iq med kww age mrt), gmm2s orthog(age mrt)
			
			ivreg2 lw expr tenure rns smsa _I* (s = iq kww), gmm2s

// control the regression output
			
	// small: report small-sample statistics
	// first: display the full first-stage regression results
	// ffirst: display first-stage diagnostic and identification statistics

		ivreg2 lw expr tenure rns smsa _I* (s = iq kww), small ffirst first

	// usualy we just use the option ffirst
		
		ivreg2 lw expr tenure rns smsa _I* (s = iq kww), small ffirst

// testing for the presence of heteroskedasticity
		ivreg2 lw expr tenure rns smsa _I* (s = iq kww), small ffirst
			ivhettest, fitlev
	
		// we do not reject the null hypothesis of homoskedasticity
	
		// run file 'iv_heteroskedasticity.do' == extra discussion on heteroskedasticity == //
		// 'do iv_heteroskedasticity'

// two-step GMM efficient in the presence of arbitrary heteroskedasticity
		ivreg2 lw expr tenure rns smsa _I* (s = iq kww), gmm2s robust ffirst
			eret li
	
	est store GMM1
	outreg2 using logs/iv_regressions, dec(4) alpha(0.001, 0.01, 0.05) /*
		*/ keep(iq s expr tenure rns smsa) sortvar(iq s expr tenure rns smsa) nocons/*
		*/ word label addnote(Source: Own computations; Griliches 1976's data.) /*
		*/ append ctitle(GMM1) adds(RMSE, e(rmse), LogLikelihood, e(ll))

//////////////////////////////////////////////////////////////////////////////////////////////////////////

// GMM with user-specified first-step weighting matrix or matrix of orthogonality conditions)
		ivreg2 lw expr tenure rns smsa _I* (s = iq kww), robust

	predict double uhat if e(sample), resid

	mat accum S = `e(insts)' [iw=uhat^2]

	mat S = 1/`e(N)' * S

	ivreg2 lw expr tenure rns smsa _I* (s = iq kww), gmm2s robust smatrix(S)

	mat W = invsym(S)

	ivreg2 lw expr tenure rns smsa _I* (s = iq kww), gmm2s robust wmatrix(W)

	est store GMM2
	outreg2 using logs/iv_regressions, dec(4) alpha(0.001, 0.01, 0.05) /*
		*/ keep(iq s expr tenure rns smsa) sortvar(iq s expr tenure rns smsa) nocons/*
		*/ word label addnote(Source: Own computations; Griliches 1976's data.) /*
		*/ append ctitle(GMM2) adds(RMSE, e(rmse), LogLikelihood, e(ll))


// Equivalence of J statistic and Wald tests of included regressors,
// irrespective of instrument choice (Ahn, 1997)

ivreg2 lw (s = iq kww med age), gmm2s

	mat S0 = e(S)
	qui ivreg2 lw (s = kww) iq med age, gmm2s smatrix(S0)
	test iq med age
	qui ivreg2 lw (s = med) iq kww age, gmm2s smatrix(S0)
	test kww age
	qui ivreg2 lw (s = age) iq med kww, gmm2s smatrix(S0)
	test iq med kww

// Continuously-updated GMM (CUE) efficient in the presence of arbitrary
// heteroskedasticity NB: may require 30+ iterations.

ivreg2 lw expr tenure rns smsa _I* (s = iq kww), cue robust
	eret li
	est store CUE
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////

	outreg2 using logs/iv_regressions, dec(4) alpha(0.001, 0.01, 0.05) /*
		*/ keep(iq s expr tenure rns smsa) sortvar(iq s expr tenure rns smsa) nocons/*
		*/ word label addnote(Source: Own computations; Griliches 1976's data.) /*
		*/ append ctitle(CUE) adds(RMSE, e(rmse), LogLikelihood, e(ll))

log close
