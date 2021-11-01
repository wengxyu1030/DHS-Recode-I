
**************************
*** Child illness ********
**************************   
	   	
/* 
Note: for phase 6: V000 = AM6 CG6 KE6, use the old code for formal provider for ARI and Diarrhea.
Because the for the formal provider, the information can not be captured from the variable label, but only 
from the report/survey, which presented in the adeptfile. 
 */


rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

*c_diarrhea Child with diarrhea in last 2 weeks
	    gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/
		replace c_diarrhea=. if h11   ==8|h11  ==9|h11  ==. 

		if inlist(name,"Sudan1989"){
			gen ccough=1 if s427 ==1
			replace ccough = 0 if s427 ==2
			replace ccough=. if s427 ==8|s427  ==. 
		}	
					  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
		cap gen h13b  =. 
		gen c_treatdiarrhea=(h13  ==1|h13  ==2|h13b  ==1) 	if c_diarrhea == 1							/*ORS for diarrhea*/
		replace c_treatdiarrhea=. if (h13  ==8|h13  ==9 | h13  ==.)&(h13b  ==8|h13b  ==9 | h13b  ==.) 
		
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
        gen c_diarrhea_hmf=(h14  ==1|h14  ==2) if c_diarrhea == 1			/* home made fluid for diarrhea*/
		replace c_diarrhea_hmf=. if h14  ==8|h14  ==9 | h14  ==. 
		
*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)
       /*please cross check as there might be case where the diarreha treatment provider is not in h12a-h12x*/
	  gen c_diarrhea_pro = .
	  replace c_diarrhea_pro = 1 if inlist(h12,1,2,3)  & c_diarrhea == 1
	  replace c_diarrhea_pro = 0 if !inlist(h12,1,2,3,.) & c_diarrhea == 1
	  
	  if inlist(name,"Uganda1988"){
		replace c_diarrhea_pro =1 if h12 == 4 //dispensaire
	  }
	  if inlist(name,"Morocco1987"){
		replace c_diarrhea_pro =1 if h12 == 6 //guerisseur
	  }
	  if inlist(name,"SriLanka1987"){
		replace c_diarrhea_pro =.
		replace c_diarrhea_pro = 1 if h12 == 1 & c_diarrhea == 1
		replace c_diarrhea_pro = 0 if inlist(h12,0,2,3)
	  }
	  if inlist(name,"Tunisia1988"){
		replace c_diarrhea_pro = 1 if inlist(h12,4) & c_diarrhea == 1 // dispensaire
	  }
	  
		/*order h12a-h12x,sequential
	    foreach var of varlist h12a-h12x {
	    local lab: variable label `var' 	   
        replace `var' = . if ///
	    regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker)")  
	    replace `var' = . if !inlist(`var',0,1) 
	    }
	   /* do not consider formal if contain words in 
	   the first group but don't contain any words in the second group */
       
	    egen pro_dia = rowtotal(h12a-h12x),mi

        gen c_diarrhea_pro = 0 if c_diarrhea == 1
        replace c_diarrhea_pro = 1 if c_diarrhea_pro == 0 & pro_dia >= 1 
        replace c_diarrhea_pro = . if pro_dia == . 	
	   
	   /*for countries below there are categories that identified as formal 
	   provider but not shown in the label*/
		*/
*c_diarrhea_mof	Child with diarrhea received more fluids
		gen c_diarrhea_mof=h16 ==1 if !inlist(h16,.,8) & c_diarrhea == 1
		if inlist(name,"Uganda1988"){
			replace c_diarrhea_mof = . if s424e==8
		}
		if inlist(name,"Kenya1989"){
			replace c_diarrhea_mof = . if s424d==8
		}
		if inlist(name,"Sudan1989"){
			replace c_diarrhea_mof = . if s439==8
		}
		
*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific). 
		gen c_diarrhea_medfor =  h15 if c_diarrhea == 1 //  tablets,injections,syrup
/*
        egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h ),mi
		gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
		// formal medicine don't include "home remedy, herbal medicine and other"
		replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15e,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)
*/
*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
		gen c_diarrhea_med = h15  if c_diarrhea == 1
		if inlist(name,"Tunisia1988"){
			replace c_diarrhea_med = 1 if s542d==1 | s542e==1 // oralyte & other
		}
				
 /*     egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h),mi
        gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med!=.
        replace c_diarrhea_med = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15d,8,9)|inlist(h15e,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)
	*/
		
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
        gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
		replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1		
					 					
