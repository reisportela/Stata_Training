// Licenciatura em Economia - Universidade do Minho
// Econometria II - 2º ano
// M Portela -- março de 2020

clear all
set more off
set matsize 800

capture cd "/Users/miguelportela/Documents/GitHub/Stata_Training/4.EconometricsClassExercise/assignment_econometria_ii"
capture cd "/Users/miguelportela/Dropbox/3.aulas/2019/licenciatura/econometria_ii/"

    capture cd "3.assignment/logs"

// construção do ficheiro log '(.txt)'

capture log close
log using econometria.ii.assigment.txt, text replace



// # 1. ler e fazer uma 1ª descrição dos dados

use WAGE1, clear		// ficheiro de dados 'original'

    // ==>> definição da amostra

            // - de forma a garantir que a análise é feita sobre a mesma base de dados
            // vamos apagar as observações que tenham valores omissos ("missings") nalguma
            // das variáveis relevantes para a análise
            
			// - colocar à frente do 'rowmiss' as variáveis que fazem parte do modelo
            // mais completo

            egen nmiss = rowmiss(lwage educ exper female nonwhite married numdep)
                tab nmiss
                keep if nmiss == 0
                    drop nmiss

    // # 1.1 1ª descrição dos dados

        describe                // - este comando descreve os dados em memória
        codebook, compact       // - por exemplo, permite perceber os valores únicos de cada variável, 
								// o que nos dá uma ideia se devemos, ou não,
                                // considerar uma dada variável como contínua ou discreta

        summarize               // - produção de estatísticas descritivas para todas as variáveis
        tab educ, sort          // - aplicar o comando 'tab' apenas a variáveis categóricas
        sum wage, detail        // - aplicar 'sum' apenas a variáveis contínuas

        tabstat wage,by(smsa) stat(mean sd p50 p90 p95)        // - tabulação de estatísticas descritivas
			logout, save(tabstat_smsa) excel word replace: tabstat wage,by(smsa) stat(mean sd p50 p90 p95)
			
	log using econometria.ii.assigment.txt, text append		// - é necessário re-iniciar o log, pois
															// o comando 'logout' fecha o log aberto acima
	
	// # 1.2 exportar a estatística descritiva para o documento word/latex do trabalho

    // # 1.2.a exportar a estatística descritiva de um sub-conjunto de variáveis para uma tabela

		estpost summarize wage educ exper female nonwhite married numdep, detail
		
		esttab using summary_statistics.rtf, replace ///
			cells("count mean sd min max p95") nonumbers noobs label ///
			nomtitles nonotes addnotes("Fonte: cálculos próprios.")

                // NOTA 1: não reportar o desvio-padrão para variáveis categóricas
                // NOTA 2: para a estatística descritiva as variáveis categóricas devem ser transformadas 
				// num conjunto de variáveis dummy
	
	// # 1.2.b forma alternativa de exportar a estística descritiva

        // - o comando 'outreg2' exporta a estatística descritiva para um ficheiro word
        // - da 1ª vez que usam o comando devem instalá-lo: ssc install outreg2
        // - verificar na pasta de trabalho o ficheiro 'estatistica_descritiva.doc'

                preserve
                    keep wage educ exper female nonwhite married numdep
                    order wage educ exper female nonwhite married numdep
                    outreg2 using estatistica_descritiva.doc, sum(detail) word eqkeep(N mean sd p10 p50 p99) replace
                restore

	// # 1.2.c exportar gráficos: exemplos; adaptar a cada base de dados em função das variáveis disponíveis

        // ==> não é necessário aplicar todos os pontos abaixo ao vosso trabalho
        // ==> são exemplos do que podem fazer

        histogram wage, bin(15)

        kdensity wage, normal
            graph export wage_density.png, replace

        histogram female, discrete width(0.5) start(0) frequency
            graph export female_histogram.png, replace

        histogram female, discrete width(0.5) start(0) frequency by(married)
            graph export female_histogram_married.png, replace

        egen mean_wage = mean(wage),by(educ)
        
		scatter mean_wage educ
		
            graph export wage_educ_scatter.png, replace				// export the graph to an image file

        twoway (scatter mean_wage educ) || (fpfit wage educ)            // versão simples do gráfico
		
		// o mesmo gráfico com a inclusão de uma série de opções
		
			twoway (scatter mean_wage educ) || (fpfit wage educ), graphregion(color(white)) ///
				legend(label(1 "Mean wage") label(2 "Predicted wage") ///
				region(color(white))) scheme(sj) xtitle("Years of education") ytitle("Wage")

				graph export wage_educ_fit.png, replace

        // forma alternativa de preparar os dados para o gráfico

            preserve
                collapse (mean) mean_wage = lwage,by(educ)
                twoway (scatter mean_wage educ)
            restore
		
		label var educ "Years of education"
		
		graph bar (mean) female, over(educ, label(angle(-45) labsize(vsmall))) ///
			 graphregion(color(white)) scheme(s2color) ytitle("Share of females (x 100)")

    // # 1.4 forma alternativa de fazer uma 1ª caracterização da relação entre salário e educação

        tab edu, missing
            gen high_educ = (educ >12)

        tab high_educ
        label define heduc 0 "Low educ" 1 "High educ", replace
        label values high_educ heduc
        label variable high_educ "Level of education; 1 high, 0 otherwise"
            des high_educ
            tab high_educ

        sum wage, detail
            return list
            scalar p99 = r(p99)

            correlate wage educ

        tabstat wage,by(high_educ) stat(N mean sd p10 p50 p90 p99)

        twoway (kdensity wage if high_educ == 0 & wage <= p99) || (kdensity wage if high_educ == 1 & wage <= p99) ///
			, graphregion(color(white)) ///
            legend(label(1 "Low education") label(2 "High education") ///
            region(color(white))) scheme(sj) xtitle("Wage") ytitle("Density")
			
			graph export wage_density_educ.png, replace



