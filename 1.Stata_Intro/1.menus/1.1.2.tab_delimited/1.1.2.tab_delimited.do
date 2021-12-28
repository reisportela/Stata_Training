//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all
	set more off
	set rmsg on
	
	timer on 1
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\1.menus\1.1.2.tab_delimited"									// put here your folder
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\1.menus\1.1.2.tab_delimited"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus/1.1.2.tab_delimited"

capture log close
log using logs/tab_delimited.txt, text replace

sysuse auto, clear

export delimited using "data/auto_tab.txt", delimiter(tab) replace

	sleep 500

filefilter data/auto_tab.txt data/auto_tab_clean.txt, from(\t) to(";") replace


// OPEN FILE 'auto_tab.txt auto_tab_clean.txt' WITH NOTEPAD == SEE THE STRUCTURE OF THE FILE

	import delimited data/auto_tab_clean.txt, delimiter(";") varnames(1) clear

	sleep 500

filefilter data/auto_tab.txt data/auto_tab_clean.txt, from(";") to("") replace

// OPEN FILE 'auto_tab.txt auto_tab_clean.txt' WITH NOTEPAD == SEE THE STRUCTURE OF THE FILE
	
	import delimited data/auto_tab_clean.txt, varnames(1) clear

save data/auto_tab, replace

timer off 1
timer list 1

log close
