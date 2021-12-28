//////////////////////////////////////////////
// M Portela - Thesis: empirical analysis	//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
//////////////////////////////////////////////

clear all
set more off
set rmsg on
	
	timer on 1
	
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/6.clean/logs"

capture log close
log using thesis_mportela_v1.txt, text replace

// # 1. Data
webuse nlswork, clear
	gen wage = exp(ln_wage)
	compress
	sort idcode year
	xtset idcode year
	
		save ../data/nlswork_local, replace

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
	
	esttab, cells("mean(fmt(1)) sd(fmt(3)) min(fmt(2)) max(fmt(1))") nomtitle nonumber label

	esttab using ../_text/tables/descriptives_table1.rtf, replace cells("mean(fmt(2)) sd(fmt(3)) min(fmt(2)) max(fmt(1))") nomtitle nonumber label
	
	twoway (kdensity ln_wage if union == 0) (kdensity ln_wage if union == 1),scheme(economist) graphregion(color(white)) legend(region(color(white))) legend(order(1 "Non-Union" 2 "Union")) ytitle("Density") xtitle("Wage (log)")
	
	graph export ../_text/figures/fig_wage_density_union.pdf, replace

// 3. Regression analysis

reg ln_wage ttl_exp union i.year
	est store ols

xtreg ln_wage ttl_exp union i.year, fe
	est store fe

	esttab ols fe using ../_text/tables/regression_table1.rtf, replace ///
		drop(*.year _cons) ///
		b(%6.3f) se(%6.3f)  sfmt(%5.2f) star(* 0.1 ** 0.05 *** 0.01) ///
		mlabel("OLS" "FE") nonumbers ///
		scalars("N Observations" "N_g Firms" "r2_w R-sq-within" "r2_b R-sq-between" "rho Rho" "corr corr(u_i,Xb)") label ///
		nonotes addnotes("Notes: robust standard errors in parenthesis (clustered at the sector level)." "Significance levels: *, 10 \%; **, 5 \%; ***, 1 \%." "All regressions include a constant and time dummies.") title("Regression analysis -- Wages (logs)\label{tb:regresults}")

// <<>> --- <<>>

timer off 1
timer list 1
				
log close
