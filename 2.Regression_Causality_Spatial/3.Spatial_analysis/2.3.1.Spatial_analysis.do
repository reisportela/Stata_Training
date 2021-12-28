//////////////////////////////////////////////////////////////////////////
// 2020 STATA ECONOMETRICS WINTER SCHOOL								//
// January 20-24, 2020													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// # 2.3. Spatial analysis						   		//
//////////////////////////////////////////////////////////

	

	global st = "$S_TIME"									// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM


	clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
	set more off											// ALLOW SCREENS TO PASS BY
	set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND
			
	capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/2.Regression_Causality_Spatial/3.Spatial_analysis"                           // THIS SHOULD BE YOUR DIRECTORY
	capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\3.Spatial_analysis" 		// THIS IS MY WORKING FOLDER


	*** first, download the NUTS 2016 zip file at ///
	 /// "https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts16"

	import delimited "data/NUTS_AT_2016.csv", varnames(1) 
	ren nuts_id NUTS_ID
	sort NUTS_ID 
	save data/nuts_europe, replace

clear
spshape2dta data/NUTS_RG_10M_2016_3035, replace /// Creating the Stata format shapefile

use NUTS_RG_10M_2016_3035

describe

merge 1:1 NUTS_ID using data/nuts_europe
replace NUTS_NAME= nuts_name if NUTS_NAME==""
replace CNTR_CODE= cntr_code if CNTR_CODE==""

drop nuts_name cntr_code _merge

save map_nuts_europe, replace

*** import unemployment rate data from eurostat

clear

 eurostatuse lfst_r_lfu3rt, noflags nolabel long geo()
 keep if time==2016
 ren geo NUTS_ID
 keep if age=="Y15-74"
 keep if sex=="T"	
 
 sort NUTS_ID
 
 save unemp_eur, replace
 
*** import educational attainment levelt data from eurostat
//net install eurostatuse.pkg, from("http://fmwww.bc.edu/RePEc/bocode/e/") replace

 clear
 eurostatuse edat_lfse_04, noflags nolabel long geo()
 keep if time==2016
 ren geo NUTS_ID
 keep if isced11=="ED5-8"  /// keep tertiary education
 
 sort NUTS_ID

 keep if sex=="T"	
 save tert_educ_eur, replace

  
*** merge map with unemployment data and college attainment data
 
use map_nuts_europe, clear

	sort NUTS_ID
 
	merge 1:m NUTS_ID using unemp_eur
	keep if _merge==3
	drop _merge
	
	merge 1:m NUTS_ID using tert_educ_eur
	keep if _merge==3
	drop _merge



*** analysing the data

describe

ren lfst_r_lfu3rt unemp_rate
ren edat_lfse_04 tert_educ_rate

sum unemp_rate	tert_educ_rate
	
*** my first map
	
grmap unemp_rate	

grmap unemp_rate,								///	
 clbreaks(0 4 8 12 16 20 24 28 32) clmethod(custom)	///
        title("Unemployment Rate", size(*0.8))      ///
        subtitle("EU 2016", size(*0.8))       

graph export unemp_ue.wmf, replace
	
	
*** Fit a linear regression of the unemployment rate on the college graduation rate		
reg unemp_rate tert_educ_rate


	
*** Create a contiguity matrix
keep if e(sample)

spmatrix create contiguity W, replace


estat moran, errorlag(W) /// The test reports that we can reject that the residuals from the model above are independent and
						/// identically distributed (i.i.d.). In particular, the test considered the alternative hypothesis that residuals
						/// are correlated with nearby residuals as defined by W.
	
	
	
*** Fitting models with a spatial lag of the dependent variable

spregress unemp_rate tert_educ_rate, gs2sls dvarlag(W)
	
estat impact /// reports the average effects from the recursive process.	
	
*** Fitting models with a spatial lag of independent variables

spregress unemp_rate tert_educ_rate, gs2sls ivarlag(W:tert_educ_rate)

estat impact /// the easy way to obtain the direct and indirect effects of independent variables is to use estat impact
	
	
*** Fitting a model with a spatial lag of the error	

spregress unemp_rate tert_educ_rate, gs2sls errorlag(W)

