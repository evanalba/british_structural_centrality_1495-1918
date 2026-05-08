#delimit ;
version 13;
cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";
log close _all;
set more off;
clear;
est clear;
*---------------------------------*
*Kinship and Conflict Regressions*
*---------------------------------*;
use royal_obs_AEJ.dta;

cd "/Users/kmcooke/Desktop/Replication-Code/13---Appendix";

set matsize 1200;

sort pair year;

xtset pair year;

capture drop invpath;
gen invpath=1/path;
replace invpath=0 if path==.;
replace invpath=. if path==0;

capture drop invres;
gen invres=1/res;
replace invres=0 if res==.;
replace invres=. if path==0;


label var invpath "(Path)$^{-1}$";
label var invres "(Resistance)$^{-1}$";
label var adj "Adjacent";
label var shared "Neither Landlocked";
label var ln_dist "ln(Distance)";
label var same "Same Religion";
label var blood_dist "Genetic Distance";
label var blood "Genetic Tie";
label var war "War";
label var deg "Immediate Relatives";

*OLS (Table 12);

est clear;

eststo: quietly reghdfe war invpath, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;

eststo: quietly reghdfe war invpath blood same shared ln_dist adj, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;


eststo: quietly reghdfe war invres, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;

eststo: quietly reghdfe war invres blood same shared ln_dist adj, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;

esttab using AppendixTables.tex, se label replace keep(invpath invres blood same_religion adj shared_sea ln_dist)
order(invpath invres blood same_religion adj shared_sea ln_dist)
stats(C_FE T_FE N, label("Pair FE" "Year FE" "N")) 
booktabs page  
nonotes nostar addnote("Standard errors are robust to 2-way country clustering.") 
title(OLS Results \label{tab:OLS});

est clear;

*Blood Distance  (Table 13);

est clear;

replace blood_dist=99 if blood_dist==.;

drop if R1==R2;

drop if l.R1~=R1;

drop if l.R2~=R2;

eststo: quietly ivreg2 war ib99.blood_dist, cluster(C1 C2);

eststo: quietly ivreg2 war ib99.blood_dist same shared ln_dist adj, cluster(C1 C2);

eststo: quietly reghdfe war ib99.blood_dist, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;

eststo: quietly reghdfe war ib99.blood_dist same shared ln_dist adj, a(pair year) cluster(C1 C2);
estadd local C_FE "X",replace;
estadd local T_FE "X",replace;


esttab using AppendixTables.tex, se label append 
stats(C_FE T_FE N, label("Pair FE" "Year FE" "N")) 
booktabs page  
nonotes nostar addnote("Base group is dyads with no genetic tie. Standard errors are robust to 2-way country clustering.") 
title(Genetic Distance and War \label{tab:Blood});

est clear;

*Connection Over Time Graphs;

cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";

use royal_obs_AEJ.dta, clear;

cd "/Users/kmcooke/Desktop/Replication-Code/13---Appendix";

gen conn=0;
replace conn=1 if path<8;

gen res2=0;
replace res2=1 if res<=2;

gen bconn=0;
replace bconn=1 if blood_dist~=.;

collapse bconn blood conn res2, by(year);

scatter bconn blood year, legend(label(1 "Share of Dyads with Related Rulers") 
label(2 "Share of Dyads with Common Great Grand Parent") cols(1))
bgcolor(white) graphregion(color(white));

graph export BloodTiesOverTime.pdf, replace;

scatter res2 conn year, legend(label(1 "Share of Dyads with Resistance Distance < 2") 
label(2 "Share of Dyads with Shortest Path < 8") cols(1))
bgcolor(white) graphregion(color(white));

graph export ConnectionsOverTime.pdf, replace;


*Dyad Coexistence;

cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";

use royal_obs_AEJ.dta, clear;

cd "/Users/kmcooke/Desktop/Replication-Code/13---Appendix";

collapse (mean) C1 C2 (count) year (mean) war invpath, by(pair);

rename year years;

gsort -year;

outsheet C1 C2 years war invpath using dyad_stats.csv,comma replace;

*Graph - War vs Inverse Path;

twoway scatter war invpath [w=years], msymbol(circle_hollow) msize(vsmall)||
lfit war invpath [w=years], bgcolor(white) graphregion(color(white)) 
legend(label(1 "Dyadic War Frequency"))  ytitle("Dyadic War Frequency") xtitle("Average Dyadic Inverse Path Length");

graph export Dyadic_War_Frequency.pdf, replace;


*Country Timeline;

cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";

use royal_obs_AEJ.dta, clear;

cd "/Users/kmcooke/Desktop/Replication-Code/13---Appendix";

gen exists=1;

keep C1 year exists;

duplicates drop;

reshape wide exists, i(C1) j(year);

save Timeline, replace;

cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";

use royal_obs_AEJ.dta, clear;

cd "/Users/kmcooke/Desktop/Replication-Code/13---Appendix";

gen exists=1;

keep C2 year exists;

rename C2 C1;

duplicates drop;

reshape wide exists, i(C1) j(year);

append using Timeline;

collapse (max) exists*, by(C1);

save Timeline,replace;

reshape long exists, i(C1) j(year);

collapse (sum) exists, by(C1);

rename exists total_years;

merge 1:1 C1 using Timeline;

gsort -total C1;

drop _merge;

rename C1 Country;

outsheet using timeline.csv,comma replace;

erase Timeline.dta;