// # 2. análise de regressão; exemplos de modelo

    generate exper2 = exper^2            // gerar uma variável 'exper2' que é o quadrado da experiência

    // # 2.1
		
		// -- >> REGRESSION 1: column 1 of the estimates table
		
        regress lwage educ exper exper2     // discutir a formulação do modelo e a interpretação dos parâmetros
            
			estimates store ols1            // guardar os resultados da regressão num "caixa" designada 'ols1'

                test exper2                 // teste de significância individual
                                            // teste de hipóteses: H0: beta3 = 0

                test exper exper2           // teste de significância conjunta à variável experiência,
                                            // que entra no modelo como 'exper' e 'exper2'

        // para que este teste de significância conjunta possa ser implementado manualmente é necessário ter informação
        // da estimação de um modelo sem exper e exper2

                regress lwage educ
					
					est store ols0
                
				// formulação manual do teste

                    di ((0.3003 - 0.1858)/2)/((1 - 0.3003)/(526 - 3 - 1))

        regress lwage educ c.exper##c.exper // o modelo acima poderia ter sido estimado sem criar a variável 'exper2'
                                            // utilizando os operadores do tipo '#' do Stata
                                            // esta formulação equivale a inserir na regressão 'exper' e 'exper2'

    // # 2.2
		
		// - tendo em conta o debate feito na literatura teórica e empírica definir um 2º conjunto
		// de variáveis a incluir na regressão

		// -- >> REGRESSION 2: column 2 of the estimates table
		
        regress lwage educ exper exper2 married nonwhite
            est store ols2

            test married nonwhite   // teste de significância conjunta
                                    // H0: beta4 = beta5 = 0

    // # 2.3 teste de Chow: avaliar se existe uma quebra de estrutura entre homens e mulheres na formação dos salários

        // # 2.3.a versão "longa"; ajuda a perceber o funcionamento do teste ==> não usar no trabalho de grupo

            gen female_educ = female*educ
            gen female_exper = female*exper
            gen female_exper2 = female*exper2
            gen female_married = female*married
            gen female_nonwhite = female*nonwhite

        regress lwage educ exper exper2 married nonwhite female female_educ female_exper female_exper2 female_married female_nonwhite

            test female female_educ female_exper female_exper2 female_married female_nonwhite

        
		// # 2.3.b versão alternativa; a que é habitualmente aplicada ==> esta é que a devem usar no trabalho

        regress lwage educ exper exper2 married nonwhite                    // restricted model: a variável 'female' não é incluída na regressão

		// -- >> REGRESSION 3: column 3 of the estimates table
		
        regress lwage educ exper exper2 married nonwhite if female == 0     // un-restricted (1); males
            est store ols3

		// -- >> REGRESSION 4: column 4 of the estimates table
		
        regress lwage educ exper exper2 married nonwhite if female == 1     // un-restricted (2); females
            est store ols4

            // teste F, estatística observada:			
			// display ((102.3923 - (45.5929658 + 37.9369573))/(6))/((45.5929658 + 37.9369573)/(526 - 2*(5 + 1))) 
			// = 19.344887
            
			// F crítico: cálculo via Stata
			// display invFtail(6,526 - 2*(5 + 1),.05)
			// = 2.1159353
            
			// comparar com a tabela F para um nível de significância de 5%

                // p-value: 2.057e-20 ~= 0

            display ((102.3923 - (45.5929658 + 37.9369573))/(6))/((45.5929658 + 37.9369573)/(526 - 2*(5 + 1)))


    // # 2.4 variáveis adicionais

        // criação de uma variável categórica com 3 valores a partir de numdep

        tab numdep, missing            // a opção missing avalia se a variável tem valores omissos

        gen numdep_dummies = 0 if numdep == 0
            replace numdep_dummies = 1 if (numdep == 1 | numdep == 2)
            replace numdep_dummies = 2 if (numdep > 2)

            tab numdep_dummies

                gen dummy_1 = (numdep == 1 | numdep == 2)
                gen dummy_2 = (numdep > 2)
				
					// atenção: para o Stata o 'missing' (valor omisso) é + infinito

        regress lwage educ exper exper2 married nonwhite female i.numdep_dummies

            testparm i.numdep_dummies   // teste de significância conjunta para as duas dummies adicionais
                                        // H0: beta6 = beta7 = 0

                regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2

                    test dummy_1 dummy_2

            matrix list e(V)                // listar a matriz de variâcias e co-variâncias
                                            
											// é necessário para obter a covariância que é
                                            // utilizada no teste de igualdade de parâmetros

            test nonwhite = female  	// teste de igualdade de parâmetros
										// H0: beta5 = beta6

            // cálculo da estatística do teste
			
				display (-.0084906-(-.32417))/((.0599608^2+.0371179^2 - 2*(.00008415))^.5)

                    // comparar com a aplicação automática do stata: test nonwhite = female

    // # 2.5 interacção de variáveis

        // gen female_educ = female*educ    ==>> a variável já existe

		// -- >> REGRESSION 5: column 5 of the estimates table
		
        regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ
            est store ols5

                test female_educ        // avaliar se faz sentido incluir a variável 'interacção' no modelo
                                        // interacção = female_educ = female*educ

            // teste de significância global

                test educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ

                            // H0: beta1=beta2=beta3=beta4=(...)=beta9=0
                            // comparar com o output do canto superior direito do Stata

                            // a seguir à regressão

        regress lwage c.educ##i.female exper exper2 nonwhite i.numdep_dummies
            
			// o modelo acima poderia ter sido estimado sem criar a variável 'exper2'
            // utilizar operadores Stata, #



