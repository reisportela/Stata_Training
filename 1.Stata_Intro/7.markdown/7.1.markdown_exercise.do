//////////////////////////////////////////////
// EEGS - Introduction to Stata				//
// April, 2021								//
// EEG / Universidade do Minho, Portugal	//
// Miguel Portela							//
//////////////////////////////////////////////

clear all
set more off

// -- 'markstat'

	// https://data.princeton.edu/stata/markdown
		// ssc install markstat
		// ssc install whereis
		// whereis pandoc /usr/local/bin/pandoc
		// whereis pdflatex /Library/TeX/texbin/pdflatex
		// whereis R /opt/homebrew/bin/R

cd "/Users/miguelportela/Dropbox/Stata/stata_training/day1/7.markdown"

markstat using stata_markdown_example.stmd, pdf strict mathjax bib
