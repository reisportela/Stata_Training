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
	
		capture cd "C:\Users\mangelo\Documents\training\stata_training\day1\4.output_export"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export"

// EXAMPLE ON IMPORTING TAB DELIMITED DATA

capture log close
log using logs/output_export.txt, text replace

// # 1. produce word and latex tables after tab and list

	use data/growth_data, clear

	preserve
		keep rgdpwok pop openk ki /*lnk education*/
		format %12.3f rgdpwok pop openk ki /*lnk education*/

			outreg2 using logs/sum.doc, sum(detail) word eqkeep(N mean p50 sd min max) replace
	restore
	
	recode education min/2 = 2 2.0001/4 = 4 4.0001/6 = 6 6.0001/9=9 9.0001/12=12 12.0001/max=16
	format %2.0f education
	
	drop if education < 10
	
	replace country = proper(country)

	tabout country educ using logs/country_educ.txt, cells(freq col cum) format(0 1) clab(No. Col_% Cum_%) replace
	
// # 2. GRAPH EXPORT & LABEL

use data/growth_data, clear
	gen lnrgdpwok = ln(rgdpwok)
	gen lnrgdpl = ln(rgdpl)

	label var lnrgdpwok "Ln Real GDP per Worker"
	label var lnrgdpwok "Ln Real GDP per Capita"
	label var education "Average Years of Education"
	
	scatter lnrgdpwok educ if year == 2000, scheme(mono)
	scatter lnrgdpwok educ if year == 2000, scheme(economist)
	scatter lnrgdpwok educ if year == 2000, scheme(sj)
	
	gen cty = substr(country,1,3)
	scatter lnrgdpwok educ if year == 2000, scheme(mono) mlabel(cty)

	egen cty_id = group(country)
	scatter lnrgdpwok educ if year == 2000, scheme(mono) mlabel(cty_id)
	
	twoway kdensity lnrgdpl,legend(on label(1 "Ln GDP per capita")) || /*
	*/ kdensity lnrgdpwok,legend(on label(2 "Ln GDP per worker"))

	twoway scatter lnrgdpwok education || lfit lnrgdpwok education, title("GDP Data")
		graph export graphs/gdp_education.png, replace
	
log close

// # 3. LOGOUT

use data/growth_data, clear
	sum openk
		gen high_open = (openk > r(mean))
	
	logout, save(logs/education) excel replace: list education if country == "algeria", clean
	logout, save(logs/codebook) word replace: codebook, compact
	logout, save(logs/tabstat_year) excel word replace: 	tabstat education,by(year) stat(mean sd p75)
	logout, save(logs/tabulations_1) excel word replace: tab1 country year
	logout, save(logs/tabulations_2) excel replace: tab country year
	logout, save(logs/tab_sum) excel replace: tabulate year high_open,sum(education) nostandard nofreq

	
// # 4. OUTREG

capture log close
log using logs/output_export.txt, text append


// # 1. example A

use data/growth_data, clear

	reg lngdp education
		estimates store r1
	
	reg lngdp education lnk
		est store r2
		
	reg lngdp education lnk openk i.year
		est store r3

outreg, clear
	estimates restore r1
		outreg using logs/growth_analysis, replace rtitles("Education" \ "" \ "Capital" \ "" \ "Openness degree" \ "")  /*
				*/ drop(_cons) /*
				*/ ctitle("","Simple model") /*
				*/ nodisplay varlabels bdec(3) se starlevels(10 5 1) starloc(1) summstat(r2\rmse \ N) summtitle("R2"\"RMSE" \ "N")
	
	estimates restore r2
		outreg using logs/growth_analysis, merge rtitles("Education" \ "" \ "Capital" \ "" \ "Openness degree" \ "")  /*
				*/ drop(_cons) /*
				*/ ctitle("","Include capital") /*
				*/ varlabels bdec(3) se starlevels(10 5 1) starloc(1) summstat(r2\rmse \ N) summtitle("R2"\"RMSE" \ "N")
		
	estimates restore r3
		outreg using logs/growth_analysis, merge rtitles("Education" \ "" \ "Capital" \ "" \ "Openness degree" \ "")  /*
				*/ drop(_cons 1975.year 1980.year 1985.year 1990.year) /*
				*/ ctitle("","Full model") /*
				*/ nodisplay varlabels bdec(3) se starlevels(10 5 1) starloc(1) summstat(r2\rmse \ N) summtitle("R2"\"RMSE" \ "N")
				