// # 3. HETEROSKEDASTICITY (para efeitos de ilustração vamos utilizar um modelo mais simples)

        regress lwage educ exper female

            predict e, resid    // previsão dos resíduos
            predict y_hat       // variável dependente prevista

            gen e2 = e^2        // gerar uma variável 'e2' que contém o quadrado dos resíduos

    // # 3.1 exploração gráfica

                scatter e educ
                scatter e exper

            // comando automático

				regress lwage educ exper female
						rvpplot educ
						rvpplot exper

            // solução 'manual'

                // num modelo que satisfaça os pressupostos clássicos em relação à variância
                // não deve existir um padrão na relação entre os resíduos e a variável
                // dependente prevista, y_hat

                scatter e y_hat

                rvfplot // comando automático para avaliar se a variância dos resíduos é constante

                    twoway (scatter e y_hat) || (lfit e y_hat) || (fpfit e y_hat)

    // # 3.2 TESTE DE BREUSH-PAGAN
			
			// manual, step-by-step

				reg e2 educ exper female
                    scalar N=e(N)
                    scalar R2=e(r2)
                    scalar nregressores=e(df_m)
					di _new(2) "Estatística do teste:    " %5.2f N*R2 "	P-valor:    " %5.4f chi2tail(nregressores,N*R2)
				
                    di invchi2(3,.95)	// show the qui-square critical value

			// PROCEDIMENTO AUTOMÁTICO DO STATA

				quietly regress lwage educ exper female		// the command 'quietly' asks Stata not to show the output
						estat hettest,rhs iid

    // # 3.3 TESTE DE WHITE
	
			// solução 1, manual (step-by-step)

            // gerar os quadrados das variáveis

                // já temos exper2 e female = female^2
                
					gen educ2 = educ^2
				
				// e os produtos cruzados
				
					gen educ_exper=educ*exper
					gen educ_female=educ*female
					gen exper_female=exper*female

                reg e2 educ exper female educ2 exper2 educ_exper educ_female exper_female

                        scalar N=e(N)
                        scalar R2=e(r2)
                        scalar k=e(df_m)
				
				di _new(2) "Estatística do teste:    " %5.2f N*R2 "	P-valor:    " %5.4f chi2tail(k,N*R2)

			// solução 2, procedimento automático do Stata

				quietly regress lwage educ exper female		// the command 'quietly' asks Stata not to show the output
					estat imtest, white

        // PROCEDIMENTO ALTERNATIVO: UTILIZAR O VALOR PREVISTO DA VARIÁVEL DEPENDENTE 
		// E O SEU QUADRADO COMO VARIÁVEIS EXPLICATIVAS DE e^2

                gen y_hat2=y_hat^2

					reg e2 y_hat y_hat2

                        scalar N=e(N)
                        scalar R2=e(r2)
                        scalar k=e(df_m)
				
				di _new(2) "Estatística do teste:    " %5.2f N*R2 "	P-valor:    " %5.4f chi2tail(k,N*R2)

		drop e y_hat e2 y_hat2
		
	// # 3.4 HETEROSKEDASTICITY TEST on the FULL MODEL

		regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ
		
			predict e, resid
			predict y_hat
			
				gen e2 = e^2
				
			
			regress e2 educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ
				estimates store residuals

                        scalar N=e(N)
                        scalar R2=e(r2)
                        scalar k=e(df_m)
				
				di _new(2) "Estatística do teste:    " %5.2f N*R2 "	P-valor:    " %5.4f chi2tail(k,N*R2)

		regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ
				estat hettest,rhs iid		// procedimento automático

