//////////////////////////////////////////////////////////////////////////
// 2020 STATA ECONOMETRICS WINTER SCHOOL								//
// January 20-24, 2020													//
// Faculdade de Economia da Universidade do Porto, Portugal				//
// Anabela Carneiro, João Cerejeira, Miguel Portela	& Paulo Guimarães	//
//////////////////////////////////////////////////////////////////////////

	//////////////////////////////////////////////////////////
	// # 2. Linear regression						   		//
	//////////////////////////////////////////////////////////


	** World Bank Data to estimate a growth equation like table 7 in  Gallup, J. L., & Sachs, J. D. (2001). ///
				//The economic burden of malaria. The American journal of tropical medicine and hygiene, 64(1_suppl), 85-96.

				
	global st = "$S_TIME"									// CHECK HOW LONG IT TAKES TO RUN THE FULL PROGRAM
	clear all												// CLEAR STATA'S MEMORY; START A NEW SESSION
	set more off											// ALLOW SCREENS TO PASS BY
	set rmsg on												// CONTROL THE TIME NEEDED TO RUN EACH COMMAND

	
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\1.Linear_regression\data"         // THIS SHOULD BE YOUR DIRECTORY
capture cd "C:\Users\JoaoCerejeira\Dropbox\statafep2020\day2\2.regression\1.Linear_regression\data" 		// THIS IS MY WORKING FOLDER

		  
		  
** GDP per capita (constant 2010 US$)
ssc install wbopendata // in the case you don't have the command wbopendata in your computer
	
	wbopendata, indicator(NY.GDP.PCAP.KD) clear // allows Stata users to download over 9,900 indicators from the World Bank databases. Try the command "db wbopendata"
												// try a similar command for Eurostat data - eurostatuse
												
	 drop if region=="NA" | region=="" // keep only countries
	 
	 gen logGDPpc2000=log( yr2000) // gen new variables
	 gen logGDPpc2015=log( yr2015)
	 gen growthGDPpc=100*(logGDPpc2015-logGDPpc2000)/15 // gen average yearly growth rate
	 
	  label var growthGDPpc "Av. GDPpc growth 2015-2000"
	  label var logGDPpc2000 "Log GDPpc 2000"
	  label var logGDPpc2015 "Log GDPpc 2015"
		
	 keep countrycode logGDPpc2000 logGDPpc2015 growthGDPpc // keep relevant variables

	 save gdp_pc, replace
 
 ** Incidence of malaria (per 1,000 population at risk)

wbopendata, indicator(SH.MLR.INCD.P3) clear
 drop if region=="NA" | region==""
 
 rename yr2000 imalaria2000 // rename variable yr2000
 rename yr2015 imalaria2015 // rename variable yr2015

 gen change_malar=imalaria2015-imalaria2000
 
	label var imalaria2000 "Malaria incidence rate in 2000"
	label var imalaria2015 "Malaria incidence rate in 2015"
	label var change_malar "Change in incidence rate 2015-2000"
	
keep countrycode imalaria2000 imalaria2015 change_malar

  save imalaria, replace


** Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)

wbopendata,  indicator(SE.SEC.CUAT.LO.ZS) clear
  drop if region=="NA" | region==""

 egen educ_sec=rowmean(yr1995-yr2005) // create new variable equal to the mean educational attainment from 1995 to 2005

	label var educ_sec "% Population 25+ with lower sec. school"

 keep countrycode educ_sec
 
   save educ_sec, replace
   

** Life expectancy Life expectancy at birth, total (years) 

 wbopendata, indicator(SP.DYN.LE00.IN) clear

 drop if region=="NA" | region==""

 rename yr2000 life2000
	label var life2000 "Life expectancy 2000"
 
 keep countrycode life2000 
   save life, replace

** Trade (100*(Exp+Imp)/GDP) 

wbopendata, indicator(NE.TRD.GNFS.ZS) clear

 drop if region=="NA" | region==""

 rename yr2000 trade2000
	labe var trade2000 "Trade openess in % GDP 2000"
  
  keep countrycode trade2000

   save trade, replace

   
** Government Effectiveness: Estimate (from Worldwide Governance Indicators)

wbopendata, indicator(GE.EST) clear

 drop if region=="NA" | region==""

 rename yr2000 gov2000
	label var gov2000 "Government Effectiveness Índex 2000"
 
 keep countrycode gov2000 

  save gov, replace

  
** Gross capital formation (constant 2010 US$)

wbopendata, indicator(NE.GDI.TOTL.KD) clear

 drop if region=="NA" | region==""
 
 gen invest_growth=100*(log(yr2015)-log(yr2000))/15
	label var invest_growth "Mean growth gross capital formation"
 
 keep countrycode invest_growth
 
 save invest, replace

 
** merge all the files in one unique datafile

use gdp_pc, clear


foreach X in imalaria educ_sec life trade gov invest {

merge 1:1 countrycode using `X'
	drop _merge

}		

save world_data, replace

motivate
***

 
 
