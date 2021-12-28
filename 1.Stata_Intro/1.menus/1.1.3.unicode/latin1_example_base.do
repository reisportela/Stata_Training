//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all
	set more off

*** INFER�NCIA ESTAT�STICA
use bdados, clear
	gen lnwtp=ln(wtp)
	gen lnfaminc=ln(faminc)
	gen nrbags2=nrbags^2

/* Modelo a estimar: lnwtp = beta_0+beta_1*lnfaminc+beta_2*headeduc+beta_3*headage+beta_4*nrbags+beta_5*nrbags2+u */

		regress lnwtp lnfaminc headeduc headage nrbags nrbags2

	/* ESPECIFICAR E INTERPRETAR OS TESTES DE HIP�TESES INDIVIDUAIS */
	/* 	H0: beta_1=0
		H1: beta_1!=0
		Estat�stica do teste (estat�stica t): (beta_1_hat-0)/se(beta_1_hat) */
* NA SEGUNDA COLUNA DE RESULTADOS DO STATA OBTEMOS O ERRO PADR�O DO COEFICIENTE. ESTE PODE TAMB�M SER CALCULADO A PARTIR DA MATRIZ DE VARI�NCIAS E COVARI�NCIAS		
		mat l e(V)

* NA DIAGONAL PRINCIPAL DESTA MATRIZ TEMOS A VARI�NCIA DE CADA ESTIMADOR, FORA DA DIAGONAL PRINCIPAL EST�O AS COVARI�NCIAS DE PARES DE ESTIMADORES
* PARA O COEFICIENTE DE lnfamhinc, beta_1, O ERRO PADR�O � OBTIDO ASSIM
		di .00493664^.5
* A ESTAT�STICA t � DADA POR
		di (.1748676-0)/(.00493664^.5)
* PARA UM N�VEL DE SIGNIFIC�NCIA DE 5% O t cr�tico � DE
		di invttail(315-6,.025)
* UMA VEZ QUE A ESTAT�STICA DO TESTE � SUPERIOR AO t cr�tico REJEITAMOS A HIP�TESE NULA
* O STATA CALCULA O p-valor ASSOCIADO � HIP�TESE NULA FORMULADA ACIMA (TESTE BILATERAL PARA UMA HIP�TESE NULA EM QUE O COEFICIENTE � IGUAL A 0)
* NO CASO CONCRETO DE beta_1 O p-valor de 0.013 INDICA QUE O N�VEL M�NIMO DE SIGNIFIC�NCIA QUE PERMITE REJEITAR A HIP�TESE NULA � DE 1,3%
		di 2*ttail(315-6,(.1748676-0)/(.00493664^.5))
* PARA OS N�VEIS DE SIGNIFIC�NCIA HABITUAIS DE 5% E 10% REJEITAMOS A HIP�TESE NULA, MAS J� N�O A REJEITAMOS PARA UM N�VEL DE SIGNIFIC�NCIA DE 1%
* SE alpha=1% N�O REJEITAMOS A HIP�TESE DE beta_1 SER 0
* INTERPRETAR O INTERVALO DE CONFIAN�A E EXPLICAR A SUA CONSTRU��O: beta_1 +/- 1.9676709*se(beta_1_hat)
mat var=e(V)
		di _b[lnfaminc]-invttail(315-6,.025)*(var[1,1]^.5)
