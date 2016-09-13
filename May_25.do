
/* improvements on May 25, 2012
(1) years of schooling as outcome variable.
(2) diff-diff table  and RDD picture
(3) shorter interval for RDD desgin

(4) Nancy Qian's survey data which contains info on enforcement of OCP in four provinces. 
*/
cd "C:\Users\wenyun\Desktop\data"


/*
do C:\Users\wenyun\Desktop\data\ipumsi_00003.do
save ipumsi_00003.dta, replace
*/
// No information on Urban/Rural Status 

set mem 1g

//============================================1982 data
/*
use ipumsi_00003.dta, clear
keep  FPP ethn_han female college prefcn provcn year age educcn empstat

// regression discontinuity
gen college = educcn == 40 | educcn == 50
gen female = sex == 2
gen ethn_han = ethncn == 1

gen FPP = age >= 19 & age <= 23  // assume that college attendance decision can only be made when one is 19 years old, and if the chance is missed, the opportunity is lost forever.

gen random = runiform()
keep if random < 0.01

gen insample = age >= 19 & age < 30 & ethn_han 
//xi3: reg college female age female*age FPP female*FPP if insample 
xi3: reg college female age FPP g.female*g.FPP if insample
xi3: reg college age g.female*g.FPP i.provcn if insample & random < 0.01
xi3: reg college age g.female*g.FPP i.prefcn if insample & random < 0.01

// diff-in-diff
replace insample = age >= 19 & age 

*/

// =========================================1990 data=========================================
use ipumsi_00005.dta, clear

gen college = educcn >= 40 & educcn <90  //notice that educcn in 1990 has a different codebook than educcn in 1982
gen female = sex == 2
gen ethn_han = ethncn == 1

gen insample = age >= 18 & age <= 41 & ethn_han   // just for a balanced sample on the two sides of cut-off point
gen FPP = age <= 30 & age >= 18

//xi3: reg college age g.female*g.FPP i.provcn if insample

sum college 

//diff-diff table

mat diff = [0,0,0\0,0,0]
forvalues i =  1/2 {
    forvalues j = 1/2 {
        sum college if female == `i' - 1 & FPP == `j' - 1 & ethn_han, meanonly
        mat diff[`i',`j']= r(mean)
    }
    mat diff[`i',3]=  diff[`i',2] -  diff[`i',1]
}
mat rownames diff = male female
mat colnames diff = before after change


 /*
//======================= Robustness check (different outcomes) ===============
// secondary education
gen sec_edu = educcn >= 30 & educcn < 40
//treatment group is younger than 16 in 1979 = younger than 27 in 1990
replace FPP = age <= 27 & age >= 16
replace insample = age >= 16 & age <= 38
replace female_FPP = female * FPP


xi3: reg sec_edu age g.female*g.FPP i.provcn if insample
probit sec_edu age female FPP female_FPP i.provcn if insample

//technical secondary education
gen sec_tech_edu = educcn >= 35 &  educcn < 40 
probit sec_tech_edu age female FPP female_FPP i.provcn if insample

//academic secondary education
gen sec_acd_edu = educcn >= 31 &  educcn < 35 
probit sec_acd_edu age female FPP female_FPP i.provcn if insample

*/






