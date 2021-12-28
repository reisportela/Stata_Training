
cd "/Users/miguelportela/Documents/GitHub/Stata_Training/3.Panel_Data/dofiles/sessao_live_aula"

clear all
webuse nlswork
save nlswork, replace
use nlswork, clear

describe
regress ln_wage union collgrad ttl_exp
regress ln_wage union collgrad c.ttl_exp##c.ttl_exp
xtdes
regress ln_wage union collgrad c.ttl_exp##c.ttl_exp c.year##c.year##c.year##c.year 
gen year2 = year^2
gen year3 = year^3
gen year4 = year^4
regress ln_wage union collgrad c.ttl_exp##c.ttl_exp year year2 year3 year4
regress ln_wage union collgrad c.ttl_exp##c.ttl_exp c.year##c.year##c.year 
sort idcode year 
br
regress ln_wage union collgrad c.ttl_exp##c.ttl_exp
xtreg ln_wage union collgrad c.ttl_exp##c.ttl_exp,fe


