//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

clear all
set more off

		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\1.menus\logs"									// put here your folder
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\1.menus\logs"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus/logs"

log using "example.log", replace

sysuse auto.dta
	describe
	su
	codebook, compact

kdensity price
	graph export example1.pdf, replace


tabstat price,by(foreign) stat(mean sd p50 p90 p99)

	twoway (kdensity price if foreign == 0) ///
		(kdensity price if foreign == 1), scheme(sj) graphregion(color(white)) ///
		legend(order(1 "Domestic" 2 "Foreign")) legend(region(color(white)))
		
		graph export example2.png, replace

log close

// LOOP: examples

sysuse auto, clear

	// # 1. example 1
	
		foreach n of numlist 0/1  {

		display _new(2) "ROUND:	`n'" _new
			
			kdensity price if foreign == `n',title(`n')

		}

	// # 2. example 2

		levelsof make,local(rty)

		foreach n of local rty  {

		display _new(2) "ROUND:	`n'" _new

			if "`n'" == "Volvo 260" {
				
				list price if regexm(make,"Volvo 260")
				
			}
			
			
		}
