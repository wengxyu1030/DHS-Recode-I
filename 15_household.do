
******************************
*****Household Level Info*****
******************************   

*hh_id	ID (generated)      
    clonevar hh_id = hhid
	
*hh_headed	Head's highest educational attainment (1 = none, 2 = primary, 3 = lower sec or higher)
	capture confirm variable hv106 hv101 
	if _rc == 0 {
    recode hv106 (0 = 1) (1 = 2) (2/3 = 3) (8 9=.) if hv101 == 1,gen(headed)
	bysort hh_id: egen hh_headed = min(headed)
	label define l_headed 1 "none" 2 "primary" 3 "lower sec or higher"
    label values hh_headed l_headed
	
	* Household Head - Education [hm file, computed]
	* create mod-education indicator
	gen temp_edu = hv106
		replace temp_edu = . if missing(hv101) | hv106 >=8 /*drop don't know or missing*/
		replace temp_edu = . if hv101 != 1 /*keep values for household heads*/

	* this methodology implies - when multiple household head, we take the highest
	bysort hv001 hv002: egen hh_headedu_comp = max(temp_edu) 
	drop temp_edu

	label define l_headedu 0 "none" 1 "primary" 2 "secondary" 3 "higher"
    label values hh_headedu_comp l_headedu
	
	}
	
	if _rc != 0 {
	gen hh_headed =.
	gen hh_headedu_comp = .
	}
* hh_country_code Country code
	clonevar hh_country_code = hv000 							  

*hh_region_num	Region of residence numerical (hv024)
    gen hh_region_num = .
	capture confirm variable hv024
	if _rc == 0 {
		replace hh_region_num = hv024
	}   	
*hh_region_lab	Region of residence label (v024)
    gen hh_region_lab =.
	capture confirm variable hv024
	if _rc == 0 {
		drop hh_region_lab
		decode hv024,gen(hh_region_lab)
	} 	
*hh_size # of members   
    gen hh_size = .
	capture confirm variable hv009
	if _rc == 0 {
		replace hh_size = hv009
	}            
*hh_urban Resides in urban area (1/0)
    gen hh_urban = .
	capture confirm variable hv025
	if _rc == 0 {
		drop hh_urban
		recode hv025 (2=0),gen(hh_urban)
	} 	
*hh_sampleweight Sample weight (v005/1000000)       
    gen hh_sampleweight = .
	capture confirm variable hv005
	if _rc == 0 {
		replace hh_sampleweight = hv005/10e6
	} 
*hh_wealth_quintile	Wealth quintile  
    gen hh_wealth_quintile = . 
    capture confirm variable hv270 
    if _rc == 0 {    
    replace hh_wealth_quintile = hv270                          
	}
	
*hh_wealthscore	Wealth index score   
    capture confirm variable hv271
	if _rc == 0 {
	clonevar hhwealthscore_old = hv271
	egen hhwealthscore_oldmin=min(hhwealthscore_old) 
	gen hh_wealthscore=hhwealthscore_old-hhwealthscore_oldmin
	replace hh_wealthscore=hh_wealthscore/10e6 
	}
	
/*
* implementation for all other DHS waves, disabled for DHS-I
*hh_religion: religion of household head (DW Team Nov 2021)
	cap rename v130 hh_religion
	
*hh_watersource: Water source (hv201 in DHS HH dataset, already coded for MICS)
	rename hv201 hh_watersource

*hh_toilet: Toilet type (hv205 ??????, already coded for MICS)
	rename hv205 hh_toilet
*/


/* DW Apr 2022 */

* Household Head - Age [raw]
	capture confirm variable hv220
	if _rc == 0 {
		rename hv220 hh_headage_raw	
	}
	else {
		gen hh_headage_raw = .
	}

* Household Head - Sex [raw]
	capture confirm variable hv219
	if _rc == 0 {	
		rename hv219 hh_headsex_raw	
	}
	else {
		gen hh_headsex_raw = .
	}	

*hv001 Sampling cluster number (original)
*hv002 Household number (original)
*hv003 Respondent's line number in household roster (original)
	
duplicates drop hv001 hm_shstruct1 hm_shstruct2 hv002,force
	
