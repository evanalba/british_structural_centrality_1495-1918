version 13
cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses"
log close _all
set more off
clear
est clear
*---------------------------------*
*Kinship and Conflict Regressions*
*---------------------------------*
use royal_obs_AEJ.dta

cd "/Users/kmcooke/Desktop/Replication-Code/14---In-Text-Estimates"


file close _all


*establishing 1*
preserve
gen share_pairs_connected = 1
replace share_pairs_connected = 0 if path == .



collapse (mean) share_pairs_connected, by(year)


***Percent connected goes from 21.5% in the 1500s to 73.2% in the 1900s****

file open results using in_text_results.txt, write text replace

file write results "Estimate 1 Results Displayed:" _newline _newline
file write results "year" _tab "share_pairs_connected" _newline

summ share_pairs_connected if year>=1500 & year<1600

file write results "share connected in 1500s =" _tab (r(mean)) _newline 

summ share_pairs_connected if year>=1800 & year<1900
local x2 r(mean)

file write results "share connected in 1800s =" _tab (r(mean)) _newline _newline _newline _newline



*%8z share_pairs_connected[1]






*save estimate_1, replace
restore



*establishing (3)
preserve
gen is_post_1800 =0
replace is_post_1800 = 1 if year >1800

collapse (mean) war, by(is_post_1800)
**percent of pairs at war post 1800 = 1.3%, before 1800 = 5%


file write results "Estimate 3 Results Displayed:" _newline _newline
file write results "is_post_1800" _tab "war_frequency" _newline
local x1 = is_post_1800[1] 
local y1 = war[1] 
file write results "`x1'" _tab _tab _tab  _tab"`y1'" _newline
local x2 = is_post_1800[2] 
local y2 = war[2] 
file write results "`x2'" _tab  _tab _tab _tab"`y2'" _newline _newline _newline _newline

*save estimate_3, replace
restore



*establishing (5)
preserve
gen num_personal_unions =0
replace num_personal_unions =1 if path ==0

collapse (sum) num_personal_unions
*save estimate_5, replace


file write results "Estimate 5 Results Displayed:" _newline _newline
file write results "num personal unions"  _newline
local x1 = num_personal_unions[1] 
file write results "`x1'" _tab _tab _tab  _tab _newline _newline _newline _newline




restore




*establishing (7) 
preserve
keep if C1 == 216 | C2 == 216
keep if C1 == 304 | C2 == 304

gen years_of_coexist = 1

collapse (sum) years_of_coexist (mean) war

*save estimate_7, replace

file write results "Estimate 7 Results Displayed:" _newline _newline
file write results "Country Pair" _tab "Years of Coexist"  _tab "War Frequency" _newline
local x1 = years_of_coexist[1] 
local y1 = war[1] 
file write results "Austria-France" _tab"`x1'" _tab _tab _tab  _tab"`y1'" _newline _newline _newline _newline

restore




*establishing (11)

preserve
drop if path ==0
gen years_of_coexist = 1
gen num_ever_connected = 1
replace num_ever_connected = 0 if path == .

collapse (sum) years_of_coexist (max) num_ever_connected, by(pair) 

gen pair_count = 1
drop if years_of_coexist<=100

collapse (sum) pair_count num_ever_connected
*save estimate_11, replace
file write results "Estimate 11 Results Displayed:" _newline _newline
file write results "Number of Pairs Coexisting 100 Years" _tab "Number of Those Pairs Who Are Ever Connected"  _newline
local x1 = pair_count[1] 
local y1 = num_ever_connected[1] 
file write results "`x1'" _tab _tab _tab  _tab _tab _tab _tab  _tab _tab _tab   "`y1'" _newline _newline _newline _newline

restore


*establishing 12
preserve

gen is_1580s = 0
replace is_1580s = 1 if year>1579 & year<1590

gen is_1910s = 0
replace is_1910s = 1 if year>1909

gen share_pairs_connected = 1
replace share_pairs_connected = 0 if path == .

collapse (mean) share_pairs_connected, by(is*)

drop if is_1910s == 0 & is_1580s == 0

*save estimate_12, replace
file write results "Estimate 12 Results Displayed:" _newline _newline
file write results "Decade" _tab "Share of Pairs Connected" _newline

local y1 = share_pairs_connected[1] 
file write results "1910s" _tab "`y1'" _newline

local y2 = share_pairs_connected[2] 
file write results  "1580s" _tab  "`y2'" _newline _newline _newline _newline



restore




*establishing 13
preserve
gen share_close_connection =0
replace share_close_connection = 1 if path<8

collapse (mean) share_close_connection, by(year)

*twoway (scatter share_close_connection year) (lfit share_close_connection year)

reg share_close_connection year

*graph save estimate_13, replace

file write results "Estimate 13 Results Displayed:" _newline _newline
*file write results "Decade" _tab "Share of Pairs Connected" _newline

local y1 = _b[year]
file write results "Coefficient of Year in Explaining Share of Pairs Closely Connected" _tab "`y1'" _newline _newline _newline _newline _newline

*local y2 = share_pairs_connected[2] 
*file write results "1910s" _tab  "`y2'" _newline _newline _newline _newline




restore


*establishing 15
preserve
collapse (sum) death
*save estimate_15, replace
file write results "Estimate 15 Results Displayed:" _newline _newline
*file write results "Decade" _tab "Share of Pairs Connected" _newline

local y1 = death[1]
file write results "Number of Pair-Years Shocked by Death" _tab "`y1'" _newline _newline _newline _newline _newline



restore



*establishing 24
*preserve

gen is_before_1600 = 0
replace is_before_1600 = 1 if year<=1600

gen is_after_1800 = 0
replace is_after_1800 = 1 if year>=1800

drop if is_before_1600 ==0 & is_after_1800 == 0

sort is_before_1600

collapse (mean) war invpath, by(is*)


file write results "Estimate 24 Results Displayed:" _newline _newline
file write results "Period" _tab _tab _tab "war frequency" _tab "average inv_path" _newline
local x1 = war[1] 
local y1 = invpath[1] 
file write results "After 1800" _tab "`x1'" _tab "`y1'" _newline
local x2 = war[2] 
local y2 = invpath[2] 
file write results "Before 1600" _tab  "`x2'" _tab  "`y2'" _newline _newline _newline _newline




*restore


file close _all




























