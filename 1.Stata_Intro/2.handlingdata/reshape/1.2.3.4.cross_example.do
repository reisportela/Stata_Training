//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
	set more off											// ALLOW SCREENS TO PASS BY
	set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata\reshape\cross_example"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata\reshape\cross_example"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata/reshape/cross_example"

sysuse auto, clear
	gen id = _n
	reg price mpg
	predict e, resid
	keep id e
save residuals, replace

	ren id id1
	ren e e1
save residuals1, replace

use residuals, clear

	cross using residuals1
	list
