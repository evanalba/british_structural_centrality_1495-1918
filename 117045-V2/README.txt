Replication Instructions For

"A Network of Thrones: Kinship and Conflict in Europe, 1495-1918"

by: Seth Benzell and Kevin Cooke

Project ID: openicpsr-117045

________________________________________________________________________________

-----------------
Software Requirements:  Matlab R2013b or later, Stata/MP 13.0 or later, Strawberry Perl 5.30.1.1

Software Set-up:  Use setup file ("config_stata.do") to install the following required Stata packages

	- ranktest  3.23
	- reghdfe   1.4.01
	- ftools    5.7.3
	- ivreghdfe 2.37.0
	- ivreg2    4.1.11
	- estout    1.0.0
	- parallel  1.20.0

Suggested Hardware:  minimum 12 core parallel cluster

Estimated Total Computer Time: 5 hours (using 12 cores for parallel jobs)

-----------------
Step 0: Data Collection

Excel Data - "Master Data.xlsx" contains data on rulers, wars, battle deaths, and various covariates manually assembled from a variety of sources as detailed in the data appendix.  Note tabs "Death Table 2" and "Appendix Death Table" contain data for Table 2 and Table AX, respectively.

Genealogical Data - "royal2014.GED" contains genalogical data generously provided by Brian Tompsett based upon his Directory of Royal Genealogical Database.

-----------------

Step 1:  Create Dyadic Data

This step requires three processed data files (Rulers.csv, Wars.csv, BattleDeaths.csv) that were manually cleaned based upon data included "Master Data.xlsx" as described below:

Rulers.csv extracts (in the following order) Columns [B,E,I K, AG to AK, AO, AT, F, AU to DB] from the "Ruler+Adjacency" tab with the following modifactions:

 - Religions from Column AO are coded such that Protestant groups=1, Orthodox groups=2, and Catholic=3
 - Dynasties from Column F are coded 1 for Habsburgs and 0 otherwise
 - Coexistence from Columns AU-DB are coded Yes=1 and 0 otherwise

Wars.csv extracts (in the following order) Columns [D, F, G, R to V, A] from the "Final War Dyads" tab

BattleDeaths.csv extracts Columns B and E from the "Deaths at War Level" tab


The Matlab program "Royal_import.m" processes these files and creates a set of dyad-year observations with all non-network covariates.  This program takes about 25 minutes on a local machine. This produces:

C1, C2, year, R1, R2, ln(dist), same religion, neither landlocked,
Adjacency, Habsburg dummy, war, any war, war id, battle deaths

Note:  "lldistkm.m" is a publically available Matlab package used to calculate great circle distances and is required to run "Royal_import.m".

Output: "obs.csv"

-----------------

Step 2:  Processing Genealogical data

Corrected Genealogical Data -  "royal2014update.GED"  makes a number of corrections and additions to Tompsett's data.  These changes are detailed in "Master Data.xlsx"

Parser - "tree_cleaner.pl" is perl script that converts the correct genealogical data into 3 easier to read files listing families, birth/death dates, and marriage dates

Output: "families.csv","dates.csv","marriages.csv"

-----------------

Step 3:  Create (Timeless) Adjacency Matrix

Input: "families.csv","dates.csv"

"royalnet.m" is a Matlab script that converts the processed genealogical data into a 'timeless' network adjacency matrix that connects all siblings,spouses, and parents/children without regard to dates.

Output:  "net.mat"  (Matlab workspace including an adjacency matrix and an associated dates file)

-----------------

Step 4:  Add Kinship Network Covariates

Input:  "obs.csv", "marriages.csv","net.mat"

"addnetcov" is a Matlab program which is meant to be run in parallel on a cluster.  This program takes about 45 mins on 12 cores.  This generates the following variables:

path pair_deg death deathID placebo_death resistance

