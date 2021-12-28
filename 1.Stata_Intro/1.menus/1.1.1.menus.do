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
	
// EXAMPLE ON IMPORTING TAB DELIMITED DATA
	clear all
	set more off


// # 1. MENU 'File'
// # 1.1 "Working directory..."

		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\1.menus"									// put here your folder
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\1.menus"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus"
		
		clear all
		set more off
		set rmsg on
		
// # 1.2 CREATE A LOG FILE, 'Log'
	
		capture log close						// in the event a log is open, close it, otherwise move to the next line; avoids the error message in case no log is open
		log using logs/read_data.txt, text replace

// # 1.3 OPEN A STATA DATA FILE

// # 1.3.1 use a system file from the web

		// Import data from an internet archive
			capture use http://www.stata-press.com/data/r12/apple.dta
			capture save data/apple, replace					// save the file in Stata data format

// # 1.3.2 open a Stata data file
		use data/apple, clear

// # 1.4 import and export options
	
		// Data source - Penn World Table: https://pwt.sas.upenn.edu/

		// OPEN THE FILE 'pwt71.csv' WITH Stata doedit TO SEE THE DATA

		// Read text data created by a spreadsheet
		// Indicate that variables names are in the first row of the data file

		insheet using "data/pwt71.csv", delimiter(,) names clear

		keep isocode year pop xrat openc rgdpl rgdpwok

		save data/pwt71_short, replace

		// Export in xlsx format
			export excel using "data/pwt71_short.xlsx", firstrow(variables) replace

		// Import the xlsx file format
			import excel "data/pwt71_short.xlsx", sheet("Sheet1") firstrow case(lower) clear

		// Load the Stata native binary format '.dta'
			use data/pwt71_short, clear

		// In case you want to export your data to be read by other software and it has above
		// 1 Million observations you better use an ASCII file format (Excel does not handle very large files)
			
			outsheet using "data/pwt71_short.txt",delimiter("$") replace

// # 1.5 Explore example data sets
		sysuse auto, clear
		sysuse census, clear

// # 1.6 ODBC example

	// "Microsoft has still not published a OSBC-Driver for 64bit applications that want to read data from Access Files"
	// only Stata 32-bit is able to use ODBC with Microsoft Access database: for this example I am going to use Stata 12 32-bit
	// windows, search for ODBC Administrator
	// add 'Microsoft Access Driver' and choose your access data set == we will be using odbc_stata_example.mdb

		/*
			odbc list
			odbc query "odbc_stata_example", dialog(complete)
			odbc desc "pwt71"
			odbc load, table("pwt71") clear
				describe
				
				gen pop2 = pop^2
				
				odbc insert isocode pop2, as("isocode pop2") dsn("odbc_stata_example") table("pwt71_new") create
				odbc query "odbc_stata_example", dialog(complete)
				odbc desc "pwt71_new"
				
				replace pop2 = -pop2
				
				odbc insert isocode pop2, as("isocode pop2") dsn("odbc_stata_example") table(" pwt71_new") overwrite
				odbc query "odbc_stata_example", dialog(complete)
				odbc desc "pwt71_new"
				odbc load, table("pwt71_new") clear
					sum
					save odbc_example, replace
		*/

// # 2. EDIT menu: explore the following two items

		// Clear Results window
		// Preferences

// # 3. DATA menu: examples

		use data/pwt71_short, clear
		
		describe			// Describe data in memory
		inspect pop			// Display simple summary of data's attributes
		ds					// Compactly list variable names
		summarize			// Summary statistics
		sum pop, detail		// Additional statistics 
		range x 1 100		// Generate numerical range

		// Define variable labels

		label var isocode 	"Country Code"
		label var year 		"Year of Observation"
		label var pop 		"Population (in thousands)"
		label var xrat 		"Exchange Rate to US$: national currency units per US dollar"
		label var openc 	"Openness at Current Prices (%)"
		label var rgdpl 	"PPP Converted GDP Per Capita (Laspeyres), derived from growth rates of c, g, i, at 2005 constant prices"
		label var rgdpwok 	"PPP Converted GDP Chain per worker at 2005 constant prices"

		order isocode year xrat	// Change order of variables
		gsort +year -rgdpwok	// Ascending and descending sort

// # 4. GRAPHICS menu

		twoway (scatter rgdpwok openc, sort)
		histogram rgdpwok if year == 2010

		preserve
			keep if year == 1960 | year == 1970 | year == 1980 | year == 1990 | year == 2000 | year == 2010
			graph box rgdpwok, by(year)
			sleep 2700
			graph box rgdpwok, by(year) nooutsides scheme(sj)
				//graph export graphs\rgdpwok_boxp.wmf, replace
				graph export graphs/rgdpwok_boxp.png, replace
		restore

		quantile rgdpwok if year == 1960, title(1960) recast(area) name(g1960, replace)
		quantile rgdpwok if year == 2010, title(2010) recast(area) name(g2010, replace)

		graph combine g1960 g2010, ycommon
		graph combine g1960 g2010
			//graph export graphs\rgdpwok_comb.wmf, replace
			graph export graphs/rgdpwok_comb.png, replace

		kdensity rgdpwok if year == 2010
			//graph export graphs\rgdpwok_dens.wmf, replace
			graph export graphs/rgdpwok_dens.png, replace

// # 5. STATISTICS menu

		tabstat rgdpwok if year == 1960 | year == 2010, statistics(mean sd p25 p50 p75 p90 p99 ) by(year)

// # 6. Window

// # 7. HELP menu
		help summarize
		h su

// # 8. NOTES
	clear
	cls					// CLEAR THE RESULTS WINDOW

	sysuse auto
	
		label define lbl_f 0 "Domestic" 1 "Foreign", replace
		tab foreign
		tab foreign, nolabel

		ge logprice = log(price)
		ge lnprice = ln(price)
		compare lnprice logprice
		sum price if foreign == 0
		sum price if foreign == 1
		bysort foreign: sum price
		tabstat price,by(foreign)
		tabstat price,by(foreign) stat(mean sd p25 p99)
		egen meanprice = mean(price),by(foreign)
		egen nmiss = rmiss(price mpg)
		drop nmiss
		egen nmiss = rmiss(_all)
		collapse (mean) price mpg ,by(foreign)


	sysuse auto, clear

		list if regexm(make,"Buick")
		//br if regexm(make,"Buick")
		//h functions
		keep make
		gen f4 = substr(make,1,4)
		gen dot = substr(make,1,strpos(make,"."))
		drop dot
		gen first = word(make,1)
		//help string functions
		ssc install ascii
		ssc install charlist
		charlist make
		ascii
		di  char(98)

clear all
log close
