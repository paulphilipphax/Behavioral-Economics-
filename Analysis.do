
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
 
hist wtp, bins(9)

hist lreveal_usage

hist lest_own_usage

hist wtp

twoway ///
	(hist est_own_usage, color(blue))  ///
	(hist est_other_usage, color(red)),
	title ("Estimation of own vs. peer usage")

*** Table 3: Main Regressions  ***	

use ${DirData}Analysis.dta, clear
drop if inconsistent == 1 
rename frame high_frame 
est clear 

tobit wtp est_own_usage est_other_usage high_frame male bachelor age, ll(-50) ul(150)
eststo model1

tobit wtp reveal_usage high_frame male bachelor age, ll(-50) ul(150) 
eststo model2

reg est_own_usage est_other_usage male bachelor age, robust 
eststo model3

reg est_own_usage est_other_usage reveal_usage male bachelor age, robust 
eststo model4

esttab model1 model2 model3 model4 using "${DirResults}table3.tex", replace label ///
	title(Main Regressions ) ///
	order(est_own_usage est_other_usage high_frame reveal_usage male bachelor age) ///
	se(2) b(2) ///
	coeflabels( est_own_usage "Estimate own usage" est_other_usage "Estimate peer usage" high_frame "High frame" 	reveal_usage "True usage" male "Male" bachelor "Bachelor" age "Age")
		
*** Appendix 1: Regression Models for WTP using the whole sample ***	

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
rename frame high_frame 
	

tobit wtp est_own_usage male bachelor age, ll(-50) ul(150)
eststo model1

tobit wtp est_other_usage high_frame male bachelor age, ll(-50) ul(150)
eststo model2

tobit wtp high_frame male bachelor age, ll(-50) ul(150)
eststo model3

tobit wtp  high_frame est_own_usage male bachelor age, ll(-50) ul(150)
eststo model4

esttab model1 model2 model3 model4 using "${DirResults}table4.tex", replace label compress ///
	title(Regression Models for WTP using the whole sample) ///
	se(2) b(2) ///
	coeflabels( est_own_usage "Estimate own usage" est_other_usage "Estimate peer usage" high_frame "High frame" 	reveal_usage "True usage" male "Male" bachelor "Bachelor" age "Age")
		
		
*** Appendix 2: WTP using revealed usage sample ***

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
rename frame high_frame


foreach var in reveal_usage { 
	gen sq`var' = `var' ^2 
}


tobit wtp high_frame male bachelor age, ll(-50) ul(150) 
eststo model1 

tobit wtp reveal_usage sqreveal_usage high_frame male bachelor age, ll(-50) ul(150)
eststo model2

tobit wtp reveal_usage est_own_usage high_frame  male bachelor age, ll(-50) ul(150)
eststo model3

tobit wtp reveal_usage est_own_usage est_other_usage high_frame male bachelor age, ll(-50) ul(150)
eststo model4

esttab model1 model2 model3 model4 using "${DirResults}table5.tex", replace label ///
	title(WTP using revealed usage sample ) ///
	se(2) b(2) ///
	coeflabels(est_own_usage "Estimate own usage" est_other_usage "Estimate peer usage" high_frame "High frame" 	reveal_usage "True usage" sqreveal_usage "True usage ^ 2 " male "Male" bachelor "Bachelor" age "Age")

	
*** Appendix 3: Regressions explaining estimate of own usage *** 

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
rename frame high_frame

reg est_own_usage est_other_usage male bachelor age, robust 

reg est_own_usage est_other_usage reveal_usage male bachelor age, robust 

reg est_own_usage est_other_usage wtp high_frame male bachelor age, robust 

reg est_own_usage est_other_usage reveal_usage wtp high_frame male bachelor age, robust 

esttab model1 model2 model3 model4 using "${DirResults}table6.tex", replace label compress ///
	title(Regressions explaining estimate of own usage) ///
	se(2) b(2) ///
	coeflabels(wtp "WTP" est_own_usage "Estimate own usage" est_other_usage "Estimate peer usage" high_frame "High frame" 	reveal_usage "True usage" male "Male" bachelor "Bachelor" age "Age")












