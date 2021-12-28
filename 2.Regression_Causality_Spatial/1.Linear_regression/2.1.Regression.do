//////////////////////////////////////////////////////////////////////////
// 2020 STATA ECONOMETRICS WINTER SCHOOL								//
// January 20-24, 2020													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// # 2. Linear regression						   		//
//////////////////////////////////////////////////////////

global st = "$S_TIME"									// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM


clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
set more off											// ALLOW SCREENS TO PASS BY
set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND
		
capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/1.Linear_regression"             // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\1.Linear_regression" 		// THIS IS MY WORKING FOLDER

// OLS & GLS regression //
	capture log close
	log using logs/regression1.txt, text replace

	// SIMPLE ANALYSIS OF THE RELATION BETWEEN GDP pc & EDUCATION

		use data/world_data, clear
			
		scatter logGDPpc2000 educ_sec, graphregion(color(white)) legend(region(color(white))) scheme(sj) title("GDP per capita vs Education")		// MAKE A SCATTER GRAPH
		scatter logGDPpc2000 educ_sec, title("GDP per capita vs Education")
			
			graph export graphs/Graph1.png,replace								// IF YOU CHANGE THE SUFFIX YOU CHANGE THE EXPORT FORMAT
			capture graph export graphs/Graph1.wmf,replace								// IF YOU CHANGE THE SUFFIX YOU CHANGE THE EXPORT FORMAT

		twoway lfit logGDPpc2000 educ_sec || scatter logGDPpc2000 educ_sec, graphregion(color(white)) legend(region(color(white))) scheme(sj) title("GDP per capita vs Education")
		
		twoway lfit logGDPpc2000 educ_sec || scatter logGDPpc2000 educ_sec, title("GDP per capita vs Education")
		
			
			graph export graphs/Graph2.png,replace
			capture graph export graphs/Graph2.wmf,replace

	log close



// ########################################################################### //



