////////////////////////////////////////////////////////////////////////////////////////////////////
*** DHS MONITORING: I Minority
////////////////////////////////////////////////////////////////////////////////////////////////////

version 15.1
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

* Define root depend on the stata user. 
if "`c(username)'" == "xweng"     local pc = 1
	if "`c(username)'" == "robinwang"     local pc = 4

if `pc' == 1 global root "C:/Users/XWeng/OneDrive - WBG/MEASURE UHC DATA"
	if `pc' == 4 global root "/Users/robinwang/Documents/MEASURE UHC DATA"

* Define path for data sources
global SOURCE "${root}/RAW DATA/Recode I"
	if `pc' == 4 global SOURCE "/Volumes/Seagate Bas/HEFPI DATA/RAW DATA/DHS/DHS I"

* Define path for output data
global OUT "${root}/STATA/DATA/SC/FINAL"
	if `pc' == 4 global OUT "${root}/STATA/DATA/SC/FINAL"

* Define path for INTERMEDIATE
global INTER "${root}/STATA/DATA/SC/INTER"
	if `pc' == 4 global INTER "${root}/STATA/DATA/SC/INTER"

* Define path for do-files
if `pc' != 0 global DO "${root}/STATA/DO/SC/DHS/DHS-Recode-I"
	if `pc' == 4 global DO "/Users/robinwang/Documents/MEASURE UHC DATA/DHS-Recode-I"

* Define the country names (in globals) in by Recode
do "${DO}/0_GLOBAL.do"
global DHScountries_Recode_I "Brazil1986 Kenya1989 Senegal1986 SriLanka1987 Tunisia1988 Peru1986"
global DHScountries_Recode_I "SriLanka1987"

/*
The code is used to process Brazil1986  SriLanka1987 Tunisia1988 Kenya1989 Peru1986 Senegal1986

We cannot generate hm.dta from hh.dta for these survey points 
either because the hh.dta doesn't offer household members' line number 
or we cannot generate v001 v002 from hh.dta to match with birth.dta or ind.dta
The final dataset only contains children and women sample
*/	
	
foreach name in $DHScountries_Recode_I { //{

tempfile birth ind men hm hiv hh wi zsc iso hmhh

************************************
***domains using zsc data***********
************************************
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'zsc.DTA"	
if _rc == 0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'zsc.dta", clear
	
    if hwlevel == 2 {
		gen caseid = hwcaseid
		gen bidx = hwline   	
		gen name = "`name'"
		if inlist(name,"DominicanRepublic1991","SriLanka1987"){
			tempfile DRbirth
			preserve
			use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta",clear
			duplicates drop caseid bidx,force // drop 5 duplicates in DominicanRepublic1991, drop 1 in SriLanka1987
			save `DRbirth',replace
			restore 
			merge 1:1 caseid bidx using `DRbirth'
		}
		else merge 1:1 caseid bidx using "${SOURCE}/DHS-`name'/DHS-`name'birth.dta"
    	gen ant_sampleweight = v005/10e6  
    	drop if _!=3
		
		cap clonevar c_motherln = v003 /*DW Nov 2021 - use v003 from birth.dta in the zsc dependent code chunk*/
				
  		foreach var in hc70 hc71 hc72 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
   		replace hc72=. if hc72<-6 | hc72>5

		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
 		gen c_wasted=1 if hc72<-2
 		replace c_wasted=0 if hc72>=-2 & hc72!=.
		gen c_stunted_sev=1 if hc70<-3
		replace c_stunted_sev=0 if hc70>=-3 & hc70!=.
		gen c_underweight_sev=1 if hc71<-3
		replace c_underweight_sev=0 if hc71>=-3 & hc71!=.
		gen c_wasted_sev=1 if hc72<-3
		replace c_wasted_sev=0 if hc72>=-3 & hc72!=.		

*c_stu_was: Both stunted and wasted
		gen c_stu_was = (c_stunted == 1 & c_wasted ==1) 
		replace c_stu_was = . if c_stunted == . | c_wasted == . 
		label define l_stu_was 1 "Both stunted and wasted"
		label values c_stu_was l_stu_was		

*c_stu_was_sev: Both severely stunted and severely wasted		
		gen c_stu_was_sev = (c_stunted_sev == 1 & c_wasted_sev == 1)
		replace c_stu_was_sev = . if c_stunted_sev == . | c_wasted_sev == . 
		label define l_stu_was_sev 1 "Both severely stunted and severely wasted"
		label values c_stu_was_sev l_stu_was_sev
			
		rename ant_sampleweight c_ant_sampleweight 
		keep c_* caseid bidx hwlevel hc70 hc71 hc72
		save "${INTER}/zsc_birth.dta",replace
    }
