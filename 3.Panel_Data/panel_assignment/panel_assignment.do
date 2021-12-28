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
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/panel_assignment/logs"

capture log close
log using panel_assignment.txt, text replace

// ########################################################################### //


// # 0. prepare the data

use ../data/growth_data, clear	
	keep country year isocode rgdpwok education ki kg kc openk

	gen logrgdpwok=log(rgdpwok)
	
	// as country is a string variable we need to generate a numeric variable based on it
	// the solution is to use the command 'encode'
	// it creates a new variable, ccode, which is numeric and has the labels of country on it
	encode country, gen(ccode)
	
	// xtset & tsset perform an identical task
	tsset ccode year
	xtset ccode year, delta(5)	// our data is on a 5 year interval, so we have to specify the delta

	save ../data/data, replace	// save the data as we are going to use it several times in the following tasks


// ########################################################################### //


// # 1. describe the data
	xtdes	// describe the panel data
	sum		// summarize the panel data


// ########################################################################### //


// # 2. produce word and latex tables after tab and list

	use ../data/growth_data, clear
	
		preserve
		keep rgdpwok openk ki /*lnk education*/
		format %12.3f rgdpwok openk ki /*lnk education*/

			outreg2 using sum.doc, sum(detail) word eqkeep(N mean p50 sd min max) replace
		restore

	recode education min/2 = 2 2.0001/4 = 4 4.0001/6 = 6 6.0001/9=9 9.0001/12=12 12.0001/max=16
	format %2.0f education
	drop if education < 10
	replace country = proper(country)

	// ssc install tabout
	
	tabout country educ using country_educ.txt, cells(freq col cum) format(0 1) clab(No. Col_% Cum_%) replace


// ########################################################################### //


// # 3. test for heteroskedasticity & serial correlation

// HETEROSKEDASTICITY

// assuming pooled data
	use ../data/data, clear
		reg logrgdpwok education ki kg kc openk
		estat hettest
		estat imtest, white
	
	// we reject homoskedasticity

// assuming panel data

	// test for heteroskedasticity & correlation
	// optimal solution proposed by Greene, Econometric Analysis

	use ../data/data, clear
	capture net install xttest3.pkg, replace
	xtreg logrgdpwok education ki kg kc openk, fe
		xttest3

// test for serial correlation

	use ../data/data, clear
	capture net install xtserial.pkg
	xtserial logrgdpwok education ki kg kc openk
		
// since we rejected homoskedasticity & no serial correlation, one should use the option cluster() in our regressions		


// ########################################################################### //


// # 4. REGRESSIONS
	use ../data/data, clear
	xtset ccode year, delta(5)	// our data is on a 5 year interval, so we have to specify the delta
	

// # 4.a OLS

		label var logrgdpwok "Ln Real GDP per Worker"
		label var education "Av Education (years)"
		label var ki "Investment Share of PPP"
		label var kg "Government Consumption Share of PPP"
		label var kc "Consumption Share of PPP"
		label var openk "Degree of Openness"

	reg logrgdpwok education ki kg kc openk, cluster(ccode)
	est store OLS
	
	// will be used for the test of fixed-effects
	ereturn list
	scalar r2lsdv=e(r2)
	scalar mflsdv=e(df_m)
	scalar dflsdv=e(df_r)
	
		// TEST FOR RANDOM EFFECTS (Breush & Pagan, 1980)
			predict res, resid
			gen res2=res^2
			egen mres=mean(res),by(ccode)
			egen nobsT=count(ccode),by(ccode)
			bysort ccode (year): gen Tmres2=(nobsT*mres)^2 if _n==1
			egen sTmres2=total(Tmres2)
			egen sres2=total(res2)
			count if i[_n]~=i[_n-1]
			gen n=r(N)
			di "LM = " ((n*nobsT)/(2*(nobsT-1)))*((sTmres2/sres2-1)^2)
			scalar LM = ((n*nobsT)/(2*(nobsT-1)))*((sTmres2/sres2-1)^2)
		// COMPUTE THE p-value FOR THE TEST
			di chi2tail(1,LM)

	outreg2 using mainregs, dec(4) sortvar(education ki kg kc openk) keep(education ki kg kc openk) nocons/*
		*/ word label addnote(Source: Own computations, 2015.) replace ctitle(OLS) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))