// MAIN REGRESSIONS

	capture log close
	log using logs/regression2.txt, text replace

		use data/world_data, clear
			

		reg growthGDPpc logGDPpc2000  educ_sec invest_growth trade2000 gov2000 	
			ereturn list									// retrive all computations associated with the regression
			estat summarize									// summarizes the variables used by the command 
			matrix list e(b)								// creates a vector with estimated coefficients
			mat betas = e(b)'								// transpose the matrix
			mat l betas										// list matrix b
			estat vce										// Variance-Covariance matrix
			estat ic						 				// Akaike's information criterion and Bayesian information criterion: the preferred model is the one with the minimum AIC or BIC value
			estat vif										// Variance inflation factor: the mean should be smaller than unity and the largest < 10

			di invttail(65,.025)							// critical values for confidence intervals with alpha=5% and N-k=65
			di 2*ttail(65,(.0325741/ .006704))				// p-value for b(educ_sec)

			test educ_sec    								// test the sgnificance of one coefficient
			testparm *2000								    // test the joint significance of a set of coefficients (logGDPpc2000,  trade2000, gov2000)
			test educ_sec=trade2000					        // test linear combinations of parameters
			testnl _b[educ_sec]/_b[trade2000]=10		    // Tests involving nonlinear combinations of parameters

		***** predicted values

		predict growthGDPpc_hat, xb							// predicted values
		
			label var growthGDPpc_hat "Predicted Growth log GDP per capita"
			
			sort educ_sec
			
			scatter growthGDPpc_hat educ_sec, graphregion(color(white)) legend(region(color(white))) scheme(sj) ///
			title("Predicted Growth log GDP per capita vs Education") 
				
			scatter growthGDPpc_hat educ_sec,  ///
			title("Predicted Growth log GDP per capita vs Education") 
					
				graph export graphs/Graph3.png,replace
				capture graph export graphs/Graph3.wmf,replace

			twoway scatter growthGDPpc_hat educ_sec || scatter growthGDPpc educ_sec, graphregion(color(white)) legend(region(color(white))) scheme(sj) title("Predicted and actual Growth log GDP p.c. vs Education") 
			
			twoway scatter growthGDPpc_hat educ_sec || scatter growthGDPpc educ_sec,  title("Predicted and actual Growth log GDP p.c. vs Education") 
				
				graph export graphs/Graph3b.png,replace	
				capture graph export graphs/Graph3b.wmf,replace	

			predict residuals_hat, residual									// predicted residuals
				label var residuals_hat "Predicted residuals"
			
			scatter  residuals_hat growthGDPpc, graphregion(color(white)) legend(region(color(white))) scheme(sj) ///
			title("Predicted residuals") 

			scatter  residuals_hat growthGDPpc,  ///
			title("Predicted residuals") 
			
				graph export graphs/Graph4.png,replace
				capture graph export graphs/Graph4.wmf,replace

			
			graph matrix growthGDPpc logGDPpc2000  educ_sec invest_growth trade2000 gov2000, graphregion(color(white)) legend(region(color(white))) scheme(sj) msize(large)		// graph of regression variables
			
			graph matrix growthGDPpc logGDPpc2000  educ_sec invest_growth trade2000 gov2000,  msize(small)		// graph of regression variables
			
				graph export graphs/Graph_matrix.png,replace
				capture graph export graphs/Graph_matrix.wmf,replace

			corr growthGDPpc logGDPpc2000 educ_sec invest_growth trade2000 gov2000
				
			avplots, graphregion(color(white)) legend(region(color(white))) scheme(sj) msize(small) col(2)		// graph with added variable plots
			
			avplots,  msize(small) col(2)		// graph with added variable plots

				
				graph export graphs/Graph_avplot.png, replace
				capture graph export graphs/Graph_avplot.wmf, replace


		lvr2plot, graphregion(color(white)) legend(region(color(white))) scheme(sj) mlabel(countrycode)			// detecting outliers
		
		lvr2plot, msize(small)  mlabel(countrycode)			// detecting outliers
		
			predict lev if e(sample), leverage
		
			predict dfits if e(sample), dfits
			
			
		// adding an interaction between investment and education

	reg growthGDPpc logGDPpc2000  c.educ_sec##c.invest_growth gov2000 trade2000
	
	
		reg growthGDPpc logGDPpc2000  c.educ_sec#c.invest_growth gov2000 trade2000
		
				reg growthGDPpc logGDPpc2000 educ_sec c.educ_sec#c.invest_growth gov2000 trade2000

		
			margins, dydx(*)								// the marginal effects evaluated at the mean of each variable

		margins, dydx(educ_sec) at(invest_growth=(0 (1) 25))			// marginal effects of education for different values of invest_growth
			marginsplot, graphregion(color(white)) legend(region(color(white))) scheme(sj)
			
			marginsplot
			graph export graphs/margins.png,replace
			capture graph export graphs/margins.wmf,replace

			
		
		gen open = (trade2000 > 100)								// generate a dummy variable equal to one for countries with openk>70
		
		reg growthGDPpc logGDPpc2000  educ_sec invest_growth trade2000 gov2000 i.open
		
		
		margins open, post
			display _b[1.open] - _b[0.open]
			test 1.open = 0.open
		
			*ssc install coefplot, replace// net install coefplot" if needed
			
			coefplot, keep(*open) vertical  // plot the coefficient of open when open=1 or open=0
		
	
		drop open

		
		// heteroskedasticity test
		reg growthGDPpc logGDPpc2000 educ_sec invest_growth gov2000 trade2000 
			estat hettest, iid								//Breusch Pagan test
			estat imtest, white							    //White's original heteroskedasticity test 	

		// "Manual" Breusch-Pagan test

			predict u, resid
			predict y_hat, xb
			gen u2=u*u

			reg u2 y_hat 

				eret li
				scalar N=e(N)
						scalar R2=e(r2)
						scalar nregressors=e(df_m)
						di "Test statistic:	" N*R2
						di "P-value: " chi2tail(nregressors,N*R2)

						drop u u2 y_hat

		// robust and cluster regression
		reg growthGDPpc logGDPpc2000 educ_sec invest_growth gov2000 trade2000 
		reg growthGDPpc logGDPpc2000 educ_sec invest_growth gov2000 trade2000 , robust

		gen open=(trade2000>100)
		reg growthGDPpc logGDPpc2000 educ_sec invest_growth gov2000 trade2000 , cluster(open)

		*** FGLS Regression

		reg growthGDPpc logGDPpc2000 educ_sec invest_growth gov2000 trade2000   [aw=logGDPpc2000] 

log close


	
