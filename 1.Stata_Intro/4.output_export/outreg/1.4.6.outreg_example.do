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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export/outreg"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export/outreg"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export/outreg"
	
	timer on 1


// ssc install outreg, replace

sysuse auto, clear
	codebook, compact
	sum price

logit foreign mpg
	margins, dydx(*)

outreg using logs/margins_example.doc, replace marginal title("Model 1")

logit foreign mpg weight
	margins, dydx(*)

outreg using logs/margins_example.doc, append marginal title("","Model 2")

timer off 1
timer list 1
