
************************
*** Sexual health*******
************************ 	

	gen w_married=(v502==1)
	replace w_married=. if inlist(v502,.,9)
	
	*w_condom_conc: 18-49y woman who had more than one sexual partner in the last 12 months and used a condom during last intercourse
     ** Concurrent partnerships 
	gen wconc_partnerships=. //v766b Number of men including the husband is missing in Recode III
/* 	replace v766b=. if v766b==98|v766b==99
	gen wconc_partnerships=1 if v766b>1&v766b!=.
	replace wconc_partnerships=0 if v766b==0|v766b==1 */

     ** Condom usage
	 gen wcondom = .  //no condom useage data point in the Recode II. 
	/* rename v761 wcondom
		replace wcondom=. if wcondom==8|wcondom==9
		replace wcondom=. if v766b==0 | v766b==. */
		
	gen w_condom_conc=1 if wcondom==1&wconc_partnerships==1
    replace w_condom_conc=0 if wcondom==0&wconc_partnerships==1
	
    /*18-49y woman who had more than one sexual partner in the last 12 months and used a condom during last intercourse*/
    cap confirm variable w_condom_conc
    if _rc==0 {
    replace w_condom_conc=. if hm_age_yrs<18
    }

	*w_CPR: Use of modern contraceptive methods of women age 15(!)-49 married or living in union
	gen w_CPR=(v313==2)
    replace w_CPR=. if v313==.
    replace w_CPR=. if w_married!=1
	
	*w_unmet_fp 15-49y married or in union with unmet need for family planning (1/0)
	*w_need_fp 15-49y married or in union with need for family planning (1/0)
	*w_metany_fp 15-49y married or in union with need for family planning using modern contraceptives (1/0)
	*w_metmod_fp 15-49y married or in union with need for family planning using any contraceptives (1/0)
	gen w_unmet_fp=.
	gen w_need_fp=.
	gen w_metany_fp=.
	gen w_metmod_fp=.
	gen w_metany_fp_q=.
/*	
	 tempfile temp1 temp2 temp3
	 
	 preserve
     do "${DO}/Add unmetFP_DHS.do"
	 gen w_metany_fp = 1 if inlist(unmet,3,4)
     replace w_metany_fp = 0 if inlist(unmet,1,2) 
     keep caseid w_unmet_fp w_metany_fp
	 
     save `temp1'
	 restore
	 
	 preserve
	 do "${DO}/Add unmetFPmod_DHS.do"
     gen w_metmod_fp = 1 if inlist(unmet,3,4)
     replace w_metmod_fp = 0 if inlist(unmet,1,2)
	 
	 gen w_need_fp = 1 if w_metmod_fp!=.
     replace w_need_fp = 0 if inlist(unmet,7,9)
	 
     keep w_metmod_fp  w_need_fp w_metmod_fp caseid
	 save `temp2'
	 
	 merge 1:1 caseid using `temp1'
	 drop _merge
	 save `temp3'
	 restore 
	 
	 merge 1:m caseid using `temp3'
     drop if _m == 1
    
	replace w_metany_fp = . if w_married!=1
	replace w_metmod_fp = . if w_married!=1
	replace w_need_fp = . if w_married!=1
	replace w_unmet_fp = . if w_married!=1
	
    *w_metany_fp_q 15-49y married or in union using modern contraceptives among those with need for family planning who use any contraceptives (1/0)
    gen w_metany_fp_q = (w_CPR == 1) if w_need_fp == 1 
*/	 

	if inlist(name,"Bolivia1989"){
		gen hm_shstruct1 = substr(caseid,9,3)
		order caseid v000 v001 hm_shstruct1 v002
		destring hm_shstruct1,replace
		isid v001 hm_shstruct1 v002 v003
	}
	if inlist(name,"Colombia1986"){
		gen hm_shstruct1 = substr(caseid,8,3)
		order caseid v000 v001 hm_shstruct1 v002
		isid v001 hm_shstruct1 v002 v003
		destring hm_shstruct1,replace
	}
	if inlist(name,"Mali1987"){
		ren scnocon hm_shstruct1 
		order caseid v000 v001 hm_shstruct1 v002
		isid v001  hm_shstruct1 v002 v003  
	}	
	if inlist(name,"Peru1986"){
		ren sps hm_shstruct1 
		order caseid v000 v001 hm_shstruct1 v002
		isid v001  hm_shstruct1 v002 v003 
	}
	if inlist(name,"Tunisia1988"){
		gen hm_shstruct1 = substr(caseid,1,7)
		replace v001=274 if inlist(caseid,"      9274 1  2","      9274 4  2","      9274 3  2","      9274 7  2") 		
		order caseid v000 v001 hm_shstruct1 v002
		isid v001  hm_shstruct1 v002 v003 
		destring hm_shstruct1,replace
	}	
		
		
	cap gen hm_shstruct1 = 999
	cap gen hm_shstruct2 = 999