*c_diarrheaact_q	Child with diarrhea who received any treatment or consultation and received ORS
        gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1
        replace c_diarrheaact_q = . if  c_treatdiarrhea == .
		
*c_fever	Child with a fever in last two weeks
        gen c_fever = .
		if inlist(name,"Sudan1989"){
			replace c_fever = 1 if s426 ==1 
			replace c_fever = 0 if s426 ==2
		}		
*c_sevdiarrhea	Child with severe diarrhea
        gen eat = .
		if inlist(name,"Kenya1989"){
			replace eat = 1 if inlist(s424e,2,4,5) & c_diarrhea == 1
			replace eat = 0 if inlist(s424e,1,3) & c_diarrhea == 1
		}		
		if inlist(name,"Sudan1989"){
			replace eat = 1 if inlist(s440,2,4,5) & c_diarrhea == 1
			replace eat = 0 if inlist(s440,1,3) & c_diarrhea == 1
		}
				
/*       gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8) & c_diarrhea == 1 */
        gen c_sevdiarrhea = (c_diarrhea==1 & (c_fever == 1 | c_diarrhea_mof == 1 | eat == 1)) 
		replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | c_diarrhea_mof ==.| eat==. 
		/* diarrhea in last 2 weeks AND any of the following three conditions: fever OR offered 
		more than usual to drink OR given much less or nothing to eat or stopped eating */
		
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
        gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
		replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
        gen iv = . //(h15c == 1) if !inlist(h15c,.,8,9) & c_diarrhea == 1
		gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1
		
*c_ari	Child with acute respiratory infection (ARI)	
        gen c_ari = . 
		/* Children under 5 with cough and rapid breathing in the 
		two weeks preceding the survey which originated from the chest. */
		
		gen c_ari2 = .
		if inlist(name,"Sudan1989"){
			replace c_ari2 = 0 if ccough != .
			replace c_ari2 = 1 if s429 == 1 & ccough == 1
			replace c_ari2 = . if inlist(s429,8,9)
			replace c_ari2 = . if ccough==1 & s429 == .
		}	
		/* Children under 5 with cough and rapid breathing in the 
		two weeks preceding the survey. */
		
 
*c_treatARI	Child with acute respiratory infection (ARI) symptoms seen by formal provider
	    /*please cross check as there might be case where the treatment provider is not in h32a-h32x*/
     	gen c_treatARI= .
        gen c_treatARI2= .
		
		if inlist(name,"Sudan1989"){
			egen ARI2 = rowtotal(s431a s431b s431c s431d s431f s431h s431i s431j),mi
			replace c_treatARI2=0 if c_ari2 !=. 
			replace c_treatARI2=1 if ARI2>=1 & ARI2<. & c_ari2 ==1
		}	
			
		/*	
     	gen c_treatARI= 0 if c_ari !=.
        gen c_treatARI2= 0 if c_ari2 !=. 
        
	    order h32a-h32x,sequential
	    foreach var of varlist h32a-h32x {
	    local lab: variable label `var' 
        replace `var' = . if ///
	    regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker)")  
		replace `var' = . if !inlist(`var',0,1) 
	    }
	    /* do not consider formal if contain words in 
	    the first group but don't contain any words in the second group */
        egen pro_ari = rowtotal(h32a-h32x),mi
		
		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}
	   */
		
*c_fevertreat	Child with fever symptoms seen by formal provider		
		gen c_fevertreat = .
		if inlist(name,"Sudan1989"){
			replace c_fevertreat=0 if c_fever !=. 
			replace c_fevertreat=1 if ARI2>=1 & ARI2<. & c_fever ==1
		}	

*c_illness	Child with any illness symptoms in last two weeks
   		gen c_illness = .
		replace c_illness =.
		
		gen c_illness2 = .
		replace c_illness2 =. 
		
*c_illtreat	Child with any illness symptoms taken to formal provider
        gen c_illtreat = . 
        gen c_illtreat2 = . 
