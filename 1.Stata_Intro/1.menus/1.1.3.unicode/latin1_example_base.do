//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

	clear all
	set more off

*** INFERÊNCIA ESTATÍSTICA
use bdados, clear
	gen lnwtp=ln(wtp)
	gen lnfaminc=ln(faminc)
	gen nrbags2=nrbags^2

/* Modelo a estimar: lnwtp = beta_0+beta_1*lnfaminc+beta_2*headeduc+beta_3*headage+beta_4*nrbags+beta_5*nrbags2+u */

		regress lnwtp lnfaminc headeduc headage nrbags nrbags2

	/* ESPECIFICAR E INTERPRETAR OS TESTES DE HIPÓTESES INDIVIDUAIS */
	/* 	H0: beta_1=0
		H1: beta_1!=0
		Estatística do teste (estatística t): (beta_1_hat-0)/se(beta_1_hat) */
* NA SEGUNDA COLUNA DE RESULTADOS DO STATA OBTEMOS O ERRO PADRÃO DO COEFICIENTE. ESTE PODE TAMBÉM SER CALCULADO A PARTIR DA MATRIZ DE VARIÂNCIAS E COVARIÂNCIAS		
		mat l e(V)

* NA DIAGONAL PRINCIPAL DESTA MATRIZ TEMOS A VARIÂNCIA DE CADA ESTIMADOR, FORA DA DIAGONAL PRINCIPAL ESTÃO AS COVARIÂNCIAS DE PARES DE ESTIMADORES
* PARA O COEFICIENTE DE lnfamhinc, beta_1, O ERRO PADRÃO É OBTIDO ASSIM
		di .00493664^.5
* A ESTATÍSTICA t É DADA POR
		di (.1748676-0)/(.00493664^.5)
* PARA UM NÍVEL DE SIGNIFICÂNCIA DE 5% O t crítico É DE
		di invttail(315-6,.025)
* UMA VEZ QUE A ESTATÍSTICA DO TESTE É SUPERIOR AO t crítico REJEITAMOS A HIPÓTESE NULA
* O STATA CALCULA O p-valor ASSOCIADO À HIPÓTESE NULA FORMULADA ACIMA (TESTE BILATERAL PARA UMA HIPÓTESE NULA EM QUE O COEFICIENTE É IGUAL A 0)
* NO CASO CONCRETO DE beta_1 O p-valor de 0.013 INDICA QUE O NÍVEL MÍNIMO DE SIGNIFICÂNCIA QUE PERMITE REJEITAR A HIPÓTESE NULA É DE 1,3%
		di 2*ttail(315-6,(.1748676-0)/(.00493664^.5))
* PARA OS NÍVEIS DE SIGNIFICÂNCIA HABITUAIS DE 5% E 10% REJEITAMOS A HIPÓTESE NULA, MAS JÁ NÃO A REJEITAMOS PARA UM NÍVEL DE SIGNIFICÂNCIA DE 1%
* SE alpha=1% NÃO REJEITAMOS A HIPÓTESE DE beta_1 SER 0
* INTERPRETAR O INTERVALO DE CONFIANÇA E EXPLICAR A SUA CONSTRUÇÃO: beta_1 +/- 1.9676709*se(beta_1_hat)
mat var=e(V)
		di _b[lnfaminc]-invttail(315-6,.025)*(var[1,1]^.5)
