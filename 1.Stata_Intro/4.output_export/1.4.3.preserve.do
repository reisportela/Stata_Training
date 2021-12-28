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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export"
	
// EXAMPLE: 'preserve'
	
	clear all
	set more off

sysuse auto, clear
	codebook, compact
	sum price

preserve
	keep if foreign == 1
	sum price, detail
	kdensity price
restore

sum price
