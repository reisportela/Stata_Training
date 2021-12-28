//////////////////////////////
// Applied Econometrics		//
// Universidade do Minho	//
// October, 2021			//
// Miguel Portela			//
//////////////////////////////

// STATIC PANEL DATA
	clear all
	set more off
	set matsize 800
	set rmsg on
	
	timer on 1
	
		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/panel_simulation/logs"

capture log close
log using iv_panel_simulation.txt, text replace

****** 10000 observations ******

// build simulated data
set obs 10000			// define the number of observations
set seed 345567789		// define the 'seed' in order to be able to replicate the results

// define worker's id and year of observation
gen workerid = int(_n/10.1)+1
bysort workerid: gen ano = _n

sort workerid ano
tsset workerid ano

// generate individual's specific effect, ui
bysort workerid (ano): gen double ui = runiform() if _n == 1
     bysort workerid (ano): replace ui = ui[_n-1] if _n > 1

// build the instrument, q1
bysort workerid (ano): gen quarter= int(4*uniform()+1) if _n == 1
     bysort workerid (ano): replace quarter = quarter[_n-1] if _n > 1
	 
	gen q1=(quarter==1)

// build education and experience; education is a function of ui, the worker specific effect, as well as the instrument, q1
bysort workerid (ano): gen educ= int(16*uniform())*ui if _n == 1
	bysort workerid (ano): replace educ= educ - 3*q1 if _n == 1
	
	bysort workerid (ano): replace educ = educ[_n-1] + round(uniform()) if _n > 1
	egen sd = sd(educ),by(workerid)
		sum sd, detail
		drop sd

bysort workerid (ano): gen exper= int(20*uniform()) if _n == 1
	bysort workerid (ano): replace exper = exper[_n-1] + 1 if _n > 1
	
	gen exper2 = exper^2

// generate the true log wage equation, where the error term is defined by 'uniform()/ln(485)'; 485 is the minimum wage
gen double lnwage = ln(485) + 0.06*educ + 0.007*exper - 0.00001*exper2 + 0.02*ano + ui + uniform()/ln(485)

// # 1. OLS

reg lnwage educ exper exper2
reg lnwage educ exper exper2 i.ano ui

reg lnwage educ exper exper2 i.ano
	est store OLS
	outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
		*/ keep(educ exper exper2) nocons/*
		*/ word label addnote(Sourse: Own computations; simulated data) replace ctitle(OLS) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

// # 2. PANEL
xtreg lnwage educ exper exper2 i.ano, re theta
	est store RE
	outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
		*/ keep(educ exper exper2) nocons/*
		*/ word label addnote(Sourse: Own computations; simulated data) append ctitle(RE) /*
		*/ adds(RMSE, e(rmse))

// discuss why some time dummies are dropped
xtreg lnwage educ exper exper2, fe	// omit the time dummies

xtreg lnwage educ exper exper2 i.ano, fe	// complete model
	est store FE
	outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
		*/ keep(educ exper exper2) nocons/*
		*/ word label addnote(Sourse: Own computations; simulated data) append ctitle(FE) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))
	
	hausman FE RE

// # 3. IV
    preserve
		bysort workerid (ano): keep if _n==1    // cross-section
        xi: ivreg2 lnwage (educ = q1) exper exper2 i.ano, first
		est store IV
		outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
			*/ keep(educ exper exper2) nocons/*
			*/ word label addnote(Sourse: Own computations; simulated data) append ctitle(IV) /*
			*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))
    restore

// # 4. PANEL + IV

// explain why education is dropped in the following regression
xtivreg lnwage (educ=q1) exper exper2 i.ano, fe
	est store FE_IV
	outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
		*/ keep(educ exper exper2) nocons/*
		*/ word label addnote(Sourse: Own computations; simulated data) append ctitle(FE_IV)

// comparar os resultados do ivreg2 com os do xtivreg2, re - explicar/debater
xtivreg lnwage (educ=q1) exper exper2 i.ano, re
	est store RE_IV
	outreg2 using iv_panel_simulationdoc, dec(4) alpha(0.001, 0.01, 0.05) sortvar(educ exper exper2) /*
		*/ keep(educ exper exper2) nocons/*
		*/ word label addnote(Sourse: Own computations; simulated data) append ctitle(RE_IV)

// discuss the underlying problems with this exercise
estimates dir
est stats OLS RE FE IV FE_IV RE_IV

	estimates table OLS RE FE IV FE_IV RE_IV, keep(educ exper exper2) b(%7.4f) se(%7.4f) stats(N r2_a)
	estimates table OLS RE FE IV FE_IV RE_IV, keep(educ exper exper2) b(%7.4f) star stats(N r2_a)
	sh start iv_panel_simulationdoc.rtf	// execute a DOS command == !start iv_panel_simulationdoc.rtf

timer off 1
timer list 1

log close
