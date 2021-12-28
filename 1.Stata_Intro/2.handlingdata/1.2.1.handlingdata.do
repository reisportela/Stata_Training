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
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata"


global st = "$S_TIME"									// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM


// FILES TO BE INSTALLED with `ssc install' or `net install'

	// Define proxy for the web

	// packages: 	ascii charlist unique outreg2 est2tex abar listtab listtex elapse sample2 cf2 cf3
	//				outtable latab tabout sutex xtabond2 ivreg2 ranktest renvars tabout

		/*
		local ados = "ascii charlist unique outreg2 est2tex listtab listtex elapse cf2 cf3 outtable latab tabout sutex ivreg2 ranktest tabout"
		foreach a of local ados {
			display _new(3) "Command:	`a'" _new(2)
			ssc install `a', replace
		}

		net install st0159_1.pkg, from (http://www.stata-journal.com/software/sj12-4) replace
		net install dm46.pkg, from(http://www.stata.com/stb/stb37) replace
		*/

			// type 'cmdlog using commands.txt, text replace' in case you want to record the commands you type interactively
			// at the end type 'cmdlog close'

capture log close								// CLOSE THE LOG IN CASE IT IS OPEN; OTHERWISE PROCEED
log using logs/handlingdata.txt, text replace		// BUILD A LOG FILE FOR THE OUTPUT


// ########################################################################### //

// # 1. READ DATA FROM the WEB & SAVE IT IN AS A LOCAL FILE

*	// comment here if internet is not available
	cd sample
		
		use http://www.stata-press.com/data/r13/abdata.dta, clear
			describe
			codebook, compact					// COMPACT DESCRIPTION OF THE VARIABLES

			keep if year == 1984				// KEEP JUST PART OF THE OBSERVATIONS
			save abdata_1984, replace			// SAVE A SAMPLE IN STATA DATA FORMAT

		use abdata_1984, clear					// OPEN A DATA SET IN STATA DATA FILE FORMAT
			codebook, compact

	cd ..
*/

// ########################################################################### //



// # 2. READING DATA FROM CSV (comma-separated values) FORMAT
//		EXPORT & IMPORT FILES FROM .CVS & EXCEL FILES



	// (can be saved from different softwares):
	// 		PWT - https://pwt.sas.upenn.edu/ == Penn World Table
	// 		NOTE: SPPS v.19 CAN SAVE CSV, EXCEL AND STATA FILES

		cd growth/pwt70							// move down one folder

			// Read text data created by a spreadsheet; indicate that variables names
			// are in the first row of the data file
			insheet using pwt70_csv_data_file.csv, names clear
				describe
			
			// EQUIVALENT TO
			
				import delimited pwt70_csv_data_file.csv, clear
					save pwt70, replace
			
			// EXPORT THE DATA TO AN EXCEL FILE
				export excel using pwt70.xls, firstrow(variables) replace
			
			// WHEN THE DATA IS VERY BIG, OR YOU WANT TO EXCHANGE IT WITH ANOTHER GENERIC SOFTWARE, EXPORT TO .CSV
				export delimited using pwt70.csv, delimiter(";") replace
			
			// IMPORT DATA FROM AN EXCEL FILE
				import excel pwt70.xls, sheet("Sheet1") firstrow case(lower) clear
			
			
			// REPLICATE THE ABOVE PROCEDURE USING the AUTOMATIC procedure: go to menu File + Import + Text data (delimited, *.csv,...), etc.


	// LABEL VARIABLES: use the information in the file pwt70_excel_variables.xls
					label var country		"Country name"
					label var year			"Year of observation"
					label var isocode		"Country code"
					label var pop			"Population (in thousands)"

				// Exchange Rates and PPPs over GDP
					label var xrat			"Exchange Rate to US$; national currency units per US dollar"
					label var ppp			"Purchasing Power Parity over GDP (in national currency units per US$)"  	

				//	Constant Price GDP Per Capita and Expenditure Shares
					label var rgdpl			"PPP Converted GDP Per Capita (Laspeyres), derived from growth rates of c, g, i, at 2005 constant prices"
					label var kc			"Consumption Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var kg			"Government Consumption Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var ki			"Investment Share of PPP Converted GDP Per Capita at 2005 constant prices [rgdpl]"
					label var openk			"Openness at 2005 constant prices (%)"
					label var rgdpwok		"PPP Converted GDP Chain per worker at 2005 constant prices"

				lookfor GDP							// LOOK FOR THE STRING 'gdp' IN VARIABLE NAMES or LABELS
				
				order country year					// order the sequence of variables as you see them, for example, in 'browse'
				keep country year isocode pop xrat ppp rgdpl kc kg ki openk rgdpwok	// keep a specific list of variables
				
				replace country = lower(country)	// small caps for country names
				tab country
					
				// correct a data issue for China & KEEP JUST ONE VERSION OF THE DATA FOR CHINA
					drop if country == "china version 1"
						replace country = "china" if country == "china version 2"

				
				// the country names have to be harmonized with the following data on education
				replace country = "antigua and barbuda"	if country == "antigua & barb."
				replace country = "central african republic"	if country == "central afr. r."
				// (...)	- include here the remaining replacements
				
				replace country = lower(country) 									// SET small caps for country names
					tab country
					tab year
				
				sort country year
				save pwt70, replace			// the file can be saved in a previous Stata format using 'saveold'

				describe

			clear all
			cd ..						// move one folder up