// # 4. utilização do procedimento do Stata para corrigir para a heteroscedasticidade

    // aplicar apenas se existir heteroscedasticidade

		// -- >> REGRESSION 6: column 7 of the estimates table
		
        regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ, robust
            est store robust

			matrix list e(V)
		
	// colinearidade
	
		vif
		
// # 5. exportar o resultado das extimações para uma tabela 'word'

estimates dir

esttab ols1 ols2 ols3 ols4 ols5 residuals robust,b(%4.3f) se(%5.4f) star(* 0.1 ** 0.05 *** 0.01) scalars("N Observações" "r2 R2" "rmse Root MSE")

		esttab ols1 ols2 ols3 ols4 ols5 residuals robust using regression_results_alt.rtf, replace ///
			keep(educ exper exper2 married nonwhite) ///
			mtitle("Model (1)" "Model (2)" "Model (3)" "Modelo (4)" "Final model" "Residuals" "Robust") nonumbers ///
			coeflabel (educ "Education" exper "Experience" exper2 "Experience sq." married "Married" nonwhite "non-White") ///
			b(%5.3f) se(%5.3f) star(* 0.1 ** 0.05 *** 0.01) ///
			scalars("N Observações" "r2 R2" "rmse Root MSE") ///
			title("Table 2: Regression analysis") ///
			nonotes addnotes("Notes: standard errors in parenthesis. Significance levels: *, 10%; **, 5%; ***, 1%." "The dependent variable is ln real GDP per workers." "Source: own computations.")

log close