/*
 	if hwlevel == 1 {
 		gen hhid = hwhhid
 		gen hvidx = hwline
 		merge 1:1 hhid hvidx using `hmhh', keepusing(hv103 hv001 hv002 hv005)
 		drop if hv103==0
 		gen ant_sampleweight = hv005/10e6
 		drop if _!=3
		gen ant_hm = 1
		
  		foreach var in hc70 hc71 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
 		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
	    
		rename ant_sampleweight c_ant_sampleweight
		keep c_* hhid hvidx hc70 hc71
		save "${INTER}/zsc_hm.dta",replace 
    }
*/
}

******************************
*****domains using birth data*
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta", clear	
	duplicates drop caseid bidx,force	// 1 duplicates in SriLanka1987, drop rather than assign a new id for it 
    gen hm_age_mon = (v008 - b3)        //hm_age_mon Age in months (children only)
    gen name = "`name'"
	
    do "${DO}/1_antenatal_care"
    do "${DO}/2_delivery_care"
    do "${DO}/3_postnatal_care"
    do "${DO}/7_child_vaccination"
    do "${DO}/8_child_illness"
    do "${DO}/10_child_mortality"
    do "${DO}/11_child_other"
	
	capture confirm file "${INTER}/zsc_birth.dta"
	if _rc == 0 {
	merge 1:1 caseid bidx using "${INTER}/zsc_birth.dta",nogen
	rename (hc70 hc71 hc72) (c_hc70 c_hc71 c_hc72)
    }

	cap clonevar c_motherln = v003 /*DW Nov 2021 - use v003 from birth.dta in the code chunk*/

*housekeeping for birthdata
   //generate the demographics for child who are dead or no longer living in the hh. 
   
    *hm_live Alive (1/0)
    
	recode b5 (1=0)(0=1) , ge(hm_live)   
	label var hm_live "died" 
	label define yesno 0 "No" 1 "Yes"
	label values hm_live yesno 

    *hm_dob	date of birth (cmc)
    gen hm_dob = b3  

    *hm_age_yrs	Age in years       
    gen hm_age_yrs = b8        

    *hm_male Male (1/0)         
    recode b4 (2 = 0),gen(hm_male)  
	
    *hm_doi	date of interview (cmc)
    gen hm_doi = v008
	
	*generate b16 as place holder
	//b16 Child's line number in household is missing in Recode III
	//gen b16 = s219  //s219 as alternative in Bangladesh1999, please check this by survey.
    cap gen b16 = . 
	
	*identify the case where there is no child line info in hm.dta 
    mdesc b16 
    gen miss_b16 = 1 if r(percent) == 100 

if miss_b16 != 1 {
rename (v001 v002 b16) (hv001 hv002 hvidx)
}

if miss_b16 == 1 {
rename (v000 v001 v002 v003) (hv000 hv001 hv002 hvidx) //v003 in birth.dta: mother's line number
}

	* FEB 2022 DW
	gen w_married=(v502==1)
	replace w_married=. if inlist(v502,.,9)
	
/*DW NOV 2021*/
*hh_religion: religion of household head (DW Team Nov 2021)
	cap clonevar hh_religion = v130
	
*hh_watersource: Water source (hv201 in DHS HH dataset, already coded for MICS)
	clonevar hh_watersource =  v113

*hh_toilet: Toilet type (hv205 ??????, already coded for MICS)
	clonevar hh_toilet = v116 

keep hv000 hv001 hv002 hvidx bidx c_* mor_* w_* hm_* hh_*
save `birth'


******************************
*****domains using ind data***
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'ind.dta", clear	
duplicates drop caseid,force // 1 duplicates in SriLanka1987, 5 in DominicanRepublic1991
gen name = "`name'"
gen hm_age_yrs = v012
    do "${DO}/4_sexual_health"
    do "${DO}/5_woman_anthropometrics"
    do "${DO}/16_woman_cancer"
*housekeeping for ind data

    *hm_dob	date of birth (cmc)
    gen hm_dob = v011  
	
	
keep v001 v002 v003 w_* hm_* 
rename (v001 v002 v003) (hv001 hv002 hvidx) 
save `ind' 

/*
************************************
*****domains using hm level data****
************************************
use "${SOURCE}/DHS-`name'/DHS-`name'hm2.dta", clear
    do "${DO}/13_adult"
    do "${DO}/14_demographics"
	
capture confirm file "${INTER}/zsc_hm.dta"
	if _rc == 0 {
		merge 1:1 hhid hvidx using "${INTER}/zsc_hm.dta",nogen
		rename (hc70 hc71) (hm_hc70 hm_hc71)
	}
	
    if _rc != 0 {
	  capture confirm file "${INTER}/zsc_birth.dta"
	    if _rc != 0 {
          do "${DO}/9_child_anthropometrics"  //if there's no zsc related file, then run 9_child_anthropometrics
	      rename ant_sampleweight c_ant_sampleweight
		}
    }	
	
