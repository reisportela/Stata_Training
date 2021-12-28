//////////////////////////////
// Applied Econometrics		//
// Universidade do Minho	//
// October, 2021			//
// Miguel Portela			//
//////////////////////////////

// STATIC PANEL DATA: detail

	clear all
	set more off
	set matsize 800
	set rmsg on
	
	timer on 1
	

		capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/logs"


capture log close
log using static_panel_detailed_programing.txt, text replace

// # 0. SOME INTRODUCTORY COMMANDS

	/*
		use http://www.stata-press.com/data/r12/nlswork, clear
		save ../data/nlswork, replace
	*/

	use ../data/nlswork, clear
		xtset
		des
		xtdes
		xtdes, pa(20)
		xtsum hours
		sum hours
	clear all


// # 1. PANEL DATA ANALYSIS, STATIC
// ssc install listtab

use ../data/tablef7_1, clear

	listtab c q pf using table.txt, rstyle(tabdelim) replace	// lists the variables in the varlist

	xtset i t
		des
		xtdes
		xtsum

	gen lncost=ln(c)
	gen lnoutput=ln(q)
	gen lnoutput2=lnoutput^2
	gen lnfuelprice=ln(pf)

	label var lnoutput "Output"
	label var lnfuelprice "Fuel Price"
	label var lf "Load Factor"

// A. OLS (see 'OLS MANUAL PROGRAMMING' at the end of the file)

reg lncost lnoutput lnfuelprice lf
	est store OLS
	outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf) keep(lnoutput lnfuelprice lf) nocons/*
		*/	word label addnote(Source: Own computations; Greene, 2008) replace ctitle(OLS) /*
		*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))
	
	scalar beta_ols = _b[lnoutput]
	
// B. ESTIMATION STEP-BY-STEP: FE ESTIMATOR based on demeaned variables

	// TRANSFORM THE VARIABLES

		egen double mlncost=mean(lncost),by(i)
		egen double mlnoutput=mean(lnoutput),by(i)
		egen double mlnfuelprice=mean(lnfuelprice),by(i)
		egen double mlf=mean(lf),by(i)

		gen double dlncost=lncost-mlncost
		gen double dlnoutput=lnoutput-mlnoutput
		gen double dlnfuelprice=lnfuelprice-mlnfuelprice
		gen double dlf=lf-mlf
		
		// demean using a loop and the command 'center'
		
		capture ssc install center
		
		local vars = "lncost lnoutput lnfuelprice lf"
		foreach v of local vars {
			di _new _new "VARIABLE:	`v'" _new
			bysort i: center `v', generate(dd`v')
			compare d`v' dd`v'	// compare the variables created using the two methods
		}

	// FE ESTIMATOR
		reg ddlncost ddlnoutput ddlnfuelprice ddlf
		reg dlncost dlnoutput dlnfuelprice dlf

		// BUILD THE VARIANCE-COVARIANCE MATRIX (CORRECTED)
			gen e2_fe=(dlncost-_b[_cons]-dlnoutput*_b[dlnoutput]-dlnfuelprice*_b[dlnfuelprice]-dlf*_b[dlf])^2
			egen se2_fe=total(e2_fe)
				ereturn list
			scalar k=e(df_m)
			scalar N=e(N)
			count if i[_n]~=i[_n-1]
			scalar n=r(N)
			scalar sigma2_fe=se2_fe/(N-n-k)

			mat acc xx=dlnoutput dlnfuelprice dlf
			mat ss_fe=sigma2_fe*inv(xx)
			mat l ss_fe

		// STANDARD-ERRORS OF EACH ONE THE b (beta_^)
			di ss_fe[1,1]^.5
			di ss_fe[2,2]^.5
			di ss_fe[3,3]^.5

// C. LSDV
	reg lncost lnoutput lnfuelprice lf i.i
		est store LSDV
		outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
			*/ word label addnote(Source: Own computations; Greene, 2008) append ctitle(LSDV) /*
			*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))
			
		// obtain the vector of betas
			mat def betas = e(b)'
				mat l betas
				mat betas0 = betas[4..9,.]
				mat l betas0

		// test for the presence of fixed-effects
			testparm i.i

		// TEST FOR THE PRESENCE OF FIXED EFFECTS: manual procedure
			reg lncost lnoutput lnfuelprice lf i.i	/* LSDV */
				ereturn list
				scalar r2lsdv=e(r2)
				scalar mflsdv=e(df_m)
				scalar dflsdv=e(df_r)

			reg lncost lnoutput lnfuelprice lf			/* OLS */
				ereturn list
				scalar r2pooled=e(r2)
				scalar mfpooled=e(df_m)

			di "Test for the presence of fixed effects; F statistic:   " ((r2lsdv-r2pooled)/(mflsdv-mfpooled))/((1-r2lsdv)/(dflsdv))
			scalar fstatistic=((r2lsdv-r2pooled)/(mflsdv-mfpooled))/((1-r2lsdv)/(dflsdv))
			di "Test for the presence of fixed effects; p-valor:   " Ftail(mflsdv-mfpooled,dflsdv,fstatistic)
	
