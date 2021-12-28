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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\3.dataanalysis\graphs"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\3.dataanalysis\graphs"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/3.dataanalysis/graphs"
capture log close
log using logs/graphs.txt, text replace


	use data/graph_data, clear

	// # 1. describe the data
			codebook, compact			



	// # 2. Histogram

		// # 2.1
			histogram education if year == 2000
		
		// # 2.2
			histogram education if year == 2000, normal
		
		// # 2.3
			histogram education if year == 2000, freq addlabels

		// # 2.4
			histogram education, ytitle(Densidade) xtitle(Educacao) xlabel(1 3 5 7 9 12) title(Distribuicao da Educacao em 2020)



	// # 3. Scatter

		// # 3.1 full command
			graph twoway scatter lngdp education
		
		// # 3.2 we do not need twoway
			twoway scatter lngdp education
		
		// # 3.3 for this type of graph we can just type
			scatter lngdp education
		
		// # 3.4.a schemes, option a: use set scheme
			scatter lngdp education || lfit lngdp education
				set scheme economist
			scatter lngdp education || lfit lngdp education
				set scheme s2mono
			scatter lngdp education || lfit lngdp education
		
	
	set scheme s2color // set scheme back


		// # 3.4.a schemes, alternative: define the scheme as an option to the graph command
			scatter lngdp education, scheme(sj)
		
		// # 3.5.b overlap two graphs; in this example the 2nd graph is a linear fit
			scatter lngdp education || lfit lngdp education, scheme(sj)
		
		// # 3.5.c overlap two graphs; in this example the 2nd graph is a polynomial fit
			scatter lngdp education || fpfit lngdp education, scheme(s2color)
		
		// # 3.6 combine a set of graphs with overlap; save the intermediate graphs
			scatter lngdp education if year == 1960 || lfit lngdp education if year == 1960, scheme(s1mono) xlabel(0(2)12) ylabel(6(1.5)12) ///
					title(Income vs. Education: 1960)legend(region(lwidth(none)) cols(1)) saving(graphs/inc_educ_60, replace)
		
			scatter lngdp education if year == 2000 || lfit lngdp education if year == 2000, scheme(s1mono) /*
					*/ xlabel(0(2)12) ylabel(6(1.5)12) saving(graphs/inc_educ_00, replace) /*
					*/ title(Income vs. Education: 2000)legend(region(lwidth(none)) cols(1))
				
			graph combine graphs/inc_educ_60.gph graphs/inc_educ_00.gph, note(Source: Own computations.) graphregion(color(white))
				graph export graphs/inc_educ.png, replace	// APPROPRIATE FOR WORD FILES; open the file 'inc_educ.wmf' with Windows Explorer
				graph export graphs/inc_educ.eps, replace	// APPROPRIATE FOR LATEX FILES

			

	// # 4. Line

		// # 4.1
			line lngdp year if country == "denmark"
		
		// # 4.2
			twoway (line education year if country == "sweden", c(dash)) (line education year if country == "united states",c(l)), ///
					yline(9) xline(1980) xlabel(1960(5)2000) ///
					text(12.25 1985 "United States", placement(e)) text(11.25 1990 "Sweden", placement(e)) ///
					scheme(s2mono) ylabel(6 9 10 12) legend(off) note(Source: Own Computations.) ///
					xtitle(Year of observation) ytitle(Average education)
			
				graph export graphs/education_pt_us.png, replace

			

	// # 5. Whisker plot ("grafico de extremos e quartis")
		
		// # 5.1 basic box plot
			graph box education if year == 2000

		// # 5.2 box plot of education for two different years
		// preserve & restore the data
			preserve
				keep if year == 1960 | year == 2000
				tab year
				graph box education, by(year)
			restore

		// # 5.3 box plot of education for two different years
			graph box education if (country == "denmark" | country == "portugal" | ///
					country == "united states" | country == "italy" | country == "spain"), ///
					over(country, label(alternate) sort(lngdp)) ///
					graphregion(color(white)) bgcolor(white) scheme(s2mono) ///
					title("Distribution of education by country") ///
					subtitle("(countries ordered by average gdp)") ///
					note("Source: own computations.")
				
				graph export graphs/boxplot_education.tif, replace

			

	// # 6. PIE
		
		// # 6.1 Example 1
		graph pie gdp if (country == "denmark" | country == "portugal" | country == "united states") & year == 2000, ///
					scheme(s2color) over(country) title(Income share among countries) ///
					plabel(1 percent, size(*1.5) color(white) format(%3.1f)) ///
					plabel(2 percent, size(*1.5) color(white) format(%3.1f)) ///
					plabel(3 percent, size(*1.5) color(white) format(%3.1f)) ///
					legend(on) plotregion(lstyle(none)) ///
					note("Source: Own computations.")
					
			graph export graphs/pie_1.png, replace

		// # 6.2 Example 2
		graph pie gdp if (country == "denmark" | country == "portugal" | country == "united states") & year == 2000, ///
					scheme(s2color) over(country) title(Income share among countries) ///
					plabel(1 name, size(*1.5) color(white)) ///
					plabel(2 name, size(*1.5) color(white)) ///
					plabel(3 name, size(*1.5) color(white)) ///
					legend(off) plotregion(lstyle(none)) ///
					note("Source: Own computations.")
			
			graph export graphs/pie_2.png, replace



	// # 7. DOT graph
		
		// # 7.1 utilizar o menu
			
			// help graph dot
			// Graphics > Dot chart
			// country == "portugal" | country == "spain"
			// a. Main: Statistic = mean; Variables: education
			// b. Categories: tick Group 1 and choose as grouping variable 'country'
			// c. if/in: expression + Create..., country == "portugal" | country == "spain"
			// d. Y axis: Title:, Average education
			// e. Titles, Title: "Countries' education, 1960-2000"
			
			// outcome
			
			graph dot (mean) education if country == "portugal" | country == "spain", /*
				*/ over(country) ytitle(Average education) title("Countries' education, 1960-2000")
				
				// optional
				
						// start graph editor
						// activate the record button
						// add box to legend
						// replace spain by Spain
						// replace portugal by Portugal
						// stop recording
						// save the resulting grc file in your working folder
						// open the .grc file with Stata doedit
						// the following lines are used to replicate the above changes to the graph

							gr_edit scaleaxis.title.style.editstyle drawbox(yes) editcopy

							gr_edit grpaxis.major.num_rule_ticks = 0
							gr_edit grpaxis.edit_tick 1 25 `"Spain"', tickset(major)

							gr_edit grpaxis.major.num_rule_ticks = 0
							gr_edit grpaxis.edit_tick 2 75 `"Portugal"', tickset(major)

		
		
		// # 7.2 'simple formulation'
			graph dot (mean) education if (country == "denmark" | country == "portugal" | ///
					country == "united states" | country == "italy" | country == "spain"), ///
					over(country, sort((mean) lngdp))
		
		// # 7.3 add scheme, title and legend
			separate education, by(open)
			label var education0 "Low openness"
			label var education1 "High openness"

			graph dot (mean) education0 education1 if (country == "denmark" | country == "portugal" | ///
					country == "united states" | country == "italy" | country == "spain"), ///
					over(country, sort((mean) lngdp)) scheme(sj) ytitle("Education") ///
					legend(label(1 "Low openness") label(2 "High openness"))

		// # 7.4 increase the complexity of the graph
			sum education if year == 2000,detail
				
				global a = r(p50)
				global b = r(p10)
				local c = r(p90)
			
			graph dot (mean) education if (country == "denmark" | country == "portugal" | country == "united states" | country == "italy" | country == "spain"),over(country, sort((max) lngdp)) ///
				title("Maximum level of education between 1960 and 2000", span) ///
				note("Notes: Countries are ordered by maximum GDP." "Values in the axis are percentiles 10, 50 and 90 of education, respectively, in 2000.") ///
				ytitle("Education") yline($a $b `c') ylabel($a $b `c',format(%3.1g)) ///
				graphregion(color(white)) bgcolor(white) scheme(s2color)
			
			// export the graph in .png format; other formats are, for example, .tif, .eps or .wmf
			graph export graphs/example1.png, replace
			graph export graphs/example1.eps, replace
	

		
	// # 8. Kernel density
		
		// # 8.1 basic kernel
			kdensity lngdp if year == 2000, bwidth(100)
		
		// # 8.2 overlap two densites for different years
			twoway (kdensity lngdp if year == 1960, lpattern(dash)) || (kdensity lngdp if year == 2000), ///
				legend(label(1 "Year 1960") label(2 "Year 2000")) scheme(economist) ///
				xtitle("ln GDP") ytitle("Density")
		
		// # 8.3 extended use of kernel density
		
			twoway (kdensity lngdp if open == 0) || (kdensity lngdp if open == 1, lpattern(dash_dot_dot)), ///
				legend(label(1 "Low-Open") label(2 "High-Open")) title(Income by Openness) ///
				xtitle("Log (Income)") ytitle("Density") scheme(economist)
				
					graph export graphs/density.png, replace

	set scheme s2color

timer off 1
timer list 1
				
log close
