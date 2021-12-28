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

// RESHAPE + MERGE, example # 1

capture log close
log using logs/reshape_example1.txt, text replace

// # 1. import an excel file, wide format, and save it in Stata format

	// # 1.1 variable 1
		import excel "data/data_example1.xlsx", sheet("fertility_index") firstrow clear

		ren TOTAL municipioid
		ren B municipio
	
	// 1.2 save municipality name
		preserve
			keep mun*
			drop if municipioid == ""
			save data_stata/municipios_id, replace
		restore

		drop municipio

		drop if municipioid == ""
	
	// 1.3 reshape
		ren (C-G) (ifecund2009 ifecund2010 ifecund2011 ifecund2012 ifecund2013)
			reshape long ifecund, i(municipioid) j(ano)
			save data_stata/ifecund, replace
	
	// 1.4 variable 2
		import excel "data/data_example1.xlsx", sheet("foreign_women") firstrow clear

		ren TOTAL municipioid
		ren Anos municipio

		drop municipio

		drop if municipioid == ""

		ren (C-G) (foreignw2009 foreignw2010 foreignw2011 foreignw2012 foreignw2013)
			reshape long foreignw, i(municipioid) j(ano)
			save data_stata/mulheres_estrangeiras, replace

	// 1.5 variable 3
		import excel "data/data_example1.xlsx", sheet("net_migration") firstrow clear

		ren TOTAL municipioid
		ren Anos municipio

		drop municipio

		drop if municipioid == ""

		ren (C-G) (migr2009 migr2010 migr2011 migr2012 migr2013)
			reshape long migr, i(municipioid) j(ano)
			save data_stata/migr, replace	
	
// # 2. merge data and build a single Stata data file
		use  data_stata/ifecund, clear
			merge 1:1 municipioid ano using data_stata/mulheres_estrangeiras
				drop _merge
			
			merge 1:1 municipioid ano using data_stata/migr
				drop _merge
			
			merge m:1 municipioid using data_stata/municipios_id
				drop _merge
			
			order municipio municipioid ano
			describe
			sum
			
			sort municipio ano
			save data_stata/data_full, replace

timer off 1
timer list 1
				
log close
