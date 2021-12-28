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

capture log close						
log using logs/handlingdata_further_commands.txt, text replace

	use growth/growth_data, clear
	codebook, compact
	

	// # 1. commands to see and edit data
	
		//	edit: Edit data with Data Editor			// be careful: you can damage the data by doing this; avoid using this command
		//	browse: Browse data with Data Editor

	
	// # 2. DISPLAY A GIVEN MESSAGE OR computation: examples
	
	display 2^3
	di _new _new "Computation, ln(23) =	" ln(23) _new	// insert 2 blank lines before the display and 1 after
		
	
	// # 3. commands over variables
	
		// # 3.1 create a new variabe
			generate education2 = education^2		// generate a new variable with the square of education
			ge lnpop = ln(pop)						// generate a new variable with the log of population
													// for Stata log = ln; log10 is the log base 10

			clonevar cty = country					// clone existing variable
				compare country cty					// compare two variables; in this case they are the same
				compress cty
				compare country cty
				describe cty
				
				drop cty							// drop a given variable

		// # 3.2 generate a numeric id for each country
			egen double cty_id = group(country)		// egen: extensions to generate == explore the command with 'help egen'; create the variable with double precision

		// # 3.3 alternative that can be used to produce an similar result
			encode country, gen(cty_id2)
			tab cty_id2
			tab cty_id2, nolabel
				compare cty_id cty_id2
			
			decode cty_id2, gen(country2)
				tab country2
				compare country country2
				
		//	# 3.4 type 'help functions'
			
			gen cty_year = cty_id*10000 + year				// generate a unique code for country + year
			gen random = int(runiform()*23)					// generate a random variable
			bysort country (year): gen num = _n				// generate sequential id numbers within country
				egen total_num = total(num), by(country)	// compute the sum of 'num' within country
			bysort country (year): gen rollsum = sum(num)	// computing running sums
				egen nobs = count(year),by(country)			// count the number of observations within each country
			
			order country year num rollsum total_num nobs	// reorder variables in dataset
			
		// # 3.5 fl: fast list; useful to list big data sets
			fl country year num rollsum total_num nobs in 1/20, sepby(country)
			list cty_id in 1/10, clean
			
			order nobs, after(year)
			
		// # 3.6 varmanage: Manage variable labels, formats, and other properties

		// # 3.7 `gsort' arranges observations to be in ascending or descending order
			gsort country -year
			
		// # 3.8 preserve the data in memory and build a separate data with means by country
			preserve
				collapse (mean) education rgdpwok, by(country)	// collapse the data with the mean of education & gdp within countries
				codebook, compact
			restore
			
			preserve
				drop if k==.	// drop missing observations on capital == drop specific observations satisfying the condition
				l k in 21/25
				format %12.0f k	// change de way we see the numeric values of the variable
				l k in 21/25
			restore

		// 3.9 work with labels
			label def lbl_years 1960 "Year 60" 1965 "Year 65" 1970 "Year 70" 1975 "Year 75" 1980 "Year 80" 1985 "Year 85" 1990 "Year 90" 1995 "Year 95" 2000 "Year 2000"
			label values year lbl_years
				tab year
				tab year, nolabel
				label dir
				label list
				labelbook
			
			numlabel lbl_years, add mask("#=")			// label utilities == prefix numeric values to value labels

			tab year

			numlabel cty_id2, add mask("#=")
			tab cty_id2

		// 3.10 recode command
			rename country cty
			clonevar educ2 = education
			recode educ2 min/4 = 4 4.00001/9 = 9 9.00000/max = 12		// recode categorical variables
			tab educ2
			
		// 3.11 compare variables
			compare educ2 education
			
		// # 3.12 identify duplicates in the data
			duplicates tag _all, ge(dup)
			tab dup							// `0' means no duplicate
				unique cty
				tab cty
				ret li						// = return list; identifies the number of observations, as well as the number of unique values
			
		// # 3.13 codebook
			codebook education
			inspect education
			tab education, miss				// run a tabulation identifying the missing values of the variable

		// # 3.14 create variable containing quantile categories
			xtile gdp_dec = rgdpwok, nq(10)

			tab gdp_dec
			fl rgdpwok gdp_dec if rgdpwok ~= .
			
			pctile tmp = rgdpwok, nq(10)	// create variable containing percentiles

			tab tmp
			fl tmp in 1/15
				drop tmp
			
			set seed 444555666
			preserve
				sample 10
				sum education, detail
			restore
			
		//	# 3.15 findit sample2: install the command 'sample2'
			net install dm46.pkg, from(http://www.stata.com/stb/stb37) replace

		// # 3.16 produce a 10% random sample
			preserve
				sample2 10, cluster(cty_id)
											// keeping the panel structure
				sum education, detail
			restore
			
			preserve
				replace education = . if education > 12		// replace contents of existing variable
			restore
			
		// # 3.17 check for unique identifiers
			drop if year == .
			isid cty_id	year

		// # 3.18 reduce data size on the harddrive
			compress

		// # 3.19 verify truth of claim
			assert inlist(year,1960,1965,1970,1975,1980,1985,1990,1995,2000)
				capture noisily assert inlist(year,1990,1995,2000)
				capture noisily assert education<=12

		//	# 3.20 COMPARE TWO FILES
			use growth/growth_data if year == 2000, clear
				
				// capture: capture return code == in case of error the program continues
				// noisily: perform command and ensure terminal output
				capture noisily cf _all using growth/growth_data		
				ssc install cf2, replace
				capture noisily cf2 _all using growth/growth_data, verbose id(country)
		
		// # 4. loops
		
		// # 4.1 foreach + local
			use growth/growth_data, clear
			
			tab country
			
			local llist = "portugal spain france"
			
			foreach cc of local llist {
				display _new _new "COUNTRY:	`cc'"
				preserve
					keep if country == "`cc'"
					tab country
					kdensity lngdp
					reg lngdp education
				restore
			}
			
		// # 4.2.1 foreach + numlist
			foreach n of numlist 100(50)1000 {
				di _new _new "N:	`n'" _new
				clear
				set obs `n'
				set seed 234345456
				gen x = uniform()
				sum x
			}
			
		// # 4.2.2 foreach + numlist
			foreach n of numlist 100/110 {
				di _new _new "N:	`n'" _new
				clear
				set obs `n'
				set seed 234345456
				gen x = uniform()
				sum x
			}
			
		// # 4.3 while
			use growth/growth_data, clear
			local i = 23
		
			while `i' <= 500 {
				di _new _new "n:	`i'" _new
				tab country if _n == `i'
				local i = `i' + 50
			}
			
		// # 5. Build your own program: simple example
		
			capture prog drop analyse
			program define analyse
			
				codebook `1' if country == "`2'" & year < `3', compact
				inspect `1' if country == "`2'" & year < `3'
				sum `1' if country == "`2'" & year < `3', detail
				kdensity `1' if country == "`2'" & year < `3'
				
			end
			
			analyse lngdp spain 1980

timer off 1
timer list 1

log close