// D. ESTIMATION WITH THE AUTOMATIC PROCEDURE
	xtreg lncost lnoutput lnfuelprice lf, fe
		est store FE
		outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
			*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(FE) /*
			*/ adds(RMSE, e(rmse), LogLikelihood, e(ll), F test that all u_i=0, e(F_f))
		
		scalar beta_fe = _b[lnoutput]
		
		test lnoutput = beta_ols

			// predict the specific effect
			predict mu, u
			sum mu
			
			// produce a graph with the specific effects
			preserve
				collapse (mean) mu,by(i)
				svmat betas0
				list
				compare mu betas0	// one is the reparametrization of the other
				twoway bar mu i
				twoway bar betas0 i
			restore


// E. BETWEEN-GROUPS ESTIMATOR
	bysort i (t): gen first=1 if _n==1			/* WE ONLY USE n OBSERVATIONS */

	reg mlncost mlnoutput mlnfuelprice mlf if first==1

		predict e if e(sample), resid
		gen e2=e^2
		egen se2=total(e2)
			ereturn list /* LIST THE VALUES IN STATA'S MEMORY */
		scalar k=e(df_m)
		scalar N=e(N)
		scalar sigma2_b=se2/(N-k-1)
			drop e e2 se2

// F. AUTOMATIC PROCEDURE
	xtreg lncost lnoutput lnfuelprice lf, be
		est store BE
		outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
			*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(BE) /*
			*/ adds(RMSE, e(rmse), LogLikelihood, e(ll))

		test lnoutput = beta_ols
		test lnoutput = beta_fe

	
// G. INTRODUCE TIME EFFECTS
	// OLS
		reg lncost lnoutput lnfuelprice lf i.t

		mat dir
			mat drop _all
				mat dir

	// FE
		xtreg lncost lnoutput lnfuelprice lf i.t, fe
		est store FE_time
		outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
			*/	word label addnote(Source: Own computations; Greene, 2008) append ctitle(FE_time) /*
			*/ adds(RMSE, e(rmse), LogLikelihood, e(ll), F test that all u_i=0, e(F_f))
	
		// test if the current estimate for the parameter of lnoutput is identical to the one obtained from OLS and FE without time effects
		test lnoutput = beta_ols
		test lnoutput = beta_fe

		mat betas = e(b)'
		mat l betas
		mat betas_time = betas[4..18,.]
		mat l betas_time
		
		preserve
			clear
			set obs 15
			gen time = _n
			svmat betas_time
			scatter betas_time time
		restore

	// JOINT SIGNIFICANCE TEST FOR THE TIME DUMMIES
		testparm i.t

