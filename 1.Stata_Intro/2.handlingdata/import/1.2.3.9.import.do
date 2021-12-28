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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata\import"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata\import"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata/import"

capture log close						
log using logs/import.txt, text replace

// # 1. OPEN A STATA DATA FILE
	
// # 1.1 use a system file from the web
	cd stata
	
	sysuse auto
	describe
	summarize
		save auto, replace

// # 1.2 open a Stata data file
		use auto, clear

// # 1.3 import data from an internet archive
		use http://www.stata-press.com/data/r13/apple.dta
			save apple, replace					// save the file in Stata data format

	cd ..

			
// # 2. Excel & ASCII files: import and export options

	// REPLICATE THE ABOVE PROCEDURE USING the AUTOMATIC procedure: go to menu File + Import + Text data (delimited, *.csv,...), etc.
	
	cd excel
	
		// Data source - Penn World Table: https://pwt.sas.upenn.edu/

		// OPEN THE FILE 'pwt70.csv' WITH Stata doedit TO SEE THE DATA
		// alternative editors include Notepad, Winedit, Oxedit, Sublime Text

		// Read text data created by a spreadsheet
		// Indicate that variables names are in the first row of the data file
	
	// # 2.1 read .csv file
			insheet using "pwt70.csv", delimiter(,) names clear

			keep isocode year pop xrat openc rgdpl rgdpwok

	
	// # 2.2 Export to other formats

		// # 2.2.a Save in stata data format
					save pwt70_short, replace

		// # 2.1.b Export in xlsx format
					export excel using "pwt70_short.xlsx", sheet("data") firstrow(variables) replace

		// # 2.1.c Export in .csv format
				
			// # 2.1.c.1
					export delimited using "pwt70_short.csv", replace
			
			// # 2.1.c.2
					export delimited using "pwt70_short_tab.csv", delimiter(tab) replace
			
			// # 2.1.c.3
					export delimited using "pwt70_short_semicolon.csv", delimiter(;) replace
					
				// In case you want to export your data to be read by other software and it has above
				// 1 Million observations you better use an ASCII file format (Excel does not handle very large files)
					
					outsheet using "pwt70_short.txt", delimiter("$") replace
			
		// # 2.1.d Export in .raw format with a dictionary
					outfile using "pwt70_short_free.dct", dictionary replace



	// # 2.3. Import the xlsx file format
			import excel "pwt70_short.xlsx", sheet("data") firstrow case(lower) clear

	// # 2.4. Import the .csv ; file format
			import delimited "pwt70_short_semicolon.csv", delimiter(";") varnames(1) clear

	
	// # 2.5. READING DATA FROM ASCII FORMAT: infile using fixed-format files (infile with a dictionary)
	
		// # 2.5.a. dictionary and data in the same file
		
			infile using "pwt70_short_free.dct", clear
	
			cd ..

		
		// # 2.5.b. data in a different file from the dictionary
	
			cd ascii

				// view with Stata doedit the files ascii_example.txt and ascii_example.dct
				// doedit ascii_example.txt
				// doedit ascii_example.dct

					infile using ascii_example.dct, clear	// read the data to Stata
						des									// describe the data: variables names, storage type, display format, value label and the variable label
					
					save ascii_example, replace				// save the file in old Stata format

			// NOTE: in Stata the decimal is denoted by dot, not comma
					
				filefilter data_ascii_example_comma.txt data_ascii_example_dot.txt, from(",") to(".") replace	// EXERCISE: install filefilter


	cd ..


// # 3. XML example
	cd xml
	
		sysuse auto, clear
		
		// # 3.1 .xml export
			xmlsave "auto_xml.xml", doctype(excel) replace
		
		// # 3.2 .xml import
			xmluse "auto_xml.xml", doctype(excel) first clear
			
				describe
				
				// one can spare space by compressing the data
				compress
					describe
		
		// # 3.3 .xml import: outside example
			xmluse "data_example_xml.xml", doctype(excel) firstrow clear

// # 4. ODBC example

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

timer off 1
timer list 1
				
log close
