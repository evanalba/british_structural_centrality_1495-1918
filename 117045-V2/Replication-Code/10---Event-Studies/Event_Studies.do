#delimit ;
version 13;
cd "/Users/kmcooke/Desktop/Replication-Code/9---Regression-Analyses";
log close _all;
file close _all;
set more off;
clear;
est clear;

*---------------------------------*
*Data for Figures*
*---------------------------------*;
use royal_obs_AEJ.dta;

sort pair year;

file open Wars_By_Decade using Wars_By_Decade.csv, write replace;

file write Wars_By_Decade "Decade, Wars" _n;


forvalues i = 1490(10)1910  {;
	quietly sum war if floor(year/10)*10==`i';
	
 	file write Wars_By_Decade (`i') "," (r(mean)) "," "`CI'" _n;
};


file close Wars_By_Decade;

file open Conn_By_Decade using Conn_By_Decade.csv, write replace;

file write Conn_By_Decade "Decade, Connection" _n;

gen conn=0;
replace conn=1 if path~=.;

forvalues i = 1490(10)1910  {;
	quietly sum conn if floor(year/10)*10==`i';
	
 	file write Conn_By_Decade (`i') "," (r(mean)) "," "`CI'" _n;
};


file close Conn_By_Decade;


*Kinship and Conflict Event Study Data*;

gen window20=L10.death+L9.death+L8.death+L7.death+L6.death+L5.death+L4.death
+L3.death+L2.death+L.death+F.death+F2.death+F3.death+F4.death+F5.death
+F6.death+F7.death+F8.death+F9.death+F10.death;

gen window12=L6.placebo+L5.placebo+L4.placebo+L3.placebo+L2.placebo+L.placebo
+F.placebo+F2.placebo+F3.placebo+F4.placebo+F5.placebo+F6.placebo;


*Data For Connectedness Event Study;

file open Invpath_EventStudy using Invpath_EventStudy.csv, write replace;

file write Invpath_EventStudy "Year Since Death, Mean, Confidence Interval" _n;

forvalues i = -10/10  {;
	quietly sum F(`i').invpath if deathadj==1;
	
	local CI = 1.96*sqrt((r(mean)*(1-r(mean))/r(N)));
	
 	file write Invpath_EventStudy (`i') "," (r(mean)) "," "`CI'" _n;
};


file close Invpath_EventStudy;

*Data For Main (On-Path) Death Event Study;

file open Onpath_EventStudy using Onpath_EventStudy.csv, write replace;

file write Onpath_EventStudy "Year Since Death, Mean, Confidence Interval" _n;

forvalues i = -10/10  {;
	quietly sum F(`i').war if deathadj==1 & window20==0;
	
	local CI = 1.96*sqrt((r(mean)*(1-r(mean))/r(N)));
	
 	file write Onpath_EventStudy (`i') "," (r(mean)) "," "`CI'" _n;
};


file close Onpath_EventStudy;

*Data For Placebo (Close Off-Path) Death Event Study;

file open Offpath_EventStudy using Offpath_EventStudy.csv, write replace;

file write Offpath_EventStudy "Year Since Death, Mean, Confidence Interval" _n;

forvalues i = -6/6  {;
	quietly sum F(`i').war if placebo==1 & window12==0;
	
	local CI = sqrt((r(mean)*(1-r(mean))/r(N)));
	
 	file write Offpath_EventStudy (`i') "," (r(mean)) "," "`CI'" _n;
};

file close Offpath_EventStudy;


*Data For Unexpected Death Event Study;

gen death_unexpected=deathadj;

replace death_unexpected=0 if ~inlist(deathID,2,20,25,40,42,120,133,163,227,245,331,340,
568,604,686,709,743,744,764,771,774,776,951,1017,1069,1075,1099,1110,1173,1200,
1248,1298,1439,1625,1649,2134,2135,2423,2431,2507,2875,2877,2881,2883,2885,2887,
5163,7235,7236,10155,10177,11752,11753,14273,18470,18480,18503,18512,18962,18974,
19494,19497,20373,20378,20405,23676,23762,23792,23893,23944,25924,31900,31985,32118);

file open Unexpected_EventStudy using Unexpected_EventStudy.csv, write replace;

file write Unexpected_EventStudy "Year Since Death, Mean, Confidence Interval" _n;

forvalues i = -10/10  {;
	quietly sum F(`i').war if death_unexpected==1 & window20==0;
	
	local CI = sqrt((r(mean)*(1-r(mean))/r(N)));
	
 	file write Unexpected_EventStudy (`i') "," (r(mean)) "," "`CI'" _n;
};

file close Unexpected_EventStudy;


*Data For Any War Death Event Study;

file open Anywar_EventStudy using Anywar_EventStudy.csv, write replace;

file write Anywar_EventStudy "Year Since Death, Mean, Confidence Interval" _n;

forvalues i = -10/10  {;
	quietly sum F(`i').any_war if deathadj==1 & window20==0;
	
	local CI = sqrt((r(mean)*(1-r(mean))/r(N)));
	
 	file write Anywar_EventStudy (`i') "," (r(mean)) "," "`CI'" _n;
};


file close Anywar_EventStudy;