// # 1. example B, 'margins'

sysuse auto, clear
	codebook, compact
	sum price

logit foreign mpg
	margins, dydx(*)

outreg using logs/margins_example, nodisplay replace marginal ctitle("","Model 1") bdec(4) se starlevels(10 5 1) starloc(1) rtitles("Miles p.g." \ "" \ "Car's weight" \ "")

logit foreign mpg weight
	margins, dydx(*)

outreg using logs/margins_example, nodisplay merge marginal ctitle("","Model 2") bdec(4) se starlevels(10 5 1) starloc(1) rtitles("Miles p.g." \ "" \ "Car's weight" \ "")

// -- ESTTAB

// # 1. Data
webuse nlswork, clear
	gen wage = exp(ln_wage)
	compress
	sort idcode year
	xtset idcode year
	save data/nlswork_local, replace

	codebook, compact

// 2. Statistics

label var age "Age (years)"
label var collgrad "Graduate"
label var union "Union"
label var ttl_exp "Experience (years)"
label var tenure "Tenure (years)"
label var hours "Working hours"
label var ln_wage "Wage (log)"

estpost sum age collgrad union ttl_exp tenure hours ln_wage if year == 88, listwise
	
	esttab, cells("mean(fmt(4)) sd(fmt(3)) min(fmt(2)) max(fmt(1))") nomtitle nonumber label

	esttab using _text/tables/descriptives_table1.tex, replace cells("mean(fmt(4)) sd(fmt(3)) min(fmt(2)) max(fmt(1))") nomtitle nonumber label
	
	twoway (kdensity ln_wage if union == 0) (kdensity ln_wage if union == 1),scheme(sj) graphregion(color(white)) legend(region(color(white))) legend(order(1 "Non-Union" 2 "Union")) ytitle("Density") xtitle("Wage (log)")
	
	graph export _text/figures/fig_wage_density_union.eps, replace

// 3. Regression analysis

reg ln_wage ttl_exp union i.year
	est store ols

xtreg ln_wage ttl_exp union i.year, fe
	est store fe

	esttab ols fe, ///
		drop(*.year _cons) ///
		b(%6.3f) se(%6.3f)  sfmt(%5.2f) star(* 0.1 ** 0.05 *** 0.01) ///
		mlabel("OLS" "FE") nonumbers ///
		scalars("N Observations" "N_g Firms" "r2_w R-sq-within" "r2_b R-sq-between" "rho Rho" "corr corr(u_i,Xb)") label ///
		nonotes addnotes("Notes: robust standard errors in parenthesis (clustered at the sector level)." "Significance levels: *, 10 %; **, 5 %; ***, 1 %." "All regressions include a constant and time dummies.") title("Regression analysis -- Wages (logs)")

	esttab ols fe using logs/regression_table1.rtf, replace ///
		drop(*.year _cons) ///
		b(%6.3f) se(%6.3f)  sfmt(%5.2f) star(* 0.1 ** 0.05 *** 0.01) ///
		mlabel("OLS" "FE") nonumbers ///
		scalars("N Observations" "N_g Firms" "r2_w R-sq-within" "r2_b R-sq-between" "rho Rho" "corr corr(u_i,Xb)") label ///
		nonotes addnotes("Notes: robust standard errors in parenthesis (clustered at the sector level)." "Significance levels: *, 10 %; **, 5 %; ***, 1 %." "All regressions include a constant and time dummies.") title("Regression analysis -- Wages (logs)")

	esttab ols fe using _text/tables/regression_table1.tex, replace ///
		drop(*.year _cons) ///
		b(%6.3f) se(%6.3f)  sfmt(%5.2f) star(* 0.1 ** 0.05 *** 0.01) ///
		mlabel("OLS" "FE") nonumbers ///
		scalars("N Observations" "N_g Firms" "r2_w R-sq-within" "r2_b R-sq-between" "rho Rho" "corr corr(u_i,Xb)") label ///
		nonotes addnotes("Notes: robust standard errors in parenthesis (clustered at the sector level)." "Significance levels: *, 10 \%; **, 5 \%; ***, 1 \%." "All regressions include a constant and time dummies.") title("Regression analysis -- Wages (logs)\label{tb:regresults}")

// <<>> --- <<>>

timer off 1
timer list 1
				
log close
