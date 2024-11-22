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
replace q2_1 = 0 if q2_1 == . 
gen est_own_usage = q2_1 * 60 + q3_1 
label var est_own_usage "Estimated own daily usage in minutes"

replace q4_1 = 0 if q4_1 == . 
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

