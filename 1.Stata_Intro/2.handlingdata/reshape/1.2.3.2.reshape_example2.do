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

// RESHAPE + MERGE, example # 2

capture log close
log using logs/reshape_example2.txt, text replace

// # 1. import data from data_examplea.xlsx

		import excel "data/data_example2a.xlsx", sheet("D1") firstrow case(lower) clear
			save data_stata/cod_descr, replace

		import excel "data/data_example2a.xlsx", sheet("D2") firstrow case(lower) clear
			save data_stata/escola_tipo, replace

		import excel "data/data_example2a.xlsx", sheet("D3") firstrow case(lower) clear
			save data_stata/notas, replace

// # 2. import data from data_exampleb.xlsx

		import excel "data/data_example2b.xlsx", sheet("D1") clear
			rename B-KW descr#, addnumber 
			keep in 1
			reshape long descr,i(A) j(Municipio)
			drop A
			save data_stata/link, replace

		import excel "data/data_example2b.xlsx", sheet("D1") clear
			rename B-KW p#, addnumber 		// teachers
			drop in 1

			ren A ano
			reshape long p,i(ano) j(Municipio)

				merge 1:1 Municipio using data_stata/link
				drop _merge

			unique Municipio

			capture destring Municipio, replace force
			capture destring ano, replace force
			capture destring p, replace force
			
			recode p 0 = .
			
		ren p alunos_1ciclo
			label var alunos_1ciclo "Número de alunos matriculados no 1 ciclo"

			order Municipio ano
			sort Municipio ano
			
			replace descr = "Calheta (R.A.A.)" if descr == "Calheta [R.A.A.]"
			replace descr = "Calheta (R.A.M.)" if descr == "Calheta [R.A.M.]"
			replace descr = "Lagoa (R.A.A)" if descr == "Lagoa [R.A.A.]"
			
		save data_stata/alunos_1ciclo, replace

		merge 1:1 descr using data_stata/cod_descr
			tab descr if _merge == 1
			tab descr if _merge == 2
			keep if _merge == 3
			drop _merge

			gen concelho2 = distrito + concelho

		save data_stata/alunos_1ciclo, replace

///////////////////////////////////////////

use data_stata/notas, clear
	merge m:1 escola using data_stata/escola_tipo
	keep if _merge == 3
	drop _merge

		unique escola
		unique concelho
		unique distrito
		
		drop if distrito == "99"
		
		gen female = (sexo=="M")
		
		gen concelho2 = distrito + concelho
			unique concelho2
		
		gen pub = (pubpriv== "PUB")

	collapse (mean) provapontos female pub,by(concelho2)

	merge 1:1 concelho2 using data_stata/alunos_1ciclo

		keep if _merge == 3
		drop _merge
	
	save data_stata/data_final, replace
	
	describe
	sum
	tab1 distrito female ano
	sum provapontos, detail
	
	sh del alunos_1ciclo.dta
	sh del cod_descr.dta
	sh del escola_tipo.dta
	sh del link.dta
	sh del notas.dta

timer off 1
timer list 1
				
log close
