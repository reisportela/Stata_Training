//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

// BHPS: example to combine the data from different years
	clear all
	set more off

// no data in the current folder; just the code
use file1
rename aeduc - aexper, predrop(1)
save file1a, replace

use file2, clear
rename aeduc aexper, predrop(1)
save file2a, replace

use file1a

	append using file2

save data, replace

local v = "file1 file2 file3 file4"
foreach zzz of local v {
	use `zzz', clear
	rename aeduc - aexper, predrop(1)
	save `zzz'a, replace	
}
