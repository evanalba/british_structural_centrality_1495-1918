#delimit ;
version 13;
cd "/Users/kmcooke/Desktop/Replication-Code/8---Create-Stata-Data";
log close _all;
set more off;
clear;
est clear;
*---------------------------------*
*Kinship and Conflict Dataset*
*---------------------------------*;


* Load non-network variables;
insheet using "obs.csv";

rename v1 C1;
rename v2 C2;
rename v3 year;
rename v4 R1;
rename v5 R2;
rename v6 ln_dist;
rename v7 same_religion;
rename v8 shared_sea;
rename v9 adj;
rename v10 Habs;
rename v11 war;
rename v12 any_war;
rename v13 war_id;
rename v14 battle_deaths;

replace battle="." if battle=="NaN";
destring battle, replace;

gen ln_battle=ln(1+battle);
bysort war_id: gen dyads=_N;
gen ln_bd=ln(1+battle/dyads);
drop dyads;

replace ln_dist="." if ln_dist=="-Inf";
destring ln_dist, replace;

egen pair = group(C1 C2);

sort pair year;

xtset pair year;

save royal_obs_AEJ.dta, replace;

clear;

* Load living kinship network variables;

insheet using "obs_net2.csv";

rename v1 C1;
rename v2 C2;
rename v3 year;
rename v4 R1;
rename v5 R2;
rename v6 path;
rename v7 deg;
rename v8 death;
rename v9 deathID;
rename v10 placebo;
rename v11 res;
rename v12 thirdparty;

egen pair = group(C1 C2);

sort pair year;

xtset pair year;

replace path="." if path=="Inf";
destring path, replace;

replace res=0 if path==0;
replace res=. if path==.;
capture destring res, replace;

gen invpath=1/path;
replace invpath=0 if path==.;
replace invpath=. if path==0;

capture drop deathadj;
gen deathadj=death;

*Remove suspicious deaths;
replace deathadj=0 if inlist(deathID, 44, 227, 740, 749, 951, 1196, 1424, 2510, 2875, 3779, 7269, 10180, 20261);


gen death5=max(l.deathadj, l2.deathadj, l3.deathadj, l4.deathadj, l5.deathadj);

save royal_obs_net.dta, replace;

clear;

*Load genetic distance;

insheet using "obs_blood.csv";

rename v1 C1;
rename v2 C2;
rename v3 year;
rename v4 R1;
rename v5 R2;
rename v6 blood_dist;

replace blood_dist="." if blood_dist=="NaN";
destring blood_dist, replace;

gen blood=0;
replace blood=1 if blood_dist<=3;

save royal_obs_blood.dta, replace;

clear;

* Add network measures to main dataset;

use royal_obs_AEJ.dta,clear;

merge 1:1 C1 C2 year using royal_obs_net.dta;

drop _merge;

save royal_obs_AEJ.dta, replace;

* Add genetic distance to main dataset;

use royal_obs_AEJ.dta, clear;

merge 1:1 C1 C2 year using royal_obs_blood.dta;

save royal_obs_AEJ.dta, replace;

erase royal_obs_net.dta;
erase royal_obs_blood.dta;

