	macro drop namenew

	* prepare for reshape 
	if !inlist(name,"Bolivia1989","Colombia1986","DominicanRepublic1986","Ecuador1987","Egypt1988") & !inlist(name,"Guatemala1987","Mexico1987","Sudan1989","Thailand1987","TrinidadandTobago","Senegal1986"){
		duplicates drop
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",1)
				ren `var' `a'
		}
		
		foreach k in 1 2 3 4 5 6 7 8 9  {
			foreach var of varlist *0`k' {
				local a =  subinstr("`var'","0`k'","`k'",1)
				ren `var' `a'
			}
		}
		global namenew
		foreach var of varlist *10{
			local a = subinstr("`var'","10","@",.)
			global namenew $namenew `a'
		}
	}
	
	if inlist(name,"Bolivia1989","Colombia1986","DominicanRepublic1986","Ecuador1987","Egypt1988") | inlist(name,"Guatemala1987","Sudan1989","TrinidadandTobago"){
		global namenew
		foreach var of varlist *_01{
			local a = subinstr("`var'","01","@",.)
			global namenew $namenew `a'
		}
		foreach var of varlist *_0* {
				local a =  subinstr("`var'","_0","_",1)
				ren `var' `a'
		}
	}
	if inlist(name,"Mexico1987"){
		global namenew
		foreach var of varlist *_0* {
				local a =  subinstr("`var'","_0","_",1)
				ren `var' `a'
		}
		foreach var of varlist *_1{
			local a = subinstr("`var'","_1","_@",.)
			global namenew $namenew `a'
		}
	}	
	if inlist(name,"Thailand1987"){
		global namenew
		foreach var of varlist *0*{
			local a = subinstr("`var'","_0","_",.)
			ren `var' `a'
		}
		foreach var of varlist *_* {
			local a = subinstr("`var'","_","",.)
			ren `var' `a'
		}
		foreach k in  1 2 3 4 5 6 7 8 9 {
			ren (hhmara0`k' hhmarb0`k') (hhmara`k' hhmarb`k')
		}
		foreach var of varlist *10{
			local a = subinstr("`var'","10","@",.)
			global namenew $namenew `a'
		}
		ren (hhdoma9 hhdoma6) (hhdoma_9 hhdoma_6)
	}
	
	* Reshape & standardize the name 
	if inlist(name,"Bolivia1989"){   // cannot tell the household line number 
		sreshape long $namenew ,  i(paquete iviviend ihogar) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}		
		ren (paquete iviviend ihogar hvidxalt) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if sexo == . 
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (sexo edada ) (hv104 hv105)
		ren ( totper area pond) (hv009 hv025 hv005)
		clonevar hv024 = depto
		gen hv000 = "BO"
	}	
	if inlist(name,"Burundi1987"){  
		sreshape long $namenew ,  i(hhseg hhrugo) j(hvidxalt)
	
		ren (hhseg hhrugo hhordre) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 		
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsexe hhage ) (hv104 hv105)
		ren ( hhmemb hurbrur hpond) ( hv009 hv025 hv005)
		clonevar hv024 = hregion
		gen hv000 = "BU"
	}	
	if inlist(name,"Colombia1986"){  
		sreshape long $namenew ,  i(hsegment hviviend hhogar) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}		
		ren (hsegment hviviend hhogar horde) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if hvidx == . 		
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)			
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (sexo edad paren durmi) (hv104 hv105  hv101 hv103)
		ren (hpersona harea hhweight) (hv009 hv025 hv005)
		clonevar hv024 = hregion
		gen hv000 = "CO"
	}		
	
	if inlist(name,"DominicanRepublic1986"){   // no household member line number, need to drop this actually 
		sreshape long $namenew ,  i(hcuest hentcode) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}		
		drop if mi(hresi, hdurm, hsexo)
		bysort hcuest hentcode: gen hvidx = _n
		ren (hcuest hentcode) (hv001 hv002)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hsexo hedad hdurm) (hv104 hv105 hv103)
		ren (area) (hv025)
		bysort hhid: gen hv009 = _N 
		gen hv000 = "DR"
	}	
	if inlist(name,"Ecuador1987"){ 
		sreshape long $namenew ,  i(segmento viv) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}		
		ren (segmento viv h21) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 		
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (h25 h26  h24) (hv104 hv105 hv103)
		ren (region  npers area) (hv024 hv009 hv025)
		gen hv000 = "EC"
	}
	if inlist(name,"Egypt1988"){
		sreshape long $namenew ,  i(psu house) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}		
		ren (psu house q1) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,999)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (q12 q13 q7 q11) (hv104 hv105 hv101 hv103)
		ren (q17 totalh sshouse) (hv106 hv009 hv025)
		clonevar hv024 = govern 
		gen hv000 ="EG"
	}
	if inlist(name,"Ghana1988"){
		sreshape long $namenew ,  i(hcluster hhnumber) j(hvidxalt)
		
		ren (hcluster hhnumber hline) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hsex hage hslep hdoic ) (hv104 hv105 hv103 hv008)
		ren (hmembers htype hweight) (hv009 hv025 hv005)
		clonevar hv024 = hregion 
		gen hv000 = "GH"
	}
	if inlist(name,"Guatemala1987"){
		sreshape long $namenew ,  i(segmento vivienda hogar) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}			
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		ren (segmento  colrm) (hv001 hvidx)
		gen hv002 = 100*vivienda + hogar
		drop if hvidx == . 
		tostring hv001  hv002, gen(hv001_alt  hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (sexo edada durmi ) (hv104 hv105 hv103)
		ren (paren tpersona ) (hv101 hv009 )
		gen hv000 = "GU"
	}
	if inlist(name,"Indonesia1987"){
		sreshape long $namenew ,  i(hhprov hhnisamp hhsampno ) j(hvidxalt)
		ren (hhsampno  hhlno) ( hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		gen hv001 = hhprov*1000 +hhnisamp 
		drop if hvidx == . 
		tostring hv001   hv002, gen(hv001_alt  hv002_alt)
		foreach k in hv001  hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt +hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage hhevm ) (hv104 hv105 hv103)
		ren (hhedu nopers hharea hhweight) (hv106 hv009 hv025 hv005)
		clonevar hv024 = hhprov
		gen hv000 = "ID"
	}
	if inlist(name,"Kenya1989"){
		sreshape long $namenew ,  i(hdist hstrucno hclust hhhno) j(hvidxalt)
		ren (hdist  hhhno hhlin) (hm_shstruct1 hv002 hvidx)
		gen hv001 = hstrucno*1000+hclust
		gen hm_shstruct2 = 999		
		drop if hvidx == . 
		tostring hv001 hm_shstruct1   hv002, gen(hv001_alt hm_shstruct1_alt  hv002_alt)
		foreach k in hv001 hm_shstruct1   hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage hhliv) (hv104 hv105 hv103)
		ren (hhtot hurbrur hhwt) (hv009 hv025 hv005)
		clonevar hv024 = hprov
		gen hv000 = "KE"
	}
	if inlist(name,"Liberia1986"){
		sreshape long $namenew ,  i(hhclust hhhhno) j(hvidxalt)
		
		ren (hhclust hhhhno hhlin) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage hhsle) (hv104 hv105 hv103)
		ren hhweight  hv005
		bysort hhid: gen hv009 = _N
		clonevar hv024 = hhcounty
		gen hv000 = "LB"
	}
	if inlist(name,"Mali1987"){
		sreshape long $namenew ,  i(ccodese cnocon cnomen) j(hvidxalt)
		ren (ccodese cnocon cnomen cndor) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (csexe cage cresi ) (hv104 hv105 hv103)
		ren (cperson cstrate) (hv009 hv025)
		clonevar hv024 = cregion
		gen hv000 = "ML"
	}
	if inlist(name,"Mexico1987"){
		sreshape long $namenew ,  i(ncontrol cuest) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}			
		ren (ncontrol cuest hvidxalt) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if h003 == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (h005 h006 h004 h003) (hv104 hv105 hv101 hv103)
		//ren (hhtot  hurbrur pondhog) (hv009 hv025)
		//clonevar hv024 = hregion
		gen hv000 ="MX"
	}
	if inlist(name,"Morocco1987"){
		sreshape long $namenew ,  i(mgrappe  mmenage) j(hvidxalt)
		
		ren (mgrappe  mmenage mlign) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (msexe mage mhabi) (hv104 hv105 hv103)
		ren mmembres hv009
		gen hv025 = mstrate 
		replace hv025 = 1 if inrange(hv025,1,8)
		gen hv000 = "MA"
	}
/*	
	if inlist(name,"Senegal1986"){		
		ren (region sdr concess cndordre) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (msexe mage resident) (hv104 hv105 hv101)
		ren cndmenag   hv009
		gen hv000 = "SN"
	}	

	if inlist(name,"SriLanka1987"){
		sreshape long $namenew ,  i(hzone hward hsbn hhun hhno hhint) j(hvidxalt)		
		ren hhlno hvidx
		gen hv001 = hzone*1000000+hward*10000+hhun*100+hsbn
		gen hv002 = hhint*10+ hhno
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		order hv001 hv002 
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage hhresb) (hv104 hv105 hv103)
		ren (nopers  hsector hhsampwt) (hv009 hv025 hv005)
		clonevar hv024 =  hzone
		gen hv000 ="LK"
	}
*/
	if inlist(name,"Sudan1989"){
		sreshape long $namenew ,  i(hclust hhhno) j(hvidxalt)
		foreach var of varlist *_* {
				local a =  subinstr("`var'","_","",.)
				ren `var' `a'
		}			
		ren (hclust hhhno col1) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (col5 col6 col4) (hv104 hv105 hv103)
		ren (hhtot  hurbrur) (hv009 hv025)
		clonevar hv024 = hregion
		gen hv000 ="SD"
	}
	if inlist(name,"Thailand1987"){
		sreshape long $namenew ,  i(hhclust hhhhno) j(hvidxalt)
		
		ren (hhclust hhhhno hhlin) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex  hhage hhrel hhsle) (hv104 hv105  hv101 hv103)
		ren (nopers hhrururb hhwt) (hv009 hv025 hv005)
		clonevar hv024 = hhregion 
		gen hv000 = "TH"
	}
	if inlist(name,"Togo1988"){
		sreshape long $namenew ,  i(zone concess menage) j(hvidxalt)
		
		ren ( zone concess menage mlign) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (msexe mage mlien mresi) (hv104 hv105 hv101 hv103)
		ren (mmembres strate) (hv009 hv025)
		recode hv025 (1 2 = 1) (3=0)
		clonevar hv024 = region
		gen hv000 = "TG"
	}
	if inlist(name,"TrinidadandTobago1987"){
		sreshape long $namenew ,  i(hhclust hhhhno) j(hvidxalt)
		
		ren (hhclust hhhhno hhlno) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage) (hv104 hv105)
		ren (totpers) (hv009)
		gen hv000 ="TT"
	}