// H. RANDOM EFFECTS ESTIMATOR
	
	tab t	/* NUMBER OF YEARS */
	ret li
		scalar T=r(r)

	scalar sigma2_alpha=sigma2_b-sigma2_fe/T
	scalar psi=sigma2_fe/(sigma2_fe+T*sigma2_alpha)
		scalar stheta=1-psi^(.5)
			di stheta

		gen double drelncost=lncost-stheta*mlncost
		gen double drelnoutput=lnoutput-stheta*mlnoutput
		gen double drelnfuelprice=lnfuelprice-stheta*mlnfuelprice
		gen double drelf=lf-stheta*mlf

		reg drelncost drelnoutput drelnfuelprice drelf
		mat V=e(V)
			di _b[_cons]/(1-stheta)									// correct the estimation of the constant term and of its
			di (V[4,4]/((1-stheta)^2))^.5							// standard error

	// AUTOMATIC PROCEDURE
	xtreg lncost lnoutput lnfuelprice lf, re
		est store RE	
		outreg2 using mainregs, dec(4) sortvar(lnoutput lnfuelprice lf)  keep(lnoutput lnfuelprice lf) nocons /*
			*/ word label addnote(Source: Own computations; Greene, 2008) append ctitle(RE) /*
			*/ adds(RMSE, e(rmse), rho, e(rho))		/// SEE OUTPUT TABLE
		
		test lnoutput = beta_fe

	// TEST FOR RANDOM EFFECTS (Breush & Pagan, 1980)
	reg lncost lnoutput lnfuelprice lf
		predict res, resid
		gen res2=res^2
		egen mres=mean(res),by(i)
		egen nobsT=count(i),by(i)
		bysort i (t): gen Tmres2=(nobsT*mres)^2 if _n==1
		egen sTmres2=total(Tmres2)
		egen sres2=total(res2)
		count if i[_n]~=i[_n-1]
		gen n=r(N)
		di "LM = " ((n*nobsT)/(2*(nobsT-1)))*((sTmres2/sres2-1)^2)
		scalar LM = ((n*nobsT)/(2*(nobsT-1)))*((sTmres2/sres2-1)^2)
	
		// COMPUTE THE p-value FOR THE TEST
			di chi2tail(1,LM)

	// TEST IF THE RANDOM EFFECTS IS A VALID PROCEDURE: HAUSMAN TEST
		
		//manual
			xtreg lncost lnoutput lnfuelprice lf, i(i) fe
				est store fe
			mat uvar=e(V)
			mat l uvar
				mat uvar=uvar[1..3,1..3]
			mat ub=e(b)
				mat ub=ub[1,1..3]
			mat l ub

			xtreg lncost lnoutput lnfuelprice lf, i(i) re
				est store re

			mat bvar=e(V)
			mat l bvar
				mat bvar=bvar[1..3,1..3]
			mat bb=e(b)
			mat l bb
				mat bb=bb[1,1..3]
			mat test=((ub'-bb')')*inv(uvar-bvar)*(ub'-bb')
			mat l test
			di chi2tail(colsof(bb),test[1,1])

		// automatic
			hausman fe re

// OLS manual programming

	sysuse auto, clear
		
		egen rmiss = rowmiss(price mpg rep78 foreign)
			tab rmiss
		
		putmata y = price X = (mpg rep78 foreign 1) if rmiss == 0

		mata
			betas = invsym(X'X)*X'*y
			betas
			e = X*betas
			n = rows(X)
			k = cols(X)
			n
			k
			varcovar = ((e'e)/(n-k))*invsym(X'X)
			varcovar
			betas
		end
		
		mata: betas
		
mata

// # 1. betas

	y = st_data(., "price")

	X    = st_data(., "mpg rep78 foreign")

	n0    = rows(X)

	X    = X,J(n0,1,1)

	XpX  = quadcross(X, X)

	XpXi = invsym(XpX)
	
		n = XpX[4,4]		// actual sample size omiying missing values
		k = cols(X)

	b    = XpXi*quadcross(X, y)

// # 2. varcovar
	
	e = y - X*b

	e2 = e:^2

	k = cols(X)

	V = (quadsum(e2)/(n-k))*XpXi

	se = sqrt(diagonal(V))'

end		
	
	mata: b'
	mata: V
	mata: se

		regress price mpg rep78 foreign

// robust standard-errors

mata
	M    = quadcross(X, e2, X)

	V    = (n/(n-k))*XpXi*M*XpXi

	se_robust = sqrt(diagonal(V))'
end

	mata: se_robust
	
		regress price mpg rep78 foreign, robust
	

timer off 1
timer list 1

log close
