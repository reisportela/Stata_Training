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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export/putpdf"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export/putpdf"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export/putpdf"

	sysuse auto, clear

// # 1. INITIATE THE docx
	putdocx begin, pagesize(A4) font(Arial,12)

// # 2. create the first paragrph
	putdocx paragraph
		
		// write a sentence in the first paragraph
			putdocx text ("WINTER SCHOOL 2019, JAN 2019"), italic

// # 3. start a new paragraph
	putdocx paragraph
		putdocx text ("FEP - Porto"), bold

	
// # 4. TABLES
	
	// # 4.1 put a table in the docx using information from a tabulation
	
	putdocx paragraph
		putdocx text ("Put a table in the docx "),underline
		putdocx text ("using information from a tabulation")
	
		tab foreign, matcell(tmp1)
				matrix rownames tmp1 = "Domestic" "Foreign"
				matrix colnames tmp1 = "Frequency"
				mat l tmp1
			putdocx table tb1 = matrix(tmp1), colnames rownames nformat(%2.0f) ///
				border(start, nil) border(end, nil) border(insideV, nil)

	// # 4.2
	
		putdocx table tb = (2,2)
		
			putdocx table tb(1,1) = ("A")
			putdocx table tb(1,2) = (23.345)
			putdocx table tb(2,1) = ("BB")
			putdocx table tb(2,2) = (89)
			
			putdocx table tb(1,2), nformat(%3.1f)

//putdocx save putdocx_example.docx, replace

// build your own program
// we compute descriptive statistics using the command 'tabstat'
// and add a graph

	capture program drop gg
	prog define gg

				local asd = "`1'"
				local lower = `2'
				local upper = `3'
				

		putdocx paragraph
			putdocx text ("Variable:	`: var l `asd''")

					
		tabstat `asd',by(foreign) stat(N mean sd p10 p50 p90) save
			return list
			
			mat a1 = r(Stat2)'
			mat a2 = r(Stat1)'

			mat m1 = (a1\a2)
				mat l m1
				matrix rownames m1 = "Domestic" "Foreign"
				mat l m1

			putdocx table hh = matrix(m1), colnames rownames nformat(%2.0f)
			putdocx table hh(.,.), halign(center)

							twoway (kdensity `asd' if foreign == 0 & `asd' >= `lower' & `asd' <= `upper') || (kdensity `asd' if foreign == 1 & `asd' >= `lower' & `asd' <= `upper', lpattern(dash_dot_dot)), ///
								legend(label(1 "Domestic") label(2 "Foreign")) title("`: var l `asd''") ///
								xtitle("`asd'") ytitle("Density") scheme(s1mono) xlabel(#5) xlabel(#5) ///
								graphregion(color(white)) bgcolor(white) legend(region(lwidth(none)))
								
								graph export graphs/`asd'.png, replace

			putdocx paragraph

					putdocx paragraph, halign(center)
						putdocx image graphs/`asd'.png, width(5)


	end

local vars = "price mpg"

foreach asd of local vars {
sum `asd', detail
	gg `asd' r(p5) r(p95)

}

// 5. write text with automatic statistics

	quietly sum price
		local mean : display %4.1f `r(mean)'
		putdocx paragraph
		putdocx text ("The average price is ")
			 putdocx text ("`mean'"),bold

// # 6. export regression results
	
	gen ln_price = ln(price)
	gen ln_mpg = ln(mpg)
		
		label var ln_price "Ln Price"
		label var ln_mpg "Ln MPG"
		
		reg ln_price ln_mpg
		
			putdocx table reg = etable
	
	// drop the constant
	
		putdocx table reg(3,.), drop
		putdocx table reg(.,5), drop

			 
// # 7. save the docx file

putdocx save putdocx_example.docx, replace