/*	
	if inlist(name,"Tunisia1988"){
		sreshape long $namenew ,  i(grappe numenage nbperson) j(hvidxalt)
		
		ren (grappe nbperson  numenage  mlign) (hv001 hm_shstruct1 hv002 hvidx)
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hm_shstruct1 hv002, gen(hv001_alt hm_shstruct1_alt hv002_alt)
		foreach k in hv001 hm_shstruct1 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,999)
		}
		gen hhid = hv001_alt+hm_shstruct1_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		order hhid hv001 hm_shstruct1 hm_shstruct2 hv002 hvidx
		ren (msexe mage mvisi) (hv104 hv105   hv103)
		//ren (hhrururb ) (hv025)
		gen hv009 = hv002
		clonevar hv024 = gouvern
		gen hv000 = "TN"
	}	
*/
	if inlist(name,"Uganda1988"){
		sreshape long $namenew ,  i(hhclust hhhhno) j(hvidxalt)
		
		ren (hhclust hhhhno hhlno) (hv001 hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hhsex hhage hhresb) (hv104 hv105 hv103)
		ren (nopers) (hv009)
		gen hv000 = "UG"
	}
	if inlist(name,"Zimbabwe1988"){
		sreshape long $namenew ,  i(hsegment hhnumber) j(hvidxalt)
	
		ren (hsegment hhnumber hline) (hv001  hv002 hvidx)
		gen hm_shstruct1 = 999
		gen hm_shstruct2 = 999
		drop if hvidx == . 
		tostring hv001 hv002, gen(hv001_alt hv002_alt)
		foreach k in hv001 hv002 {
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,9)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,99)
			replace `k'_alt = " "+`k'_alt if inrange(`k',0,999)
		}
		gen hhid = hv001_alt+hv002_alt
		order hhid hvidx
		isid hhid hvidx
		ren (hsex  hage hslep dohc) (hv104 hv105  hv103 hv008)
		ren (hmembers) (hv009)
		clonevar hv024 = hprov
		gen hv000 = "ZW"
	}	
	cap drop *alt
