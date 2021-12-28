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
	
		capture cd "C:\Users\reisportela_win\Dropbox\Stata/stata_training\day1\2.handlingdata\_other_examples\dates"
		capture cd "D:\miguel\Dropbox\Stata/stata_training\day1\2.handlingdata\_other_examples\dates"
		capture cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/2.handlingdata/_other_examples/dates"

// EXAMPLE: 'dates'

capture log close
log using dates.txt, text replace

// # 1. REGULAR DATES

// # 1.1 EXAMPLE 1

	use dates1, clear
		describe
		// date is in a string format
		
		list date in 1

	gen date_alt = date(date, "Y#M")	// generate a numeric date from the original date
		des date_alt
		list in 1	// one sees a number in data_alt that has no specific meaning

		format %tdMonth_dd,_CCYY date_alt
		list in 1
		
		format %tcDay_Mon_DD_CCYY date_alt
		list in 1

		format %tcDay_Mon_DD,_CCYY date_alt
		list in 1

		format %tdMonth,_CCYY date_alt
		list in 1
		
	gen year = year(date_alt)
		tab year
	
	gen month = month(date_alt)
		tab month
	
	gen ym = year(date_alt)*100 + month(date_alt)
		tab ym

	tsset id ym
		xtdes
	
	gen dwage = d.wage
		list
	
	gen mdate = monthly(date,"YM")
	
	format %tm mdate
		l in 1

	tsset id mdate
		gen dwage2 = d.wage
		list


// # 1.2 EXAMPLE 2

	use dates2, clear
		l in 1

	// help f_date

	gen date2 = date(date,"DMY",1999)
	describe

		list

	// date2 is a numeric variable that counts the days since january 1, 1960

	// now we have to format date2 according to our needs

	format %tdnn/dd/YY date2
		list

	format %tdCCYY/nn/dd date2
		list

	format %tdCCYY/Month/dd date2
		list

		display date2[5] - date2[4]
		display month(date2[5]) - month(date2[4])

	
// # 2. BUSINESS CALENDAR

// Tracking Error of Exchange-Traded Funds: Evidence from the US

use data_bcal, clear
	tab etf_ticker
	
		tsset
		gen year = year(tempo)
		gen month = month(tempo)
		
		gen lag_etf_v1 = l.etf_valor
		
		format %td tempo
		bcal create eikon, from(tempo) replace
		generate bcaldate = bofd("eikon",tempo)
		assert !missing(bcaldate) if !missing(tempo)
		format %tbeikon bcaldate
		tsset etf_id bcaldate

			gen lag_etf_v2 = l.etf_valor

	// verify the 4th of july, 2016, for etf ticker "U:VIOV"
	// in 2016 the 4th of july was on a monday, which implies that the business consecutive days are 1 and 5
	// check how etf_lag_v1 and etf_lag_v2, based on different definitions of time, deal with consecutive days
	
	list etf_ticker time bcaldate etf_valor lag_etf_v1 lag_etf_v2 if year == 2016 & month == 7 & etf_ticker == "U:VIOV"
	
		drop lag_etf_v1 lag_etf_v2 year month

		gen v_etf = d.etf_valor/l.etf_valor
		gen v_index = d.index_valor/l.index_valor
		
			drop if etf_valor == .

timer off 1
timer list 1
				
log close
