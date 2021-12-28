capture log close
log using "stata_markdown_example", smcl replace
//_1q

clear all
set more off


quiet use WAGE1, clear

    quiet count if educ < 10

//_2
display r(N)
//_3q
    
quiet {
        drop if educ < 10
        kdensity wage, normal graphregion(color(white)) scheme(sj) legend(region(color(white)))
            graph export wage_density.png, replace
}

codebook, compact

//_4q
quiet {
        generate exper2 = exper^2
            
        regress lwage educ exper exper2
            estimates store ols1
        
    // # 2.2
        regress lwage educ exper exper2 female nonwhite
        local beta = _b[educ]
            est store ols2
}

    esttab ols1 ols2
//_5
display %6.1f `beta'*100
//_^
log close
