set scheme s2color 


* Global Directories 
global DirData "C:\Users\pah.fi\Desktop\Irrationality\Data"
global DirResults "C:\Users\pah.fi\Desktop\Irrationality\Results"


*** Create Datasets ***
import delimited "$DirData\Instagram Usage_November 17, 2024_07.16.csv", clear varnames (1) 

drop in 1/11

* Destring variables 
describe, varlist
destring `varlist', replace 

* Generate day variable 
gen day = substr(startdate,9,2)
order day 

*Drop observations of day 6 
drop if day == "06" 

* Drop test obsevations 
drop in 68/69
drop in 1/2 

* Add missing data on graphic shown for observation on day 7 
local rows_high 64 58 57 55 53 51 48 46 45 43 42 40 38 37 36 34 35 32 31 29 27 26 24 23 22 21 20 19 18 17 16 13 11 9 8 7 5 4
local rows_low 65 63 62 61 60 59 56 54 52 50 49 47 44 41 39 33 30 28 25 15 14 12 10 6 3 2 1

foreach row in `rows_high'{
	replace graphicshown = "high" if _n == `row' & day == "07"
}

foreach row in `rows_low'{
	replace graphicshown = "low" if _n == `row' & day == "07"
}

* Drop  41 unfinished and test observations 
drop if finished == 0 
drop in 157 

* Estimated Usage 
gen est_own_usage = q2_1 * 60 + q3_1 
label var est_own_usage "Estimated own daily usage in minutes"

gen est_other_usage = q4_1 * 60 + q5_1 
label var est_other_usage "Estimated others daily usage in minutes"


* Revealed Usage 
replace q12_4 = 0 if q12_4 == . & q13_1 != . 
gen reveal_usage = . 
replace reveal_usage = q12_4 * 60 + q13_1

label var reveal_usage "Revealed own daily usage in minutes"

* Define difference of estimated own usage vs. others' usage 
gen diff_usage = est_own_usage - est_other_usage
label var diff_usage "Overestimation of you own usage to your peers "

* Define dummy for which graphic has been shown 
gen frame = . 
replace frame = 1 if graphicshown == "high"
replace frame = 0 if graphicshown == "low"

* Define differenece of own usage to frame 
gen diff_usage_frame = . 
replace diff_usage_frame = est_own_usage - 28 if frame == 0 
replace diff_usage_frame = est_own_usage - 128 if frame == 1 


* Demographics 
gen age = q15_1

gen bachelor = 0  
gen master = 0 
gen phd = 0 

replace bachelor = 1 if q16 == 1 
replace master = 1 if q16 == 2  
replace phd = 1 if q16 == 3 

gen male = 0 
gen female = 0 
gen nonbinary = 0 

replace male = 1 if q17 == 1
replace female = 1 if q17 == 2
replace nonbinary = 1 if q17 == 3

* E-mail 
gen missing_email = 0
replace missing_email = 1 if q18 == ""


* Willingess to pay 

forvalues i = 1/10{
	replace q11_`i' = 0 if q11_`i' == 1
	replace q11_`i' = 1 if q11_`i' == 2 
}

gen sum_q11 = q11_1 + q11_2 + q11_3 + q11_4 + q11_5 + q11_6 + q11_7 + q11_8 + q11_9 + q11_10


forvalues i = 2/10{
	gen switch_`i' = 0
} 

forvalues i = 2/10{
	local j = `i' - 1 
	replace switch_`i' = 1 if q11_`j' != q11_`i'  
}

gen sum_switch = switch_2 + switch_3 + switch_4 + switch_5 + switch_6 + switch_7 + switch_8 + switch_9 + switch_10

gen inconsistent = . 
replace inconsistent = 1 if sum_switch > 1 
label var inconsistent "Observation has inconsistent WTP"

gen wtp = .  
label var wtp "WTP to keep IG usage private"

replace wtp = -50 if sum_q11 == 10   
replace wtp = -30 if switch_2 == 1
replace wtp = -10 if switch_3 == 1
replace wtp = 10 if switch_4 == 1
replace wtp = 30 if switch_5 == 1
replace wtp = 50 if switch_6 == 1
replace wtp = 70 if switch_7 == 1
replace wtp = 90 if switch_8 == 1
replace wtp = 110 if switch_9 == 1
replace wtp = 130 if switch_10 == 1
replace wtp = 150 if sum_q11 == 0

replace wtp = . if inconsistent == 1 

* wtp new definiton 

gen shy = 0 
replace shy = 1 if sum_q11 == 0 

gen proud = 0 
replace proud = 1 if sum_q11 == 10 

gen slightly_proud = 0 
replace slightly_proud = 1 if switch_2 == 1  

gen indiff_show = 0 
replace indiff_show = 1 if switch_3 == 1 

gen indiff_private = 0 
replace indiff_private = 1 if switch_4 == 1 

gen slightly_shy = 0 
replace slightly_shy = 1 if wtp > 10 & wtp < 150 

gen wtp_categories = "other"
replace wtp_categories = "shy" if shy == 1 
replace wtp_categories = "proud" if proud == 1 
replace wtp_categories = "slightly proud" if slightly_proud == 1
replace wtp_categories = "indifferent show" if indiff_show == 1
replace wtp_categories = "indifferent private" if indiff_private == 1
replace wtp_categories = "slightly shy" if slightly_shy == 1


* Save Dataset 
save $DirData/Analysis.dta, replace

*** SumStat *** 

use $DirData/Analysis.dta, clear



*** Overview WTP Observations ***

use $DirData/Analysis.dta, clear

tab wtp 
return list 

tabulate wtp, matcell(freq_matrix)
matrix list freq_matrix

*** Results 1 *** 

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

esttab model1 model2 model3 model4 using "$DirResults\Reg1.tex", replace tex ///
	order(est_own_usage est_other_usage high_frame male bachelor age) ///
	compress 


*** Fuctional Form  of WTP on revealed usage ***

use $DirData/Analysis.dta, clear
drop if inconsistent == 1 
  
foreach var in reveal_usage { 
	gen sq`var' = `var' ^2 
	gen power`var' = `var' ^(4/3)
}

rename frame high_frame

reg wtp reveal_usage high_frame male bachelor age, robust  
eststo model1

reg wtp reveal_usage high_frame sqreveal_usage male bachelor age, robust
eststo model2

reg wtp sqreveal_usage high_frame male bachelor age, robust
eststo model3

reg wtp powerreveal_usage high_frame male bachelor age, robust
eststo model4

esttab model1 model2 model3 model4 


using "$DirResults\Reg3.tex", replace tex ///
	order(reveal_usage sqreveal_usage powerreveal_usage high_frame male age bachelor) ///
	compress 

*** Regression trying to explain real usage *** 

use $DirData/Analysis.dta, clear

reg reveal_usage est_own_usage male age bachelor, robust   
* Estimate own usage is significant 

*** Estimation of own usage *** 
reg est_own_usage est_other_usage male bachelor age, robust 
