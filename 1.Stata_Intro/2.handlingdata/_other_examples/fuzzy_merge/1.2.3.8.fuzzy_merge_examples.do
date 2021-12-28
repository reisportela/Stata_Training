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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata\_other_examples\fuzzy_merge"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata\_other_examples\fuzzy_merge"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata/_other_examples/fuzzy_merge"

// FUZZY MERGE EXERCISE # 2.: 'reclink'	== 	this a solution that appeared before 'matchit'; its use is more complex

	// ssc install jarowinkler
	// ssc install strdist
	// ssc install strgroup
	
capture log close
log using logs/fuzzy_merge_examples.txt, text replace

// # 1. 'prepare the data for the example'

use country using data/pwt70, clear
	bysort country: keep if _n == 1
	ren country countrya
	unique countrya
	save tmp_files/countrya, replace

use country using data/data_educ, clear
	bysort country: keep if _n == 1
	ren country countryb
	unique countryb
	save tmp_files/countryb, replace
	
use tmp_files/countrya, clear
	cross using tmp_files/countryb

// # 2. 'jarowinkler'
ssc install jarowinkler

	cd tmp_files

	jarowinkler countrya countryb,gen(strdist1)
	
	gsort countrya -strdist1
	gen strdist1a = 1 - strdist1
	bysort countrya (strdist1a): keep if _n <= 5
	
	drop strdist1a
	fl if countrya == "antigua and barbuda"
	fl if countrya == "central african republic"
	
// # 3. 'strdist'
capture ssc install strdist
	strdist countrya countryb,gen(strdist2)

	fl if countrya == "antigua and barbuda"
	fl if countrya == "central african republic"

// # 4. 'soundex'

	gen soundex1 = soundex(countrya)
	gen soundex2 = soundex(countryb)

	export excel using country_check_a.xlsx, firstrow(variables) replace

// # 5. 'strgroup'
ssc install strgroup, replace
use countrya, clear
	ren country countryb
	merge 1:1 countryb using countryb
	
	// "file strgroup.plugin not found"
	// https://ideas.repec.org/c/boc/bocode/s457151.html
	// rename the correct 'plugin' to strgroup.plugin
	
	strgroup countryb if _merge!=3, gen(group) threshold(0.25)
		drop _merge

	sort group
	
	export excel using country_check_strgroup.xlsx, firstrow(variables) replace

// # 6. 'reclink'

	// see file '1.2.3.6.reclink.do'

// # 7. 'matchit'

	// see file '1.2.3.7.matchit.do'


// # 8. outside commands

	// # 2.1
		
		// 'openrefine'
		// http://openrefine.org/
		
	// # 2.2

		// 'MergeToolBox' == German Record Linkage Center (GermanRLC)
		// http://www.record-linkage.de/-Home.htm

timer off 1
timer list 1
				
log close
