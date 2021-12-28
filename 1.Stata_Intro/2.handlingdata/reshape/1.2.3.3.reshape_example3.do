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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata\reshape"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata\reshape"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata/reshape"

// RESHAPE multiple variables, example # 3

capture log close
log using logs/reshape_example3.txt, text replace

import excel "data/bankscope_example.xls", sheet("Results (Selected Top 125 Bank)") firstrow case(lower) clear

keep bankname totalassetsmilusd2013-totalassetsmilusd2008 equitymilusd2013-equitymilusd2008
tab bankname, miss
return list
drop if bankname == ""

	reshape long totalassetsmilusd equitymilusd,i(bankname) j(time)

// 'destring', alternative a

	preserve
		local nnnn = "totalassetsmilusd equitymilusd"

		foreach v of local nnnn {
			destring `v', replace force
		}
	restore

// 'destring', alternative b

	destring totalassetsmilusd equitymilusd, replace force

save data_stata/bankscope_example, replace

timer off 1
timer list 1
				
log close
