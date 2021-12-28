// M Portela, May 21st, 2021
// EEG/U Minho

clear all
set more off

cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/8.projecto/logs"

capture log close
log using analise.txt, text replace

sysuse nlsw88.dta

// # 1. estatística descritiva

	describe
	codebook

	label list racelbl
	count if race == 2

	tabulate race


	// produz uma tabela compacta com estatísticas descritivas por grupo de uma variável secundária

	tabstat wage, statistics( mean sd p5 p50 p95 ) by(race)

// # 2. gráficos



log close





