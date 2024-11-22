
********************************************************************************
* Analysis 
********************************************************************************


*** Table 1: Frequencies of WTP ***

use $DirData/Analysis.dta, clear

tab wtp 
return list 

tabulate wtp, matcell(freq_matrix)
matrix list freq_matrix

*** Table 2 *** 

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
 
local varlist male female bachelor master age est_own_usage est_other_usage diff_usage frame reveal_usage

foreach var in `varlist'{ 
	*qui sum `var', detail 
	*replace `var' = . if `var' < r(p5) | `var' > r(p95) 
	gen `var'_mean = `var'
}

gen count = male
gen count_reveal_usage = reveal_usage 
local varlist_count count count_reveal_usage 

collapse (mean) `varlist' (count) `varlist_count', by(wtp_categories)

order wtp_categories count male female age bachelor master est_own_usage est_other_usage frame reveal_usage count_reveal_usage

gen value = 0 
replace value = 1 if wtp_categories == "shy"
replace value = 2 if wtp_categories == "slightly shy"
replace value = 3 if wtp_categories == "indifferent show"
replace value = 4 if wtp_categories == "indifferent private"
replace value = 5 if wtp_categories == "proud"

sort value 

graph bar est_own_usage reveal_usage, over(wtp_categories)

*** Distributions *** 

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
 
local varlist male female bachelor master age est_own_usage est_other_usage diff_usage frame reveal_usage

foreach var in `varlist'{ 
	qui sum `var', detail 
	replace `var' = . if `var' < r(p5) | `var' > r(p95) 
}


hist est_own_usage
 
hist wtp 
hist lreveal_usage

hist lest_own_usage
hist wtp 

twoway ///
	(hist est_own_usage, color(blue))  ///
	(hist est_other_usage, color(red)),
	title ("Estimation of own vs. peer usage")
	
*** Regression Models for WTP using the whole sample ***	

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
rename frame high_frame 

reg wtp est_own_usage male bachelor age, robust  
eststo model1

reg wtp est_other_usage high_frame male bachelor age, robust
eststo model2

reg wtp high_frame male bachelor age, robust
eststo model3

reg wtp  high_frame est_own_usage male bachelor age, robust
eststo model4

esttab model1 model2 model3 model4 using "$DirResults\reg1.tex", replace tex ///
	order(est_own_usage est_other_usage high_frame male bachelor age) ///
	compress 


*** Reg 3: WTP on revealed usage ***

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
  
foreach var in reveal_usage { 
	gen sq`var' = `var' ^2 
}

rename frame high_frame

tobit wtp reveal_usage high_frame male bachelor age, ll(-50) ul(150)
eststo coef1 
estpost margins, dydx(*)
eststo margins1 

tobit wtp reveal_usage high_frame male bachelor age, ll(-50) ul(150)
eststo coef2
estpost margins, dydx(*)
eststo margins2


tobit wtp reveal_usage est_own_usage high_frame  male bachelor age, ll(-50) ul(150)
eststo coef3
estpost margins, dydx(*)
eststo margins3


tobit wtp reveal_usage est_own_usage est_other_usage high_frame male bachelor age, ll(-50) ul(150)
eststo coef4
estpost margins, dydx(*)
eststo margins4

esttab coef1 coef2 coef3 coef4 using "$DirResults\reg3_tobit.tex", replace tex ///
	se compress ///
	order(reveal_usage high_frame est_own_usage est_other_usage male age bachelor)

esttab margins1 margins2 margins3 margins4 using "$DirResults\reg3_tobit_margins.tex", replace tex ///
	se compress ///
	order(reveal_usage high_frame est_own_usage est_other_usage male age bachelor)

	
	
*** Regression trying to explain real usage *** 

use $DirData/Analysis.dta, clear

reg reveal_usage est_own_usage male age bachelor, robust   
* Estimate own usage is significant 

*** Estimation of own usage *** 
reg est_own_usage est_other_usage male bachelor age, robust 