// -- >> << -- //
			
			
// # 6. COLINEARIDADE: discussão & simulação de 'colinearidade'

    set seed 234

        gen age = exper + educ + 6

        // 'age_b' = 'age' + resíduo

        gen age_b = exper + educ + 6 + uniform()        // 'age_b' é colinear com 'age', pois é
                                                        // igual a 'age' mais um resíduo definido pelo termo
                                                        // 'uniform()'

            correlate age age_b            	// correlação entre variáveis ==>> se elevada temos um problema 
											// de colinearidade

    // # 6.1

        regress lwage educ exper

            vif                     // comando que nos permite avaliar se existe, ou não, um problema de colinearidade
                                    // o valor de referência é '10'; valores acima implicam que se faça um estudo
                                    // adicional para a presença de colinearidade no nosso modelo

    // # 6.2

        regress lwage educ exper age_b
            vif                            	// os valores de 'VIF' são elevadíssimos, o que indica um 
											// claro problema de colinearidade

            correlate educ exper age_b      // a correlação entre as diferentes variáveis é uma forma 
											// simples de avaliar se potencialmente temos um problema de colinearidade

    // # 6.3

        regress lwage educ exper age        // nesta regressão temos um erro de especificação 'GRAVE'
                                            // a idade é igual a 'educ + exper + 6'
                                            // o Stata coloca 'omitted', pois há colinearidade perfeita
                                            // um erro do tipo 'omitted' é muito 'GRAVE'
            vif


// # 7. RESET test: teste de especificação

    capture drop y_hat            // eliminar a variável 'y_hat' que vem dos cálculos anteriores

    regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ

        predict y_hat

            gen y_hat2 = y_hat^2
            gen y_hat3 = y_hat^3

    regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ ///
            y_hat2 y_hat3

        test y_hat2 y_hat3        // implementação do teste RESET: estatística e p-valor do teste

    // comando automático

        // ssc install reset        // instalação do comando (não é um comando base do Stata)

            help reset

            reset lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ

                // comparar o valor acima com a linha 'Ramsey RESETF2 Test'

// # 8. 'outliers'

    regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ

        gen id = _n

        lvr2plot, mlabel(id)

// # 9. qualidade do ajustamento

    estimates stats ols1 ols2 ols3 ols4 ols5 robust

    estimates table ols1 ols2 ols3 ols4 ols5 robust, b(%7.3f) ///
        keep(educ exper exper2 married nonwhite female female_educ) ///
        star(.1 .05 .01) stats(r2 r2_a rmse aic bic)

    estimates table ols1 ols2 ols3 ols4 ols5 robust, b(%7.3f) se(%7.3f) ///
        keep(educ exper exper2 married nonwhite female female_educ) ///
        stats(r2 r2_a rmse aic bic)

// # 10. COMANDO Stata que aplica um conjunto de testes de especificação

    // ssc install regcheck        // instalação do comando

    regress lwage educ exper exper2 married nonwhite female dummy_1 dummy_2 female_educ

        regcheck        // 'vermelho' ==>> 'problema'

					
capture log close

////////////////////////////////////////////////////////////////////////////////


// # 11. PROGRAMAÇÃO MANUAL DO 'OLS'

// SOURCE:    https://blog.stata.com/2016/01/05/programming-an-estimation-command-
// in-stata-computing-ols-objects-in-mata/

clear all

sysuse auto

    // # 1. Computing OLS point estimates in Mata

            mata

                y    = st_data(., "price")

                X    = st_data(., "mpg trunk")

                n    = rows(X)

                X    = X,J(n,1,1)

                XpX  = quadcross(X, X)

                XpXi = invsym(XpX)

                b    = XpXi*quadcross(X, y)


            end

    // # 2. Results from Mata and regress

            mata: b'

                regress price mpg trunk

    // # 3. Computing the IID VCE

            mata

                e    = y - X*b

                e2   = e:^2

                k    = cols(X)

                V    = (quadsum(e2)/(n-k))*XpXi

                sqrt(diagonal(V))'

            end

    // # 4. Robust standard errors

            mata
                M    = quadcross(X, e2, X)

                V    = (n/(n-k))*XpXi*M*XpXi

                sqrt(diagonal(V))'

            end

                regress price mpg trunk, robust

clear all
