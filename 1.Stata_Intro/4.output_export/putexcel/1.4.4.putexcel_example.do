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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export/putexcel"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export/putexcel"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export/putexcel"


// 'putexcel' example

capture log close						
log using putexcel.txt, text replace

use graph_data, clear
	codebook, compact

// # 1. summarize
	
	// 1.1 MEANS

			putexcel clear
			putexcel set descriptives.xlsx, sheet("Avg. Educ. & desc.") replace
			
			// 1.1.1 report only aggregate average education
			
				putexcel B1=("Country"), italic left
				putexcel C1=("Average Education"), italic left
				
				putexcel B2=("All"), bold left border(bottom)
				
				sum education
					
					putexcel C2=(r(mean)), nformat(number_d2) bold right border(bottom)

			// 1.1.2 report average education for a set of countries
			
				// select only countries that at some point in time exceed
				// 10 years of education
				
					// ==>> IDENTIFY THE COUNTRIES THAT SATISFY THE CRITERIA

						preserve
							gen i = (education > 10)
							egen max = max(i),by(country)
							keep if max == 1
							drop i max
							contract country
								list
							levelsof country,local(ccc)
						restore
				
				local i = 3
				
				foreach aaa of local ccc {
					preserve
						di _new _new "COUNTRY:	`aaa'" _new
							keep if country == "`aaa'"
							
								putexcel B`i'=("`aaa'"),font(arial)
								sum education
								putexcel C`i' = (r(mean)),font(newsgott) nformat(number_d2)
							
					restore
					
					local i = `i' + 1
				}


	// 1.2 DETAILED DESCRIPTIVES
	
		putexcel F1:G1 = ("Detailed descriptive statistics"), merge
		
		sum education, detail
				
				return list
			
			putexcel G2 = rscalars
			
			putexcel F2 = ("Obs.")
			putexcel F3 = ("Sum observations = N")
			putexcel F4 = ("Overall mean")
			putexcel F5 = ("Variance")
			putexcel F6 = ("Standard deviation")
			putexcel F7 = ("Skewness")
			putexcel F8 = ("Kurtosis")
			putexcel F9 = ("Sum education")
			putexcel F10 = ("Minimum")
			putexcel F11 = ("Maximum")
			putexcel F12 = ("Percentile 1")
			putexcel F13 = ("Percentile 5")
			putexcel F14 = ("Percentile 10")
			putexcel F15 = ("Percentile 25")
			putexcel F16 = ("Percentile 50")
			putexcel F17 = ("Percentile 75")
			putexcel F18 = ("Percentile 90")
			putexcel F19 = ("Percentile 95")
			putexcel F20 = ("Percentile 99")
		
		putexcel G2:G20, italic bold right nformat(#.000)

		putexcel G2:G3, italic nformat(#.0) overwritefmt
		putexcel G9,nformat(#) noitalic nobold

// # 2. tabstat

			putexcel set descriptives.xlsx, sheet("Averages by openness") modify

				tabstat gdp education, by(open) save stat(mean)
					
					return list

					matrix open_0 = r(Stat1)'
					matrix open_1 = r(Stat2)'
				
					putexcel A3 = matrix(open_0), rownames
					putexcel C3 = matrix(open_1)
					
					putexcel B2 = ("open = 0")
					putexcel C2 = ("open = 1")
					
					putexcel A1:D1 = ("Averages of education and GDP by degree of openness"), merge
					
					putexcel describe
					
					putexcel B3:C4, nformat(#.0)
					putexcel A3:A4, bold
					putexcel B2:C2, italic border(bottom) font(arial,9,blue)

// # 3. matrix

			putexcel set descriptives.xlsx, sheet("Alternative statistics") modify
			
		preserve
			
			collapse (mean) education lngdp gdp, by(open)
			
			label var education "Education"
			label var lngdp "ln GDP"
			label var gdp "GDP"
			
				list open
				
				mkmat education - gdp,mat(main) rownames(open)
					matrix colnames main = "Education" "ln GDP" "GDP"
			
			
				putexcel B2 = matrix(main), names
				putexcel B2 = ("Openness")
				
		restore
		
		putexcel C3:E4,nformat(#.000)
		putexcel B2:E2,fpattern(gray25,blue) border(bottom)

// # 4.1 regress, simple

			putexcel set descriptives.xlsx, sheet("Regression") modify

				regress lngdp education open
					ereturn list

				putexcel B1 = ("Coef.")
					matrix b = e(b)'
					putexcel A2 = matrix(b), rownames
				
				putexcel C1 = ("Var.")
				
					mat varcovar = e(V)
					mat var = (varcovar[1,1]\varcovar[2,2]\varcovar[3,3])
					
					putexcel C2 = matrix(var)
				
				putexcel A6 = ("N = ")
				putexcel B6 = matrix(e(N))
				
				putexcel A7 = ("R^2 = ")
				putexcel B7 = matrix(e(r2))
				
				putexcel C2:C4,nformat((0.00000))
				putexcel B2:B3,nformat(#.00%)
				putexcel B4,nformat(#.00)
				putexcel A4 = ("Cons.")

// # 4.2 regress, additional features

				regress lngdp education open
				
					matrix results = r(table)
					mat l results
					
					mat b = results[1,1...]'
					mat t = results[3,1...]'
					
					putexcel E8="Coef." F8="t"
					putexcel D9 = matrix(b), rownames nformat(number_d2) right
					putexcel F9 = matrix(t),nformat("0.00")
					
// # 5. graph

			putexcel set descriptives.xlsx, sheet("Graph") modify
			
				kdensity lngdp, scheme(economist) graphregion(color(white)) ///
					legend(region(color(white))) title("") note("") lpattern(dash)
					
					graph export gdp_density.png, replace
						
						putexcel B2 = picture(gdp_density.png)

					
// # 6. loop

// 'academic' example: aggregate countries by their first letter; it could be continents; economic region, ...

gen first = substr(country,1,1)

	levelsof first,local(ff)
	
	foreach vv of local ff {
	
		di _new(3) "Country's first letter:	`vv'"
		
		preserve
		quiet keep if first == "`vv'"
		
		quiet unique country
			
			if r(unique) > 5 {
			di _new(2) "	Number of countries:	" r(unique) _new(1)
			quietly {
				collapse (mean) lngdp education,by(country)
					putexcel set descriptives.xlsx, sheet("FIRST LETTER `vv'") modify
					
					regress lngdp education
						
							matrix list r(table)
						
						matrix results = r(table)
							mat l results
						
						mat b = results[1,1...]'
						mat t = results[3,1...]'
						
						putexcel C2="Coef." F2="t"
						putexcel B3 = matrix(b), rownames nformat(number_d2) right
						putexcel D3 = matrix(t),nformat("0.00")
				}
			}
			
			if r(unique) <= 5 {
				di _new(2) "	Insufficient number of countries; n countries = " r(unique) _new(1)
			}
			
		restore
	
	}

					
timer off 1
timer list 1
				
log close
