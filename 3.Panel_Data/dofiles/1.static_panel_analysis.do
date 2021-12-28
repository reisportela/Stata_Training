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
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/logs"

capture log close
log using panel_analysis_full_exercise.txt, text replace

// # 1. READ THE DATA AND DEFINE THE SAMPLE

		use ../data/growthdata, clear
			egen nobs = count(year),by(country)		// count the number of observations per country
			
			drop if nobs < 2		// drop countries where we have less than 2 observations; minimum size to run a panel data analysis
				drop nobs

			keep country year lngdp education lnk openk rgdpwok k pop kc kg ki

// # 2. IDENTIFY THE PANEL DIMENSION OF THE DATA
		replace country = proper(country)
		encode country, gen(cty_id)									// ALTERNATIVE TO: egen double cty_id = group(country)
			tab country
			unique cty_id
				return list
codebook, compact
		preserve
			
			keep if cty_id <= 10		// list a sample of countries
			label var cty_id "Countries"
			latab cty_id, tf(list_countries) replace		// Produce a tex table with the tabulation
		
		restore

		xtset cty_id year,delta(5)							// the command 'xtset' defines the panel dimension of the data; DISCUSS 'tsset'
	
	tsset cty_id year,delta(5)
	
		// these variables will be used later as instruments
		gen lag_educ = l1.education
		gen lag2_educ = l2.educ
		
			save data_tmp, replace
	
	egen nmiss = rowmiss(lngdp education lag_educ lag2_educ lnk openk)
		tab nmiss
			keep if nmiss == 0		// keep only the sample for which we have information on all variables used in the regressions below
				drop nmiss

// # 3. DESCRIBE THE DATA

		describe
		codebook, compact
		xtdes
		sum
		xtsum
		
		inspect education
		sum education

		preserve
			collapse (mean) mean_educ = education (count) education,by(country)
			sum mean_educ education if mean_educ ~= .
		restore

		xtsum education

				tabstat education,by(country)
				sum education, detail
					scalar median_educ = r(p50)

				// export descriptive statistics & graphs

					preserve
					set dp comma
						tab year
							sum year
							
						keep if year == r(max)
						
						keep rgdpwok education k openk lnk kc kg lngdp
						order rgdpwok education k openk lnk kc kg lngdp
						
						replace k = k/1000000000
						replace rgdpwok = rgdpwok/1000
						format %12.3f lngdp lnk kc kg openk
						format %12.2f rgdpwok k education
						
						outreg2 using ../paper_files/summary_statistics.doc, word dec(2) sum(detail) eqkeep(N mean p50 sd min max) replace
						outreg2 using ../paper_files/summary_statistics.tex, tex(frag) dec(3) sum(detail) eqkeep(N mean p10 p50 sd min max) replace
					set dp period
					restore

					preserve
						collapse (mean) mean_education = education mean_gdp = rgdpwok,by(year)
						gen ln_mean_gdp = ln(mean_gdp)
						
						label var mean_education "Average education"
						label var ln_mean_gdp "Ln Average GDP"
						
						sum year
						local mm = r(min)
						local jj = r(max)
						twoway (line mean_education year, yaxis(1)) || (line ln_mean_gdp year, yaxis(2) title("`mm' - `jj'")), scheme(sj)
							graph export ../paper_files/graphs/mean_education_gdp_year.png, replace
							graph export ../paper_files/graphs/mean_education_gdp_year.eps, replace
					restore

						sum year
						local mm = r(min)
						local jj = r(max)
					
					twoway kdensity lngdp if education <= median_educ,legend(on label(1 "Low education")) || kdensity lngdp if education > median_educ, /*
						*/ legend(on label(2 "High education")) title("`mm' - `jj'") scheme(s2mono) graphregion(color(white)) xtitle("Ln GDP") /*
						*/ ytitle("Density") legend(region(lcolor(white))) xlabel(5(2)13)
					
						graph export ../paper_files/graphs/lngdp_education.png, replace					
						graph export ../paper_files/graphs/lngdp_education.eps, replace

