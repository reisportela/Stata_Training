//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
	set more off											// ALLOW SCREENS TO PASS BY
	set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND
	
	set matsize 800					// set the maximum number of variables in a model
	
	timer on 1
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\3.dataanalysis"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\3.dataanalysis"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/3.dataanalysis"

// EXAMPLE ON IMPORTING TAB DELIMITED DATA

capture log close
log using logs/dataanalysis.txt, text replace


// ########################################################################### //


// # 0. INTERNET: useful commands for the following analysis


		/*
				// packages: 	ascii charlist unique outreg2 est2tex abar listtab listtex elapse sample2 cf2 cf3
				//				outtable latab tabout sutex xtabond2 ivreg2 ranktest
				
				help whatsnew
				ado
				update query
				set timeout1 10000
				set timeout2 10000
				update all
				adoupdate, all update
				
				net search panel data
				findit xtabond2
				ssc install xtabond2							// Boston College Statistical Software Components  (SSC)
				net install xtabond2.pkg
				adoupdate xtabond2, update
				
		*/


// ########################################################################### //


// # 1. MATRICES

use ../2.handlingdata/growth/growth_data, clear
		
	// matrices manipulation

		preserve			// preserve the data in its current state
		
		// NOTE: for regressions we use `ereturn list'; for other computations we use 'return list'
			reg lngdp education i.year			// estimate a simple OLS regression
				ereturn list					// identify where the regression computations are stored

				matrix list e(b)
				mat li e(V)
				mat vars = e(V)
					scalar s = vars[2,2]
					di s
					
					mat example = (1,2\3,4)
					matrix list example
		
				
				tab year if e(sample)			// tabulate the variable 'year' but just for the sample used in the regression
					return list					// identify the number of periods
			
				mat betas = e(b)'				// build a matrix with the estimated betas
					matrix list betas
				mat dummies = betas[3..10,1]	// build a matrix with the dummies
					mat l dummies
				svmat dummies, n(dummies)		// transform the matrix in data
					gen yyyy = _n if _n <= 8	// build a time variable
				
				keep dummies yyyy
				drop if dummies == .
				
				// graph the dummies over time
					twoway (scatter dummies yyyy) || (line dummies yyyy)
		
		restore


	// OLS coefficients estimation step by step using matrices

		preserve
			
			egen nmiss = rmiss(lngdp education)
			drop if nmiss ~= 0

			keep in 1/25

			mat drop _all
			mkmat lngdp, mat(y)
			mkmat education, mat(x)
			matrix dir

			gen one=1
			mkmat one, mat(one)
			mat x=one,x
			mat l x

			mat def beta=((inv((x')*x)))*((x')*y)
			mat l beta

			reg lngdp education			// compare with the results above

		restore



// ########################################################################### //


// # 2. VARIABLES & DESCRIPTIVE STATISTICSS

	use ../2.handlingdata/growth/growth_data, clear	// load the data from the harddrive

		describe
		codebook, compact
		
		mean education
		proportion year
		
		// local & global macros
		
		local vars = "education k"
			sum `vars'

		global vars = "education k"
			sum $vars

		// evaluate if mean education is the same across high and low income countries
		
		preserve
		keep if year == 2000						// keep only observations for year 2000
		sum lngdp, detail
			gen gdp_high = (lngdp > r(p50))			// generate a dummy variable, where '1' implies satisfying the logical condition
			tab gdp_high
			ttest education, by(gdp_high)			// t tests (mean-comparison tests)
		restore

		
		sum education, detail						// use the option detail == produces additional statistics
			return list
			di r(p95)
			
			gen diff = education - r(mean)			// using 'return list' we learn that the mean of education is stored under 'r(mean)'
			sum diff, detail
			tab country year if diff > 0 & diff != .				// != equals ~=
				ret li
				drop diff					// drop the variable
				
		count if education > 9 & year == 2000
		
			table year
			tabulate year
				
				tab country if educ > 11 & year == 2000
				tab country if education ~= .
				tab country if education != .
				tab country if education == .
		
		tabstat education,by(country) stat(mean min max)			// explore further the command tabstat: type 'help tabstat'
		bysort country: sum education, detail
		
		inspect education
			sum education
			sum education, detail
			format %3.1f education
			sum education if year == 2000, format
			bysort country: sum education
		
		tab country, sum(educ)		
		tab educ
		tab educ, miss
		
	// IDENTIFY THE SEQUENCE OF OBSERVATIONS

		gen n = _n
		gen N = _N
		l n N in 1/20

		bysort country (year): gen educ_first = education[1]		// within country, sort year, and generate a variable that equals
																	// its level of education in the first observed period
		bysort country (year): gen educ_last = education[_N]		// the same, but for the last period
		
		fl country year education educ_first educ_last in 1/15		// list the first 15 observations
		
		egen double cty_id = group(country)							// WHY DO WE USE DOUBLE?
		
		xtset cty_id year, delta(5)									// declare data to be panel data; the time variation between observations is 5 years
		
		gen deduc	= d.education									// generate first-differences of education with countries
		gen lageduc	= l.education									// generate lag of education with countries
		
		// collect statistics for a command across a by list
		statsby _b _se dfr=e(df_r), by(country) saving(logs/tmp, replace): regress lngdp education
		
		preserve
			use logs/tmp, clear
				l in 1/15
				sum _b_education if _eq2_dfr > 5, detail
				sh del tmp.dta										// delete the temporary file from the folder
		restore

		clonevar educ = education
		
		recode educ min/2 = 1 2.0001/4 = 2 4.0001/6 = 3 6.0001 /8 = 4 8.001/10 = 5 10.0001/max = 6
			tab educ

		xtile inc_10 = rgdpwok, nq(10)
			tab inc_10 educ
			tab inc_10 educ, col row
		
		describe inc_*
		
		tabulate inc_10 educ
		tab1 inc_10 educ
		tab inc_10 educ, row col
		format %3.1f openk
		tab inc_10 educ, sum(openk) nost nofreq
		
		xtile open = openk,nq(2)
		histogram educ, discrete gap(10) xlabel(1(1)6, valuelabel) by(open)
		
		gen educ2 = (education > 9)
			replace educ2 = . if education == .
			tab educ2
		
		gen educ3 = recode(education,2,4,6,9,12)
			tab educ3
			bysort educ3: sum education
		
		sum openk, detail
		gen openk2 = autocode(openk,6,13,160)
			tab openk2
			
		table openk2, contents(count education mean education mean rgdpwok sd education)

timer off 1
timer list 1
				
log close
