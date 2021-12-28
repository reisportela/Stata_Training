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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\4.output_export/putdocx"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\4.output_export/putdocx"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/4.output_export/putdocx"

	sysuse auto, clear


putdocx begin, pagesize(A4) font(Arial,12)

putdocx paragraph
	putdocx text ("WINTER SCHOOL 2019, JAN 2019")

putdocx paragraph
	putdocx text ("FEP - Porto")

	
/////////////////////////

	tab foreign, matcell(q1)
			matrix rownames q1 = "Domestic" "Foreign"
			mat l q1
		putdocx table qq = matrix(q1), colnames rownames nformat(%2.0f)

/////////////////////////

capture prog drop gg
prog def gg

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

putdocx save putdocx_example.docx, replace




prog define test

	tabstat `1',by(`2') stat(`3')

end
