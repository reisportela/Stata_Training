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

capture log close
log using logs/reclink.txt, text replace	//build the log file

// MERGE INCOME DATA WITH EDUCATION DATA
use data/pwt70, clear	// upload to the memory the gdp data, pwt70.dta

	merge 1:1 country year using data/data_educ	// the variables country & year are used to link/merge the two datasets
	
	// identify the countries in each merge category
	// keep in mind that many countries only appear in some years
	
	tab country if _merge == 3
		ret li
	tab country if _merge == 1
		ret li
	tab country if _merge == 2
		ret li

	preserve
		keep if _merge == 3
		keep country year
		bysort country (year): keep if _n == 1	// you just need one observation per country; we are keeping the first observations
		drop year
		
		// the (year) means that I am sorting observations by year within country but we just apply the 'bysort' to country
		// if you do bysort country year you will have just 1 observation per combination of country and year
		// using bysort country (year) you have as many observations per country as the number of years
		
		sort country
		saveold tmp_files/country3, replace	// saveold means you are saving the data file in a previous version of Stata, in this case Stata 12
	restore
	
	preserve
		keep if _merge == 1
		keep country
		bysort country: keep if _n == 1
		sort country
		saveold tmp_files/country1, replace
	restore

	preserve
		keep if _merge == 2
		keep country
		bysort country: keep if _n == 1
		sort country
		saveold tmp_files/country2, replace
	restore

	use tmp_files/country1, clear
	merge 1:1 country using tmp_files/country3
		keep if _merge == 1
		drop _merge
		ren country country1
		sort country1
		saveold tmp_files/country1_miss, replace

	use tmp_files/country2, clear
	merge 1:1 country using tmp_files/country3
		keep if _merge == 1
		drop _merge
		ren country country2
		sort country2
		saveold tmp_files/country2_miss, replace


//////////////////////////////////////////////

	
	use tmp_files/country1_miss, clear
		ren country1 country
		gen double id1 = _n
	saveold tmp_files/country1_miss_fm, replace

	use tmp_files/country2_miss, clear
		ren country2 country
		gen double id2 = _n
	saveold tmp_files/country2_miss_fm, replace

use tmp_files/country1_miss_fm, clear

preserve
	reclink country using tmp_files/country2_miss_fm, idmaster(id1) idusing(id2) gen(myscore) wmatch(1) wnomatch(9) minscore(.3) minbigram(0.8)

	sort Ucountry country
	order Ucountry country
	
	l Ucountry country if Ucountry ~= ""
restore

preserve
	reclink country using tmp_files/country2_miss_fm, idmaster(id1) idusing(id2) gen(myscore) wmatch(1) wnomatch(9) minscore(.5) minbigram(0.8)

	sort Ucountry country
	order Ucountry country
	
	l Ucountry country if Ucountry ~= ""
restore

	// ... NOW ...
	
	use data/pwt70, clear
	
		replace country = "antigua & barb." if country == "antigua and barbuda"
		replace country = "dominican rep." if country == "dominican republic"
		replace country = "kazakhastan" if country == "kazakhstan"
		replace country = "papua new guin." if country == "papua new guinea"
		replace country = "pueto rico" if country == "puerto rico"
		replace country = "st.kitts& nevis" if country == "st. kitts & nevis"
		replace country = "st.lucia" if country == "st. lucia"
		replace country = "st.vincent & g." if country == "st.vincent & grenadines"
		replace country = "trinidad & tob." if country == "trinidad &tobago"
		replace country = "united arab em." if country == "united arab emirates"
		replace country = "viet nam" if country == "vietnam"
		
		// (...)
		
timer off 1
timer list 1
		
log close