gen c_placeholder = 1
keep hv001 hv002 hvidx  ///
a_* hm_* ln c_*  
save `hm'

capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta"
 	if _rc==0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta", clear
    do "${DO}/12_hiv"
 	}
 	if _rc!= 0 {
    gen a_hiv = . 
    gen a_hiv_sampleweight = .
    }  
cap gen hm_shstruct1 =999
cap gen hm_shstruct2 =999
keep a_hiv* hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx 
save `hiv'

use `hm',clear
merge 1:1 hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx using `hiv'
drop _merge
save `hm',replace
*/
************************************
*****domains using hh level data****
************************************
/*
tempfile birthfix
use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta",clear
duplicates drop caseid bidx,force	// 1 duplicates in SriLanka1987
gen name = "`name'"
	if inlist(name,"Colombia1986"){
		gen hm_shstruct1 = substr(caseid,9,2)
		order caseid v000 v001 hm_shstruct1 v002
		destring hm_shstruct1,replace
	}
	cap gen hm_shstruct1 = 999
	cap gen hm_shstruct2 = 999
	ren (v001 v002 v003) (hv001 hv002 hvidx)
save `birthfix',replace

use "${SOURCE}/DHS-`name'/DHS-`name'hm2.dta", clear

    merge 1:m hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx using `birthfix'
    drop _merge

************************************
*****domains using wi data**********
************************************
use "${SOURCE}/DHS-`name'/DHS-`name'hm2.dta", clear
    do "${DO}/15_household"
	
cap gen hm_shstruct1 = 999	
cap gen hm_shstruct2 = 999	

keep hhid hv001 hm_shstruct* hv002  hh_* //hv003
save `hh',replace
*/

************************************
*****merge to microdata*************
************************************
***match with external iso data
use "${SOURCE}/external/iso", clear 
keep country iso2c iso3c
replace country = "BurkinaFaso" if country == "Burkina Faso"
replace country = "DominicanRepublic" if country == "Dominican Republic"
replace country = "Moldova" if country == "Moldova, Republic of"
replace country = "Tanzania" if country == "Tanzania, United Republic of"
replace iso2c = "BU" if country == "Burundi"
save `iso'