note:  If resistance fails to calculate for some years, this is noted in the output of `addnetcov'.  These years can be manually calculated with the "resistance.m" matlab program.  For example,  if resistance fails to calculate in 1595, this can be corrected using the following code:

obs=csvread('obs_net.csv');              
obs(obs(:,3)==1595,end)=resistance(1595);
csvwrite('obs_net.csv',obs) 

Output:  "obs_net.csv"

-----------------

Step 5:  Create Directed Blood Network

Input: "families.csv","dates.csv"

Genetic distance is based on a directed kinship network where connections run (only) from children to their parents.  This directed network is constructed using "famtree.m" which can be run locally.

Output: "famnet.mat" (Matlab workspace including a adjacency matrix and an associated dates file)

-----------------

Step 6:  Add Genetic Distance

Input: "obs.csv", "famnet.mat"

Genetic distance (i.e, blood distance) is calculated using "blooddist.m".  This file is meant to be run in parallel on a cluster.  This program should take about 5 mins on 12 cores.  This will output "obs_blood.csv" which includes a column for genetic distance.

Output: "obs_blood.csv"

-----------------

Step 7:  Add Third Party Death Dummy

Input: "thirdparty.csv", "obs_net.csv"

The Matlab script "thirdparty.m" appends a dummy variable to "obs_net.csv" denoting whether an on-path death was from a third-party country.

"thirdparty.csv" extracts columns A,L, and N from the "Shortest Path Death Covariates" tab of "Master Data.xlsx".  If Column N includes multiple entries, these are represented in additional columns in "thirdparty.csv"

Output: "obs_net2.csv"


-----------------

Step 8:  Create Stata Dataset

Input: "obs.csv","obs_net2.csv", "obs_blood.csv"

"Combine_Data.do" is a Stata Do-file which creates the stata data set based upon the output of the previous steps.  You need to adjust the working directory to your file path before running.

Output: "royal_obs_AEJ.dta"

-----------------

Step 9:  Regression Analyses

Input: "royal_obs_AEJ.dta"

"Regressions_AEJ.do" is a Stata Do-file which replicates the regressions included in the paper.  You need to adjust the working directory to your file path before running.

Note:  In many specifications estimated here, you should expect the "ivreghdfe" command to produce a warning regarding the number/size of clusters.  The warning suggests caution when interpreting the two-way cluster robust standard errors reported in the paper.  For this reason (among others) we also conduct randomization inference for our main result which agrees with the inferences suggested by the analytical standard errors that may be effected under this warning.

Output: "RoyalTables.tex"

Running "RoyalTables.tex" produces "RoyalTables.pdf" which contains the regression tables from the paper

-----------------

Step 10:  Event Studies

Input: "royal_obs_AEJ.dta"

"Event_Studies.do" is a Stata Do-file which produces the data underlying the the event study graphs included in the paper.  Standard errors are calculated based upon binomial statistics [i.e., se = sqrt(p*(1-p)/N].  

Reported 95% confidence intervals equal (mean +/- 1.96 * se).

Event study graphs are produced natively in the LaTeX file based on these results.

Output:

"Invpath_Event Study.csv"
"Onpath_Event Study.csv"
"Offpath_Event Study.csv"
"Unexpected_Event Study.csv"
"Anywar_Event Study.csv"
"Wars_By_Decade.csv"
"Conn_By_Decade.csv"

Running "Figures 4-7.tex" produces the event study figures contained in the paper.

-----------------

Step 11:  Robust Randomization Inference


Input: "royal_obs_AEJ.dta"

"Randomization_Inf.do" is a Stata Do-file which replicates the main IV analysis for 10,000 placebo datasets contructed as described in the robust randomization inference section of the paper.

This program is intended to be run on cluster using 12 cores.  This program takes about 2.5 hours.

Output: "simout10kb", "simout10kb.csv", "Randomization.log"

"Bins_Calc.xlsx" takes the results from simout10kb.csv and bins the data for a histogram.  The binned data is saved as "Bins.csv."  "Figure 8.tex" produces the histogram from Figure 8, the associated table is generated by stata and saved in "Randomization.log"

-----------------

Step 12:  Figures 1,2, and D4-D6

Input: "obs_blood.csv","obs_net2.csv","Rulers.csv", "Wars_By_Decade", "Conn_By_Decade.csv"

"Mapping_Code.m" produces the maps for Figure 1  (1618a.eps and 1618b.eps) and Figures D4-D6 (various other maps) in the appendix.

"Figure 2.tex" produces the kinship connection and war over time figure (Figure 2).

-----------------

Step 13:  Appendix

Input: "royal_obs_AEJ.dta"

“Appendix Analyses.do” directly produces Tables D2 and D3 (AppendixTables.tex), Figure D1 (Dyadic_War_Frequency.pdf),Figure D2 (BloodTiesOverTime.pdf), and Figure D3 (ConnectionsOverTime.pdf)

“Appendix Analyses.do” also produces data underlying Figure A1 (timeline.csv) and Table D1 (dyad_stats.csv).  		  

Figure A1 is then produced from “timeline.csv” using “Country Timeline.xlsx”.  Table D1 is created from "timeline.csv" in “Dyad_Coexistence.xlsx”


Note: Table A1 is produced in the “Appendix Death Table” tab of “Master Data.xlsx”

-----------------

Step 14:  In Text Estimates

Input: "royal_obs_AEJ.dta"

Calculations supporting all in-text numbers are described in “Notes on replicating in text estimates.txt”.  As necessary, “In text estimates.do” provides Stata code that performs these calculations.  The output from this code is saved in “In text estimates.do”