// ########################################################################### //



// # 3. COMBINE INFORMATION FROM DIFFERENT SOURCES == command 'merge'



			// CROSS Penn World Table WITH BARRO & LEE DATA
			// Source:	http://www.cid.harvard.edu/ciddata/ciddata.html

			cd barro_lee

			// assignment: 	1. build an excel file with data on education by country and year
			//				2. transport the data to Stata
			//				3. combine the information with PWT used above
			import excel "barro_lee_aeduc.xlsx", sheet("education") firstrow case(lower) clear
				cf2 _all using barro_lee_aeduc, verbose 							// 'cf2': compare with the file in stata format

			use barro_lee_aeduc, clear												// READ A FILE ALREADY IN STATA FORMAT
				drop if year == .
			
			// BROWSE THE DATA USING THE COMMAND 'browse'
			// IDENTIFY THE CORRECTIONS TO BE MADE; COMPARE YOUR ANALYSIS WITH THE FOLLOWING COMMANDS
			
			replace country = country[_n+1] if year <= 1955 & country == ""
			replace country = country[_n+1] if year <= 1955 & country == "" 		// check for data on 'Philippines'
			replace country = country[_n-1] if country == "" & _n > 1

				tab country
				replace country = lower(country)
					tab country
					tab year
					
				order country year
				sort country year
				
				describe
				codebook, compact
				
				// since education is defined as string, we will transform it in a number
				destring education, force replace

					save data_educ, replace

			cd ..
			
			
			///// MERGE THE TWO DATASETS /////
			
			// read income data in order to combine it with the education data

			use pwt70/pwt70, clear

				// the key used to link the two data sets is defined by the variables country & year
				// within the pair country & year there is a unique observation
				// at this stage the data in memory is the one saved in the line 'save pwt70, replace'

				// '1:1' means that 1 row in the data in memory will be combined with 1 row in the data saved in the harddrive
				
				merge 1:1 country year using barro_lee/data_educ	// the merge is made on country & year

				tab country if _merge == 3				// identify the names of countries that are in both data sets
					ret li
				tab country if _merge == 1				// identify the names of countries that are just in the data in memory
				tab country if _merge == 2				// identify the names of countries that are just in the data in the harddrive
				
				
				
				// as we want to implement an analysis that will make use of both income & education data
				// we will only keep the observations identified in both data sets, '_merge == 3'
				
				keep if _merge == 3
					drop _merge				// we do not need this variable any longer
				
				drop if year < 1960
				sort country year
				
				describe
				codebook, compact
				compress					// optimize the storage of the data

			save tmp, replace

