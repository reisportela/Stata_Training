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

// # 1. INITIATE THE PDF
	putpdf begin, pagesize(A4) font(Arial,12)

// # 2. create the first paragrph
	putpdf paragraph
		
		// write a sentence in the first paragraph
			putpdf text ("WINTER SCHOOL 2019, JAN 2019"), italic

// # 3. start a new paragraph
	putpdf paragraph
		putpdf text ("FEP - Porto"), bold

	
// # 4. TABLES
	
	// # 4.1 put a table in the pdf using information from a tabulation
	
	putpdf paragraph
		putpdf text ("Put a table in the pdf "),underline
		putpdf text ("using information from a tabulation"),bgcolor("yellow")
	
		tab foreign, matcell(tmp1)
				matrix rownames tmp1 = "Domestic" "Foreign"
				matrix colnames tmp1 = "Frequency"
				mat l tmp1
			putpdf table tb1 = matrix(tmp1), colnames rownames nformat(%2.0f) ///
				border(start, nil) border(end, nil) border(insideV, nil)

	// # 4.2
	
		putpdf table tb = (2,2)
		
			putpdf table tb(1,1) = ("A")
			putpdf table tb(1,2) = (23.345)
			putpdf table tb(2,1) = ("BB")
			putpdf table tb(2,2) = (89)
			
			putpdf table tb(1,2), nformat(%3.1f)

//putpdf save putpdf_example.pdf, replace

// build your own program
// we compute descriptive statistics using the command 'tabstat'
// and add a graph

	capture program drop gg
	prog define gg

				local asd = "`1'"
				local lower = `2'
				local upper = `3'
				

		putpdf paragraph
			putpdf text ("Variable:	`: var l `asd''")

					
		tabstat `asd',by(foreign) stat(N mean sd p10 p50 p90) save
			return list
			
			mat a1 = r(Stat2)'
			mat a2 = r(Stat1)'

			mat m1 = (a1\a2)
				mat l m1
				matrix rownames m1 = "Domestic" "Foreign"
				mat l m1

			putpdf table hh = matrix(m1), colnames rownames nformat(%2.0f)
			putpdf table hh(.,.), halign(center)

							twoway (kdensity `asd' if foreign == 0 & `asd' >= `lower' & `asd' <= `upper') || (kdensity `asd' if foreign == 1 & `asd' >= `lower' & `asd' <= `upper', lpattern(dash_dot_dot)), ///
								legend(label(1 "Domestic") label(2 "Foreign")) title("`: var l `asd''") ///
								xtitle("`asd'") ytitle("Density") scheme(s1mono) xlabel(#5) xlabel(#5) ///
								graphregion(color(white)) bgcolor(white) legend(region(lwidth(none)))
								
								graph export graphs/`asd'.png, replace

			putpdf paragraph

					putpdf paragraph, halign(center)
						putpdf image graphs/`asd'.png, width(5)


	end

local vars = "price mpg"

foreach asd of local vars {
sum `asd', detail
	gg `asd' r(p5) r(p95)

}

// 5. write text with automatic statistics

	quietly sum price
		local mean : display %4.1f `r(mean)'
		putpdf paragraph
		putpdf text ("The average price is ")
			 putpdf text ("`mean'"),bold

// # 6. export regression results
	
	gen ln_price = ln(price)
	gen ln_mpg = ln(mpg)
		
		label var ln_price "Ln Price"
		label var ln_mpg "Ln MPG"
		
		reg ln_price ln_mpg
		
			putpdf table reg = etable
	
	// drop the constant
	
		putpdf table reg(3,.), drop
		putpdf table reg(.,5), drop
		putpdf table reg(.,6), drop
			 
// # 7. save the pdf file

putpdf save putpdf_example.pdf, replace

