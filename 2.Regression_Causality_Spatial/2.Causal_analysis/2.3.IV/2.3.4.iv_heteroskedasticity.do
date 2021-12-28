//////////////////////////////////////////////////////////////////////////
// 2018 STATA ECONOMETRICS WINTER SCHOOL								//
// January 22-26, 2018													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

// The following discussion follows the help file of the command 'ivreg2'

clear all
set more off
set rmsg on

capture cd "/Users/miguelportela/Dropbox/statafep2018/day2/2.Causal_analysis/2.3.iv"
capture cd "C:\fep2018\day2\2.Causal_analysis\2.3.iv" // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2018\day2\2.Causal_analysis\2.3.iv" // MOVE TO YOUR WORKING FOLDER

capture log close
log using logs/iv_heteroskedasticity.txt, text replace


// IVREG2

// Data: Griliches, Zvi (1976), "Wages of Very Young Men", The Journal of Political Economy,
// Vol. 84, No. 4, Part 2: Essays in Labor Economics in Honor of
// H. Gregg Lewis. (Aug., 1976), pp. S69-S86


use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta, clear
	note: "Wages of Very Young Men, Zvi Griliches, J.Pol.Ec. 1976; downloaded february 2015"
	notes
	
	save data/griliches76, replace
	
	use data/griliches76, clear
	
// the data

keep lw s expr tenure rns smsa year iq med kww age mrt
	xi i.year

	// == extra discussion on heteroskedasticity == //

		// Heteroskedastic Ordinary Least Squares, HOLS
			ivreg2 lw s expr tenure rns smsa _I* iq (=med kww age mrt), gmm2s

		// equivalence of Cragg-Donald Wald F statistic and F-test from first-stage regression
		// in special case of single endogenous regressor Also illustrates savefirst option.
			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), savefirst

			di e(widstat)
				estimates restore _ivreg2_iq
				test med kww age mrt
				di r(F)


		// equivalence of Kleibergen-Paap robust rk Wald F statistic and F-test from first-stage
		// regression in special case of single endogenous regressor.
			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust savefirst

			di e(widstat)
				estimates restore _ivreg2_iq
				test med kww age mrt
				di r(F)


		// equivalence of Kleibergen-Paap robust rk LM statistic for identification and LM test
		// of joint significance of excluded instruments in first-stage regression in special
		// case of single endogenous regressor Also illustrates use of ivreg2 to perform an
		// LM test in OLS estimation.

			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust
				di e(idstat)

			ivreg2 iq s expr tenure rns smsa _I* (=med kww age mrt) if e(sample), robust
				di e(j)

		// equivalence of an LM test of an excluded instrument for redundancy and an LM test of
		// significance from first-stage regression in special case of single endogenous regressor.

			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust redundant(med)
				di e(redstat)

			ivreg2 iq s expr tenure rns smsa _I* (=med) if e(sample), robust
				di e(j)

		// weak-instrument robust inference: Anderson-Rubin Wald F and chi-sq and
		// Stock-Wright S statistics Also illusrates use of saverf option.

			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust ffirst saverf
				di e(arf)
				di e(archi2)
				di e(sstat)

		// Obtaining the Anderson-Rubin Wald F statistic from the reduced-form estimation

			estimates restore _ivreg2_lw
			test med kww age mrt
			di r(F)

		// Obtaining the Anderson-Rubin Wald chi-sq statistic from the reduced-form estimation.
		// Use ivreg2 without small to obtain large-sample test statistic.
			
			ivreg2 lw s expr tenure rns smsa _I* med kww age mrt, robust
				test med kww age mrt
				di r(chi2)

		// Obtaining the Stock-Wright S statistic as the value of the GMM CUE objective function.
		// Also illustrates use of b0 option Coefficients on included exogenous regressors
		// are OLS coefficients, which is equivalent to partialling them out before obtaining
		// the value of the CUE objective function.

			mat b = 0
			mat colnames b = iq

			qui ivreg2 lw s expr tenure rns smsa _I* 
				mat b = b, e(b)

			ivreg2 lw s expr tenure rns smsa _I* (iq=med kww age mrt), robust b0(b)
				di e(j)

log close