// ########################################################################### //


// # 4. RESHAPING THE DATA: use data from a 3rd source


	cd capital

			// Source:	http://www.cid.harvard.edu/ciddata/ciddata.html

			// DOWNLOAD THE DATA IN EXCEL FORMAT; IMPORT IT TO STATA AND SAVE THE FILE 'cap_inv.dta'

				import excel cap_inv.xls, sheet("CAP_INV") clear

			// explore the data with the command 'browse'
			
			// RENAME VARIABLE NAMES WITH YEARS, command 'rename'


			rename (E-AW) (k#), addnumber(1948)			// rename a group of variables
			
				keep if regexm(D,"Total Capital") 		// under variable 'D' keep only the lines that include the string 'Total Capital'
				ren B country
				keep country k1948-k1992
				replace country = lower(country)

			///// USE OF RESHAPE /////

				reshape long k, i(country) j(year) 		// to include more variables you have to do it separately
				destring k, force replace
				drop if k == .
				
				format %16.3f k
				list k in 1/10
				
				label var k "Capital"
				
				codebook, compact
				
				order country year
				
				sort country year
				save capital_data, replace

		cd ..


// ########################################################################### //



// # 5. JOIN CAPITAL TO GDP & EDUCATION; tmp.dta file defined above


		use tmp, clear											// use the data file built above: gdp + education
			merge 1:1 country year using capital/capital_data
			drop if _merge == 2		// since we can make some of the analysis just with gdp & education, we only need to drop those observations just avaulable in the 'using' data
			drop _merge
			
			des
			codebook, compact
			tab year
			inspect isocode
			ds					// list the name of the variables available in the data
			
			// create variables
			
			generate lngdp = ln(rgdpwok)
				label var lngdp "Log Real GDP per Worker"
			gen lnk = ln(k)
				label var lnk "Log Capital"
			
					note: This data has been assembled for the course Data management, regression, panel data analysis and research output using Stata
					note: Feel free to adapt it.
					
					egen nmiss = rowmiss(_all)	// identify missings in all variables
					des
					tab nmiss
						drop nmiss

					sort country year
					save growth_data, replace
					notes						// read notes attached to the data

		sh del tmp.dta							// use MSDOS to delete a file from the harddrive

// # 6. Read and HTML Table

// https://www.ssc.wisc.edu/sscc/pubs/readhtml.htm

	// net install readhtml, from(https://ssc.wisc.edu/sscc/stata/)
	
	readhtmltable https://ssc.wisc.edu/sscc_jsp/training/, varnames


// ########################################################################### //


// # 7. ADDITIONAL DATA COMMANDS: APPEND - Append datasets


// simulate an append

			use growth_data if year == 2000, clear				// read the data keep just one year of observations
				keep country year rgdpwok education
				replace year = year + 5
				
				set seed 234345456								// specify initial value of random-number seed
				replace rgdpwok = rgdpwok + uniform()			// generate a random variable using the function 'uniform()'
																// when using some form of randomization first define 'set seed'
																// its mandatory to be able to replicate the analysis

				replace education = education + uniform()*5
				
				save tmp, replace
				
			use growth_data, clear
				keep country year rgdpwok education
				append using tmp			// we appending a new year to the data

				sh del tmp.dta 				// sh: execute a DOS command and delete de data tmp.dta

	// this is an example, so do not save the data


// ########################################################################### //

		capture ssc install elapse					// install the command 'elapse'

elapse $st									// TIME IT TOOK TO RUN THE FULL PROGRAM

clear all									// clear the memory at the end of the session to free resources

timer off 1
timer list 1
				
log close									// CLOSE THE LOG FILE
