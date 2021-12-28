//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

clear all
set more off

		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata"

capture log close
log using logs/exemplo_loop.txt, text replace

sysuse auto, clear

	codebook, compact
	sum
	
	su price, detail
	
		tab rep78
				
// # 1. loop over categories

		foreach r of numlist 1/5 {
		
			sum price if rep78 == `r'
		
		}
		

// # 2. loop over categories

	levelsof make,local(cartype)

		foreach asd of local cartype {
			
			display _new(10) "CAR TYPE:	`asd'" _new(1)
			
			sum price if make == "`asd'"

		}
// # 3.

sysuse auto, clear
codebook, compact
tab1 rep78 foreign

levelsof make,local(brands)

foreach asd of local brands {
display _new(3) "MAKE:	`asd'" _new(1)
	sum price if make == "`asd'"
}


log close