// # 4. OLS
	
	codebook year, compact

		reg lngdp education lnk openk b2000.year		// define 2000 as the base year
			testparm i.year								// evaluate the statistical significance of year dummy variables
												
		reg lngdp education lnk openk
			estimates store OLS
		
			estat hettest								// Breusch-Pagan / Cook-Weisberg test for heteroskedasticity
			estat hettest, iid
			estat imtest, white							// White's test for Ho: homoskedasticity
			estat ic
			
			estat vif									// information on possible collinearity
			
			// net install collin, from(https://stats.idre.ucla.edu/stat/stata/ado/analysis)
			collin education lnk
			
			//ssc install lmcol
			lmcol education lnk
			
			// ssc install fgtest
			fgtest education lnk

					// interpretation: we do not have a collinearity problem between education and lnk
				set seed 234
					// generate collinearity to learn the interpretation of the output
					gen educb = education + uniform()
					reg lngdp education educb lnk
						correlate education educb
						estat vif										// information on possible collinearity
						collin education lnk
						lmcol education lnk
						fgtest education educb
					
					drop educb
					
		reg lngdp education lnk openk
			regcheck													// examines regression assumptions

		reg lngdp education lnk openk, robust
		reg lngdp education lnk openk, cluster(cty_id)
			scalar beta_education_ols = _b[education]

// # 5. IV example
	
	tsset cty_id year,delta(5)
	
	// instruments defined above
	
		// gen lag_educ = l.education
		// gen lag2_educ = l2.educ
	
	ivreg2 lngdp (education = lag_educ lag2_educ) lnk openk
		est store IV
	
// # 6. First-Differences example
	
	reg d.lngdp d.education d.lnk d.openk
		est store FD
	
// # 7. FIXED EFFECTS ESTIMATOR
	
	xtset cty_id year

	xtreg lngdp education lnk openk, fe
		est store FE

		scalar beta_education_fe = _b[education]
		
		test education = beta_education_ols
		
		// COMPARE WITH THE 'LSDV' ESTIMATES
			
			reg lngdp education lnk openk i.cty_id
				est store LSDV
				
					est tab FE LSDV, se keep(education lnk openk)


// # 8. RANDOM EFFECTS ESTIMATOR

	xtreg lngdp education lnk openk, re
		est store RE

		// hypothesis testing

			xtreg lngdp education ki kg kc openk, fe
				test education
				test kg=kc
				test ki kg kc
				testparm k*		// it gives the same results as in the previous line, but you may use the wildcard, *
				testparm kc-ki	// a different form of writing the test, be haware of the order of the variables in the data
								// describe the data before you type 'kc-ki'

	// HAUSMAN test
	
		hausman FE RE

	// the Hausman test rejects the validity of the RE model
	

// # 9. RANDOM EFFECTS IV ESTIMATOR

	xtivreg lngdp (education = lag_educ lag2_educ) lnk openk, re
		est store RE_IV
		// ssc install xtoverid
			xtoverid


// # 10. EXPORT THE regression OUTPUT

	// # 10.1 SEE output within Stata

		estimates table OLS IV FD FE RE RE_IV, star(.1 .05 .01) keep(education lnk) stats(r2 ll N F) b(%5.3f) title(Growth regressions) ///
			stfmt(%6.3f)

		estimates table OLS IV FD FE RE RE_IV, keep(education lnk) stats(r2 ll N F) b(%5.4f) title(Growth regressions) ///
			se(%4.3f)

	// # 10.2 'esttab' ==> export the regression output to a .tex file

			esttab OLS IV FD FE RE RE_IV using ../paper_files/regression_analysis.tex, replace ///
				keep(education lnk openk) ///
				mtitle("Model (1)" "Model (2)" "Model (3)" "Model (4)" "Model (5)" "Model (6)") nonumbers ///
				coeflabel (education "Education" lnk "Log Capital" openk "Openness") ///
				b(%5.2f) se(%5.3f) star(* 0.1 ** 0.05 *** 0.01) ///
				scalars("N Observations" "ll Log likelihood" "r2 \$R^{2}\$" "F F statistic (overall)" "rmse Root MSE") ///
				aic t(3) ///
				nonotes addnotes("Notes: standard errors in parenthesis. Significance levels: *, 10\%;" "**, 5\%; ***, 1\%. The dependent variable is ln real GDP per workers." "Source: own computations.")


