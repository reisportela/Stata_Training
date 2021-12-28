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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\1.menus\1.1.3.unicode"									// put here your folder
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\1.menus\1.1.3.unicode"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus/1.1.3.unicode"

// example: clean files with 'utf8' codes

clear all
set more off

	unicode analyze latin1_example.do
	unicode encoding set latin1
	unicode translate latin1_example.do, invalid(ignore)