// # 4.b LSDV

	reg logrgdpwok education ki kg kc openk i.ccode, cluster(ccode)
	est store LSDV
	testparm i.ccode
	
	// by rejecting the null hypothesis that country dummies are jointly equal to zero we conclude in favour of the specific effects model
	
	ereturn list
	scalar r2pooled=e(r2)
	scalar mfpooled=e(df_m)

		di "Test for the presence of fixed effects; F statistic:   " ((r2lsdv-r2pooled)/(mflsdv-mfpooled))/((1-r2lsdv)/(dflsdv))
		scalar fstatistic=((r2lsdv-r2pooled)/(mflsdv-mfpooled))/((1-r2lsdv)/(dflsdv))
		di "Test for the presence of fixed effects; p-valor:   " Ftail(mflsdv-mfpooled,dflsdv,fstatistic)
	
	outreg2 using mainregs, dec(4) sortvar(education ki kg kc openk) keep(education ki kg kc openk) nocons/*
		*/	word label addnote(ourse: Own computations, 2015.) append ctitle(LSDV) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

	// produce different output tables combining 2 or more regressions
	// look for the example on how to output the results using outreg2
	
	estimates table OLS LSDV, keep(education ki kg kc openk) b(%7.4f) se(%7.4f) stats(N r2_a)
	estimates table OLS LSDV, keep(education ki kg kc openk) b(%7.4f) star stats(N r2_a)


// # 4.c LSDV with time dummies

	reg logrgdpwok education ki kg kc openk i.ccode i.year, cluster(ccode)
	est store LSDVtime
	testparm i.year		// by rejecting the null hypothesis we conclude that there are time specificities
	
	outreg2 using mainregs, dec(4) sortvar(education ki kg kc openk) keep(education ki kg kc openk) nocons/*
		*/ word label addnote(ourse: Own computations, 2015.) append ctitle(LSDV,Time) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))


// # 4.d FE with time dummies

	xtreg logrgdpwok education ki kg kc openk i.year, fe
	est store FEnorobust
	// see the line under the output table for the specific effects test

	xtreg logrgdpwok education ki kg kc openk i.year, fe cluster(ccode)
	est store FE
	
	outreg2 using mainregs, dec(4) sortvar(education ki kg kc openk) keep(education ki kg kc openk) nocons/*
		*/ word label addnote(ourse: Own computations, 2015.) append ctitle(FE,Time) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))


// # 4.e RE with time dummies

	xtreg logrgdpwok education ki kg kc openk i.year, re
	est store REnorobust
	
	xtreg logrgdpwok education ki kg kc openk i.year, re cluster(ccode)
	est store RE
	xtreg logrgdpwok education ki kg kc openk i.year, re cluster(ccode)
	est store RE
	
	outreg2 using mainregs, dec(4) sortvar(education ki kg kc openk) keep(education ki kg kc openk) nocons/*
		*/ word label addnote(ourse: Own computations, 2015.) append ctitle(RE,Time) /*
		*/ adds(RMSE, e(rmse))


// # 4.e BE

	xtreg logrgdpwok education ki kg kc openk i.year, be
	est store BE
	
	// test the validity of the RE estimator
	// the null hypothesis implies that the RE is not rejected
	// in the hausman command you first wright the consistent model, FE, and latter the efficient, lower variance, model, RE
	
	hausman FEnorobust REnorobust

	estimates table OLS LSDV LSDVtime FE RE BE, keep(education ki kg kc openk) b(%7.4f) se(%7.4f) stats(N r2_a)
	estimates table OLS LSDV LSDVtime FE RE BE, keep(education ki kg kc openk) b(%7.4f) star stats(N r2_a)


// ########################################################################### //


// # 5. hypothesis testing

	est replay FE
	
//	use data, clear
//	xtreg logrgdpwok education ki kg kc openk i.year, fe cluster(ccode)
	
		test education
		test kg=kc
		test ki kg kc
		testparm k*			// it gives the same results as in the previous line, but you may use the wildcard, *
		testparm kc-ki		// a different form of writing the test, be haware of the order of the variables in the data
							// describe the data before you type 'kc-ki'
timer off 1
timer list 1

log close