// ### SPECIFICATION TESTS FOR PANEL DATA ### //

// # 11. test for heteroskedasticity within panel data

	// optimal solution proposed by Greene, Econometric Analysis

		// net install xttest3.pkg, replace
		xtreg lngdp education lnk openk, fe
			xttest3
// ==>> start here
	// ALTERNATIVE
		
	// you will find here a discussion on tests for heteroskedasticity & autocorrelation

	// http://www.stata.com/support/faqs/statistics/panel-level-heteroskedasticity-and-autocorrelation/
	// this is how you implement it
	// one difficulty with this solution is that it may present difficulties in convergence
		
		xtgls lngdp education lnk openk, panels(heteroskedastic) igls tolerance(1e-5) iterate(75)
			estimates store hetero

		xtgls lngdp education lnk openk
		local df = e(N_g) - 1
		lrtest hetero . , df(`df')

	
	// I recommend the use of xttest3 


// # 12. test for cross-sectional correlation in fixed effects model
	
	// net install xttest2.pkg, replace
	xtreg lngdp education lnk openk, fe
			
		// the command will issue an error message as there are few
		// common observations across panel

				capture xttest2
			
					//run the command without capture to see the error message

// # 13. test for serial correlation within panel data & cross-sectional

	//net install st0039.pkg
	
	tsset cty_id year,delta(5)
	
	// test as discussed by Wooldridge (2002) and implemented by Drukker (2003)
	xtserial lngdp education lnk openk
	
	
	// ALTERNATIVE in Stata: set of specification tests for linear panel-data models
		
		preserve
			
			// build a balanced panel
			
			xtreg lngdp education lnk openk, re
				keep if e(sample)

			egen nobs = count(year),by(cty_id)
			tab nobs
				sum nobs
			keep if nobs == r(max)
			drop nobs
			
			xtreg lngdp education lnk openk, re
				// findit xttest1
				// net install sg164_1.pkg
				xttest1										
		
		restore
	
	// CONCLUSION: the above results lead us to conclude that we reject the base hypothesis
	// of the FE model that we have homoskedasticy & no serial correlation in the error term

	// the cluster-robust standard errors allow for heteroscedasticity and serial correlation
	// correct solution would be

	// you can also apply specification tests for error-component models	
	// this is only relevante in case the Hausman test does not reject the validity of the RE model
	

// # 14. FINAL MODEL
	
	xtreg lngdp education lnk openk i.year, fe cluster(cty_id)
		est store FE_cluster
			testparm i.yea
			test education

			tab year if e(sample)
			
		esttab OLS IV FE RE FE_cluster using ../paper_files/regression_analysis.tex, replace ///
			keep(education lnk openk) ///
			mtitle("OLS" "IV" "FE" "RE" "FE (cluster)") nonumbers ///
			coeflabel (education "Education" lnk "Log Capital" openk "Openness") ///
			b(%5.4f) se(%5.2f) star(* 0.1 ** 0.05 *** 0.01) ///
			scalars("N Observations" "ll Log likelihood" "r2 \$R^{2}\$" "F F statistic (overall)" "rmse Root MSE") ///
			aic t(3) ///
			nonotes addnotes("Notes: standard errors in parenthesis. Significance levels: *, 10\%;" "**, 5\%; ***, 1\%. The dependent variable is ln real GDP per workers." "Source: own computations.")
			
timer off 1
timer list

log close