***merge all subset of microdata
use `birth',clear 
mdesc hvidx //identify the case where there is no child line info in hm.dta 
gen miss_b16 = 1 if r(percent) == 100 

if miss_b16 == 1 {
   //when b16 is missing, the hm.dta can not be merged with birth.dta, the final microdata would be women and child only.
  
    append using `ind'
	*merge m:1 hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx using `ind',nogen update //merge child in birth.dta to mother in ind.dta
	

    //merge m:m hv001 hm_shstruct1 hm_shstruct2 hv002       using `hh',nogen update 
}
if miss_b16 != 1 {

  use `birth',clear //when b16 is not missing, the hm.dta can be merged with birth.dta, the final microdata has all household member info

    merge m:m hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx using `ind',nogen update
    
	//replace hm_headrel = 99 if _merge == 2
	//label define hm_headrel_lab 1 "head" 2 "wife/husband" 3 "son/daughter" 4 "son/daughter-in-law" 5 "grandchild" 6 "parent" 7 "parent-in-law" 8 "brother/sister" 10 "other relative" 11 "adopted child" 12 "not related" 13 "foster" 14 "stepchild" 99 "dead/no longer in the household"
	//label values hm_headrel hm_headrel_lab
	//replace hm_live = 0 if _merge == 2 | inlist(hm_headrel,.,12,98)
	//drop _merge
	
	*merge m:m hv001 hm_shstruct1 hm_shstruct2 hv002       using `hh',nogen update 
 
    *tab hh_urban,mi  //check whether all hh member + dead child + child lives outside hh assinged hh info
}

* add variables that should have been generated from hm.dta and hh.dta
	foreach k in  a_diab_treat a_inpatient_1y a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med a_bp_meas  hm_stay hm_headrel hh_sampleweight hh_headed  hh_region_num hh_region_lab  hh_size hh_urban hh_wealth_quintile a_hiv a_hiv_cat a_hiv_sampleweight {
		gen `k'=.
    }
	foreach k in c_underweight c_underweight_sev c_stunted c_stunted_sev c_wasted c_wasted_sev c_stu_was c_stu_was_sev ant_sampleweight{
		cap gen `k' = .
	}
	gen hh_country_code = hv000 
	gen ln = hvidx
	tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
	foreach k in hv001  hv002 {
		replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
		replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		replace `k'_alt = " "+`k'_alt if inrange(`k',0,999)
	}
	gen hh_id = hv001_alt+hm_shstruct1_alt+hv002_alt
	drop *_alt
	

capture confirm variable c_hc70 c_hc71 c_hc72
if _rc == 0 {
rename (c_hc70 c_hc71 c_hc72) (hc70 hc71 hc72)
}

capture confirm variable hm_hc70 hm_hc71 hm_hc72
if _rc == 0 {
rename (hm_hc70 hm_hc71 hm_hc72) (hc70 hc71 hc72)
}

capture confirm variable hc70 hc71 hc72
if _rc != 0 {
gen hc70=.
gen hc71=.
gen hc72=.
}

//rename c_ant_sampleweight ant_sampleweight

***survey level data
    gen survey = "DHS-`name'"
	gen year = real(substr("`name'",-4,.))
	tostring(year),replace
    gen country = regexs(0) if regexm("`name'","([a-zA-Z]+)")
	
	if inlist("`name'","SriLanka1987") {
		replace country = "Sri Lanka"
	}
	
    merge m:1 country using `iso',force
    drop if _merge == 2
	drop _merge
	pause on 
	pause check iso values
	
*** Quality Control: Validate with DHS official data
gen surveyid = iso2c+year+"DHS"
gen name = "`name'"


* to match with HEFPI_DHS.dta surveyid (differ in year)
	if inlist(name,"BurkinaFaso1993") {
		replace surveyid = "BF1992DHS"
	}
	
preserve
	do "${DO}/Quality_control"
	save "${INTER}/quality_control-`name'",replace
	cd "${INTER}"
	do "${DO}/Quality_control_result"
	save "${OUT}/quality_control",replace 
restore 
	
*** Specify sample size to HEFPI
	
    ***for variables generated from 1_antenatal_care 2_delivery_care 3_postnatal_care
	foreach var of var c_anc	c_anc_any	c_anc_bp	c_anc_bp_q	c_anc_bs	c_anc_bs_q ///
	c_anc_ear	c_anc_ear_q	c_anc_eff	c_anc_eff_q	c_anc_eff2	c_anc_eff2_q ///
	c_anc_eff3	c_anc_eff3_q	c_anc_ir	c_anc_ir_q	c_anc_ski	c_anc_ski_q ///
	c_anc_tet	c_anc_tet_q	c_anc_ur	c_anc_ur_q	c_caesarean	c_earlybreast ///
	c_facdel	c_hospdel	c_sba	c_sba_eff1	c_sba_eff1_q	c_sba_eff2 ///
	c_sba_eff2_q	c_sba_q	c_skin2skin	c_pnc_any	c_pnc_eff	c_pnc_eff_q c_pnc_eff2 ///
	c_pnc_eff2_q c_anc_public c_anc_hosp {
    replace `var' = . if !(inrange(hm_age_mon,0,23)& bidx ==1)
    }
	
	***for variables generated from 7_child_vaccination
	foreach var of var c_bcg c_dpt1 c_dpt2 c_dpt3 c_fullimm c_measles ///
	c_polio1 c_polio2 c_polio3{
    replace `var' = . if !inrange(hm_age_mon,15,23)
    }
	
	***for variables generated from 8_child_illness	
	foreach var of var c_ari c_ari2	c_diarrhea 	c_diarrhea_hmf	c_diarrhea_medfor	c_diarrhea_mof	c_diarrhea_pro	c_diarrheaact ///
	c_diarrheaact_q	c_fever	c_fevertreat	c_illness c_illness2	c_illtreat c_illtreat2	c_sevdiarrhea	c_sevdiarrheatreat ///
	c_sevdiarrheatreat_q	c_treatARI c_treatARI2	c_treatdiarrhea	c_diarrhea_med {
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for vriables generated from 9_child_anthropometrics
	foreach var of var c_underweight c_underweight_sev c_stunted c_stunted_sev c_wasted c_wasted_sev c_stu_was c_stu_was_sev ant_sampleweight hc70 hc71 hc72{
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for hive indicators from 13_adult
	foreach var of var a_diab_treat	a_inpatient_1y a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med a_bp_meas {
    replace `var'=. if hm_age_yrs<18
    }
	
*** Label variables
 	* DW Nov 2021
	rename hc71 c_wfa
	rename hc70 c_hfa
	rename hc72 c_wfh

    drop bidx surveyid
    do "${DO}/Label_var" 
	
*** Clean the intermediate data
    capture confirm file "${INTER}/zsc_birth.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_birth.dta"
    }	
    
	capture confirm file"${INTER}/zsc_hm.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_hm.dta"
    }	  

save "${OUT}/DHS-`name'.dta", replace   
}
