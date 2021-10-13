******************************
*** Delivery Care************* 
******************************
gen DHS_phase=substr(v000, 3, 1)
destring DHS_phase, replace

gen country_year="`name'"
gen year = regexs(1) if regexm(country_year, "([0-9][0-9][0-9][0-9])[\-]*[0-9]*[ a-zA-Z]*$")
destring year, replace
gen country = regexs(1) if regexm(country_year, "([a-zA-Z]+)")

rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

	*c_sba: Skilled birth attendance of births in last 2 years: go to report to verify how "skilled is defined"
	decode m3, gen(m3_lab)
	replace m3_lab = lower(m3_lab)

	gen c_sba = 0 if !inlist(m3,.,0,99,98)
	replace c_sba = 1 if ///
	!(!regexm(m3_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|medicin|hopital, pmi, disp|matrone, acc. aux.|sage-femme|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
	|regexm(m3_lab,"na^|-na|traditional birth attendant|untrained|unquallified|traditional midwife|birth attendant|empirical midwife") )

	/* do consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */

	*c_hospdel: child born in hospital of births in last 2 years  
	gen c_hospdel = .
	*c_facdel: child born in formal health facility of births in last 2 years
	gen c_facdel = . 
/*
	if inlist(name,"Indonesia1987"){
		gen m15 = .
		foreach k in 1 2 3 4 5 6{
			local k = "`k'"		
			tab k
			replace m15 = s404_`k' if k == bidx
		}
	}
*/
	if inlist(name,"Liberia1986"){
		ren s234a m15
	}	
	if inlist(name,"SriLanka1987"){
		ren s406 m15
	}
	if inlist(name,"Kenya1989","Thailand1987"){	
		ren s405a m15	
	}
	if inlist(name,"Tunisia1988"){	
		ren s507 m15	
	}
	if inlist(name,"Zimbabwe1988"){	
		ren s405 m15	
	}
	
	if inlist(name,"Tunisia1988","Zimbabwe1988"){	
		drop c_hospdel c_facdel 
		decode m15, gen(m15_lab)
		replace m15_lab = lower(m15_lab)
		
		gen c_hospdel = 0 if !mi(m15)
		replace c_hospdel = 1 if ///
		regexm(m15_lab,"medical college|surgical") | ///
		regexm(m15_lab,"hospital") & !regexm(m15_lab,"center|sub-center|post|clinic")
		replace c_hospdel = . if mi(m15) | inlist(m15,98,99) | mi(m15_lab)	
		// please check this indicator in case it's country specific	
		gen c_facdel = 0 if !mi(m15)
		replace c_facdel = 1 if regexm(m15_lab,"hospital") | ///
		!regexm(m15_lab,"home|other private|other$|pharmacy|non medical|private nurse|religious|abroad")
		replace c_facdel = . if mi(m15) | inlist(m15,98,99) | mi(m15_lab)
		// please check this indicator in case it's country specific	
	}

	*c_earlybreast: child breastfed within 1 hours of birth of births in last 2 years
	gen c_earlybreast = .
		
    *c_skin2skin: child placed on mother's bare skin immediately after birth of births in last 2 years
	gen c_skin2skin = .

	*c_sba_q: child placed on mother's bare skin and breastfeeding initiated immediately after birth among children with sba of births in last 2 years
	gen c_sba_q = (c_skin2skin == 1 & c_earlybreast == 1) if c_sba == 1
	replace c_sba_q = . if c_skin2skin == . | c_earlybreast == .
	
	*c_caesarean: Last birth in last 2 years delivered through caesarean                    
	gen c_caesarean = . 

	/*clonevar c_caesarean = m17
	replace c_caesarean = . if c_caesarean == 9 */
    *c_sba_eff1: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth)
	gen c_sba_eff1 = . 
	gen stay = .
	/*
	gen stay = 0
	replace stay = 1 if inrange(m61,2,90)
	replace stay = . if m61==. & !inlist(m15,11,12,96)
	//replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	//replace stay = . if inlist(m61,299,998,999,.)  // filter question, based on m15	
	
	gen c_sba_eff1 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1) 
	replace c_sba_eff1 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . 
	*/
	
	*c_sba_eff1_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth) among those with any SBA
    gen c_sba_eff1_q = c_sba_eff1 if c_sba == 1
	
	*c_sba_eff2: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact)
	gen c_sba_eff2 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1 & c_skin2skin == 1) 
	replace c_sba_eff2 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . | c_skin2skin == .
	
	*c_sba_eff2_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact) among those with any SBA
	gen c_sba_eff2_q = c_sba_eff2 if c_sba == 1
	



	
