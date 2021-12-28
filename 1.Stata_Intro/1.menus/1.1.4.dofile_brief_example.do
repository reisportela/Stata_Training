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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\1.menus"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\1.menus"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus"

capture log close
log using logs/example.txt, text replace

	sysuse auto, clear
		describe
		summarize
		summarize price

		kdensity price

		tab foreign

timer off 1
timer list 1

log close
