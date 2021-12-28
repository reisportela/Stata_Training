// Stata Minho 2021
* M Portela

clear all
set more off

cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/1.menus"

capture log close
log using logs/first_programme.txt, text replace

sysuse auto

// # 1. descriptive statistics

	codebook, compact
	tabstat price,by(foreign) stat(N mean sd p10 p25 p90 p99)
	kdensity price
		graph export graphs/fig1.png, replace
	
	twoway (scatter price mpg)
	
	summarize

// # 2. regression analysis

	gen ln_price = ln(price)
	
	regress ln_price mpg
		estimates store r1
		
		
	regress ln_price mpg rep78 foreign
		estimates store r2
		
	estimates table r1 r2,star(.1 .05 .01)



log close
