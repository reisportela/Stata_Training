//////////////////////////////
// Applied Econometrics		//
// Universidade do Minho	//
// October, 2021			//
// Miguel Portela			//
//////////////////////////////

// STATIC PANEL DATA: detail

	clear all
	set more off
	set matsize 800
	set rmsg on
	
	timer on 1
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/logs"


capture log close
log using hdfe.txt, replace

/*

CHECK:

	https://github.com/sergiocorreia/reghdfe

* Install ftools (remove program if it existed previously)

	cap ado uninstall ftools
	net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe 5.x

	cap ado uninstall reghdfe
	net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") replace

* Install boottest for Stata 11 and 12

	if (c(version)<13) cap ado uninstall boottest
	if (c(version)<13) ssc install boottest

* Install moremata (sometimes used by ftools but not needed for reghdfe)

	cap ssc install moremata

	ftools, compile
	reghdfe, compile
	
*To run IV/GMM regressions with ivreghdfe, also run these lines:

	cap ado uninstall ivreg2hdfe
	cap ado uninstall ivreghdfe
	cap ssc install ivreg2 // Install ivreg2, the core package
	net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

*/

// B. Sérgio Correia's example

	// Two and three sets of fixed effects
		
			/*
			webuse nlswork, clear
				save ../data/nlswork, replace
			*/

			use ../data/nlswork, clear
			
			reghdfe ln_w age ttl_exp tenure not_smsa south , absorb(idcode year)
			reghdfe ln_w age ttl_exp tenure not_smsa south , absorb(idcode year occ)

		// Save the FEs as variables
        
			reghdfe ln_w age ttl_exp tenure not_smsa south , absorb(FE1=idcode FE2=year)

		// Save first mobility group
		
			reghdfe ln_w age ttl_exp tenure not_smsa , absorb(idcode year) groupv(mobility_occ)

		// Factor interactions in the independent variables
		
			reghdfe ln_w i.grade#i.age ttl_exp tenure not_smsa , absorb(idcode year)

		//Interactions in the absorbed variables (notice that only the # symbol is allowed)
		
			reghdfe ln_w age ttl_exp tenure not_smsa , absorb(idcode#occ)


			
// B. EXAMPLE WITH FAKEDATA

		use ../data/fakedata, clear
			
			sum
			list

	* Regression with one fixed effect (i)
	* Fixed effects panel on i

	* Three alternative ways to produce the same results
	 
		regress y x1 x2 i.i
			areg y x1 x2, absorb(i)
			xtset i
			xtreg y x1 x2, fe

	* Models with two fixed effects

	* Spell fixed effects

		egen spell=group(i j)
		areg y x1 x2, absorb(spell)

	* Fixed effects on i and j

	* Alternative ways to estimate

		regress y x1 x2 i.i i.j
		xtreg y x1 x2 i.j, fe
		xtset j
		xtreg y x1 x2 i.i, fe
		areg y x1 x2 i.i, absorb(j)
		areg y x1 x2 i.j, absorb(i)

	* Above approaches are not feasible with a large number of fes 

	* Using iterative procedure

		reghdfe y x1 x2, absorb(i j)

	* Storing the fixed effects

		reghdfe y x1 x2, absorb(ei=i ej=j)

	* Identifying the connected sets
		// ssc install group2hdfe
		group2hdfe i j, group(g)

	* Identifying the largest connected set

		group2hdfe i j, largest(big)

	* A model with 3 fes

		reghdfe y x1 x2, absorb(i j t)
		reghdfe y x1 x2 i.t, absorb(i j)

	* Another way to do the spell model

		reghdfe y x1 x2, absorb(i##j)

log close
