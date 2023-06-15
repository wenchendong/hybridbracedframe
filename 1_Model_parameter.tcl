
######GM number
set GM_num 1; ##number of ground motion
for {set jjj 1} {$jjj <= $GM_num} {incr jjj} {
wipe
set Astart [clock milliseconds];##record the start time
##Frame information
set L 6096.0;###Span
set H [subst {4572 3657.6}]; ##Height of first storey and the upper storey

#Maximum load combination
set mass_f [expr 14.5]; #mass on a floor (tons)27 kips according to calculation
set mass_r [expr 5.2]; #mass on the roof (tons) 24 kips
set mass_lean_f [expr 438]; #mass on non-lateral force resisting system (tons)
set mass_lean_r [expr 156]; #mass on non-lateral force resisting system (tons)
#Minimum load combination
#set mass_f [expr 5.5]; #mass on a floor (tons)27 kips according to calculation
#set mass_r [expr 2.16]; #mass on the roof (tons) 24 kips
#set mass_lean_f [expr 174]; #mass on non-lateral force resisting system (tons)
#set mass_lean_r [expr 62.5]; #mass on non-lateral force resisting system (tons)

set n_st 6; #Storey number
set n_br 10; #number of elements for steel braces
set tol 1.e-8
set maxIter 10
#####################

###brace section tag
set Sec_tagbr [subst {1 2 3 4 5 6}];#Section tag for braces
set d_L [subst {8 6 6 6 6 5}];#Double angle brace depth (in)
set t_L [subst {1.0 0.5 0.5 0.5 0.5 0.3125}];#Double angle brace thickness(in)
set xb [subst {2.37 1.86 1.86 1.86 1.86 1.37}];#Double angle brace centroid distance(in)


#I-section
set dT [subst {303.267 303.267 303.267 303.267 303.267 303.267}];#Depth total (mm)
set bf [subst {203.2 203.2 203.2 203.2 203.2 203.2}];#Width of flange (mm)
set tf [subst {13.08 13.08 13.08 13.08 13.08 13.08}];#thickness of flange (mm)
set tw [subst {7.49 7.49 7.49 7.49 7.49 7.49}];#thickness of web(mm)

#brace materials
set matID_Brace_upper 3
set matID_fatBrace 4
set Es [expr 29000.0*6.895];  # modulus of elasticity for steel
#set Fy [expr 50.0*6.895]; 	 # yield stress of steel (MPa)
set b 0.003;	 # strain hardening ratio
set Fy_b_upper [expr 36.0*6.895]; 	 # yield stress of steel
set E0 0.095
set m -0.5

set matID_Brace_lower 7
set Fy_b_lower [expr 50.0*6.895]; 	 # yield stress of steel
set E0 0.095
set m -0.5

#column materials
set matID_col_lower 5
set Ecol_lower 30338;  # modulus of elasticity for steel
set Fy_col_lower 27.5; #GL32h column
set matID_col_upper 6
set Ecol_upper 14200;  # modulus of elasticity for steel
set Fy_col_upper 25.6; #GL32h column
#####################

#################
#####################
#Side column
set Sec_tagcol [subst {7 8 9 10 11 12}];#Section tag for braces

set w_col [subst {500 457 457 457 457 457}];### Column depth from 1st floor to roof (mm)
set b_col [subst {500 280 280 280 280 280}];### Column breadth from 1st floor to roof (mm)
#set w_col [subst {500 250 250 250 250 250}];### Column depth from 1st floor to roof (mm)
#set b_col [subst {500 240 240 240 240 240}];### Column breadth from 1st floor to roof (mm)
#Middle column


set E_col [subst {35000 14200 14200 14200 14200 14200}]; ###Timber column MOE (MPa) GL32h
#####################
#####################


set w_bm [subst {560 560 560 560 560 480}];### Beam depth from 1st floor to roof (mm)
set b_bm [subst {2000 180 180 180 180 160}];### Beam breadth from 1st floor to roof (mm)
set E_bm [subst {35000 11000 11000 11000 11000 11000}];###Timber beam MOE (MPa) GL32c GL24c
#####################
##Timber column connection properties
set GIR_num 4001
set EP1 182000.0;#steel rod in tension
set EP2 [expr 182000.0*0.1]
set epsP2 0.35;
set EN1 3788000.0;##timber compression
set EN2 [expr 3788000.0*0.1]
set epsN2 0.5


#####################
##analysis type
set loadingtype 3.0; #Static 1.0; Dynamic 2.0. Pushover 3.0;
set analysistype 1.0; #Monotonic 1.0; Cyclic 2.0.
#################

####################



#### Static loading (one point) 
if {$loadingtype == 1} {
    set node [expr ($n_st-1)*100+2]; ###loading point
    set dof 1
    set step 0.1
    set protocol {2.0};##Monotonic loading
    #set protocol {15.0 -15.0 30.0 -30.0 60.0 -60.0 72.0 -72.0 0.0};###cyclic loading
##### 
} elseif {$loadingtype == 2} {
  ###Damping setting
    set Damp_model 1; #1. Rayleigh model; #2 Chin-long model
    set xDamp 0.02; ###elastic damping ratio
}  else {
    #set node [expr ($n_st+1)*1000+1]; ##Pushover analysis
	set node [expr ($n_st-1)*100+2]; ##Pushover analysis[expr ($i-1)*100+2]
    set dof 1
    set step 0.1
    set protocol {160.0}  
}
source 2_Model_builder.tcl

set Afinish [clock milliseconds]
set ArunTime [expr ($Afinish-$Astart)/1000.0]
puts "Ground Motion Done. End Time: $ArunTime s."
}
