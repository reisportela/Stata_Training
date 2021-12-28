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

// FUZZY MERGE EXERCISE # 1.: 'matchit'

capture log close
log using logs/matchit.txt, text replace

use data/pwt70, clear
	des
	keep country
	bysort country: keep if _n == 1
	save tmp_files/country_pwt, replace

use data/data_educ, clear
	des
	keep country
	bysort country: keep if _n == 1
	save tmp_files/country_educ, replace


use tmp_files/country_pwt, clear
	merge 1:1 country using tmp_files/country_educ
	tab country if _merge == 3
	
	tab country if _merge == 1
		preserve
			keep if _merge == 1
			drop _merge
			encode country, gen(pwtid)
			order pwtid country
			save tmp_files/country_pwt_miss, replace
		restore
		
	tab country if _merge == 2
		preserve
			keep if _merge == 2
			drop _merge
			encode country, gen(educid)
			replace educid = educid + 1000
			order educid country
			save tmp_files/country_educ_miss, replace
		restore
	
use tmp_files/country_pwt_miss, clear
	matchit pwtid country using tmp_files/country_educ_miss.dta, idusing(educid) txtusing(country)
		list
		save tmp_files/country_corrections, replace

use tmp_files/country_pwt_miss, clear
	matchit pwtid country using tmp_files/country_educ_miss.dta, idusing(educid) txtusing(country) sim(token) score(jaccard)
		list

use tmp_files/country_pwt_miss, clear
	matchit pwtid country using tmp_files/country_educ_miss.dta, idusing(educid) txtusing(country) sim(bigram) score(jaccard)
		list

use tmp_files/country_pwt_miss, clear
	matchit pwtid country using tmp_files/country_educ_miss.dta, idusing(educid) txtusing(country) sim(bigram) score(simple)
		list

timer off 1
timer list 1
				
log close
