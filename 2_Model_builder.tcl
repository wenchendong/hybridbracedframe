puts "System"
puts "System"
model BasicBuilder -ndm 2 -ndf 3
source WSection.tcl;				# procedure for creating W section
source LSection.tcl;				# procedure for creating double angle section
source RecSection.tcl
###Timber beam and column properties
#####Timber beam and columns
#side column
set A_col [expr [lindex $b_col 0]*[lindex $w_col 0]]
set I_col [expr [lindex $b_col 0]*[lindex $w_col 0]**3/12]
for {set i 1} {$i <= [expr $n_st-1]} { incr i} {
lappend A_col  [expr [lindex $b_col $i]*[lindex $w_col $i]]
lappend I_col  [expr [lindex $b_col $i]*[lindex $w_col $i]**3/12]
}
#middle column


set A_bm [expr [lindex $b_bm 0]*[lindex $w_bm 0]]
set I_bm [expr [lindex $b_bm 0]*[lindex $w_bm 0]**3/12]
for {set i 1} {$i <= [expr $n_st-1]} { incr i} {
lappend A_bm [expr [lindex $b_bm $i]*[lindex $w_bm $i]]
lappend I_bm [expr [lindex $b_bm $i]*[lindex $w_bm $i]**3/12]
}
###################


###Leaning columns
set A_lean 5000
set lean_num 20001
uniaxialMaterial Elastic $lean_num [expr 1e9]; #Stiff leanning column and beam



#brace materials
#uniaxialMaterial Steel02 $matID_Brace $Fy_b $Es $b 20 0.925 0.15 0.0005 0.01 0.0005 0.01
uniaxialMaterial Steel01 $matID_Brace_lower $Fy_b_lower $Es $b
uniaxialMaterial Steel01 $matID_Brace_upper $Fy_b_upper $Es $b
#uniaxialMaterial Fatigue $matID_fatBrace $matID_Brace -E0 $E0 -m $m -min -1.0 -max 0.04



uniaxialMaterial Steel01 $matID_col_lower $Fy_col_lower $Ecol_lower $b
uniaxialMaterial Steel01 $matID_col_upper $Fy_col_upper $Ecol_upper $b
for {set i 1} {$i <= $n_st } { incr i} {
if {$i==1} {
	WSection [lindex $Sec_tagbr [expr $i-1]] $matID_Brace_lower [lindex $dT [expr $i-1]] [lindex $bf [expr $i-1]] [lindex $tf [expr $i-1]] [lindex $tw [expr $i-1]] 10 1 10 1
	RecSection [lindex $Sec_tagcol [expr $i-1]] $matID_col_lower [lindex $w_col [expr $i-1]] [lindex $b_col [expr $i-1]]
	} else {
	LSection [lindex $Sec_tagbr [expr $i-1]] $matID_Brace_upper [lindex $d_L [expr $i-1]] [lindex $t_L [expr $i-1]] [lindex $xb [expr $i-1]]
	RecSection [lindex $Sec_tagcol [expr $i-1]] $matID_col_upper [lindex $w_col [expr $i-1]] [lindex $b_col [expr $i-1]]
	}
	

}

###Model building
puts "nodes"
for {set i 1} {$i <= $n_st } { incr i} {

if {$i ==1} {
#left column
node [expr ($i-1)*100+1] 0.0 0.0
#right column
node [expr ($i-1)*100+5] [expr $L] 0.0
#Beam
node [expr ($i-1)*100+7] 0.0 [lindex $H 0]
node [expr ($i-1)*100+8] [expr $L] [lindex $H 0]
} else {
#Left column
node [expr ($i-1)*100+1] 0.0 [expr ($i-2)*[lindex $H 1] +[lindex $H 0]]
#Right column
node [expr ($i-1)*100+5] [expr $L] [expr ($i-2)*[lindex $H 1] +[lindex $H 0]]
#Beam
node [expr ($i-1)*100+7] 0.0 [expr ($i-1)*[lindex $H 1] +[lindex $H 0]]
node [expr ($i-1)*100+8] [expr $L] [expr ($i-1)*[lindex $H 1] +[lindex $H 0]]
}
if {$i < $n_st} {
node [expr ($i-1)*100+2] 0.0 [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_f $mass_f 0.0
node [expr ($i-1)*100+6] [expr $L] [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_f $mass_f 0.0
} else {
node [expr ($i-1)*100+2] 0.0 [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_r $mass_r 0.0
node [expr ($i-1)*100+6] [expr $L] [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_r $mass_r 0.0
}




#node [expr ($i-1)*100+6] [expr $L/2] [expr ($i-1)*$H+$H]
#node [expr ($i-1)*100+7] $L [expr ($i-1)*$H+$H]
if {$i==1} {
    # Braces
	for {set j 1} {$j <= [expr $n_br+1] } { incr j} {
	node [expr ($i-1)*100+$j+20000] [expr 0.0+$L/$n_br*($j-1)] [expr [lindex $H 0]/$n_br*($j-1)]
	}
	
} else {
	if {[expr fmod($i,2)]>0} {
	for {set j 1} {$j <= [expr $n_br+1] } { incr j} {
	node [expr ($i-1)*100+$j+20000] [expr 0.0+$L/$n_br*($j-1)] [expr ($i-2)*[lindex $H 1]+[lindex $H 0]+[lindex $H 1]/$n_br*($j-1)]
	}
	} else {
	for {set j 1} {$j <= [expr $n_br+1] } { incr j} {
	node [expr ($i-1)*100+$j+20000] [expr 0.0+$L/$n_br*($j-1)] [expr [lindex $H 0]+($i-1)*[lindex $H 1]-[lindex $H 1]/$n_br*($j-1)]
	}
	}

}
#node [expr ($i-1)*100+8] 0.0 [expr ($i-1)*$H+0.0]
#node [expr ($i-1)*100+9] [expr $L/2] [expr ($i-1)*$H+$H]
#node [expr ($i-1)*100+10] [expr $L] [expr ($i-1)*$H+0.0]
#fix [expr ($i-1)*100+8] 0 0 1
#fix [expr ($i-1)*100+9] 0 0 1
#fix [expr ($i-1)*100+10] 0 0 1
    ##connection point
#node [expr ($i-1)*100+11] [expr $L/2] [expr ($i-1)*$H+$H] 
#fix [expr ($i-1)*100+11] 0 0 1

#leaning columns
if {$i < $n_st} {
 if {$i ==1} {
node [expr $i*1000+1] -500.0 0.0
node [expr ($i)*1000+2] -500.0 [lindex $H 0] -mass $mass_lean_f $mass_lean_f 0.0
} else {
node [expr $i*1000+1] -500.0 [expr ($i-2)*[lindex $H 1]+[lindex $H 0]]
node [expr ($i)*1000+2] -500.0 [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_lean_f $mass_lean_f 0.0
}
} else {
node [expr $i*1000+1] -500.0 [expr ($i-2)*[lindex $H 1]+[lindex $H 0]]
node [expr ($i)*1000+2] -500.0 [expr ($i-1)*[lindex $H 1]+[lindex $H 0]] -mass $mass_lean_r $mass_lean_r 0.0
}

}



set transfTag_Brace 1
geomTransf Corotational $transfTag_Brace


for {set i 1} {$i <= $n_st } { incr i} {
    #column sections
#element elasticBeamColumn [expr ($i-1)*100+1] [expr ($i-1)*100+1] [expr ($i-1)*100+2] [lindex $A_col [expr $i-1]] [lindex $E_col [expr $i-1]] [lindex $I_col [expr $i-1]] 1
#element elasticBeamColumn [expr ($i-1)*100+3] [expr ($i-1)*100+5] [expr ($i-1)*100+6] [lindex $A_col [expr $i-1]] [lindex $E_col [expr $i-1]] [lindex $I_col [expr $i-1]] 1

element forceBeamColumn [expr ($i-1)*100+1] [expr ($i-1)*100+1] [expr ($i-1)*100+2] 4 [lindex $Sec_tagcol [expr $i-1]] $transfTag_Brace -iter  $maxIter $tol

element forceBeamColumn [expr ($i-1)*100+3] [expr ($i-1)*100+5] [expr ($i-1)*100+6] 4 [lindex $Sec_tagcol [expr $i-1]] $transfTag_Brace -iter  $maxIter $tol
    #beam sections
element elasticBeamColumn [expr ($i-1)*100+4] [expr ($i-1)*100+7] [expr ($i-1)*100+8] [lindex $A_bm [expr $i-1]] [lindex $E_bm [expr $i-1]] [lindex $I_bm [expr $i-1]] 1
    #braces
	for {set j 1} {$j <= $n_br} {incr j} {
	element forceBeamColumn [expr ($i-1)*100+20000+$j] [expr ($i-1)*100+$j+20000] [expr ($i-1)*100+$j+1+20000] 4 [lindex $Sec_tagbr [expr $i-1]] $transfTag_Brace -iter  $maxIter $tol
	}



###leaning column (vertical and horizontal link)

element elasticBeamColumn [expr ($i)*1000+1] [expr ($i)*1000+1] [expr ($i)*1000+2] 10e6 [expr 10*35000] 10e11 1;#rigid beam for leaning column
element Truss [expr ($i)*1000+2] [expr ($i)*1000+2] [expr ($i-1)*100+2] $A_lean $lean_num



}



#if {$n_st>1} {
#for {set i 1} {$i <= [expr $n_st-1] } { incr i} {
   ##column connection for non-linearity
#element twoNodeLink [expr ($i-1)*100+7] [expr ($i-1)*100+9] [expr ($i-1)*100+6] -mat $Top_con_num_h $Top_con_num_v -dir 1 2    
#element twoNodeLink [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat $GIR_num -dir 2
#element twoNodeLink [expr ($i-1)*100+8] [expr ($i-1)*100+4] [expr ($i)*100+3] -mat $GIR_num -dir 2
#element twoNodeLink [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat $GIR_num -dir 2
#}
#}
###Restraints

puts "Equal DOF"
for {set i 1} {$i <= $n_st } { incr i} {
equalDOF [expr ($i-1)*100+2] [expr ($i-1)*100+7] 1 2; #beam column joint
equalDOF [expr ($i-1)*100+6] [expr ($i-1)*100+8] 1 2;
if {[expr fmod($i,2)]>0} {
equalDOF [expr ($i-1)*100+1] [expr ($i-1)*100+20001] 1 2; #braces
equalDOF [expr ($i-1)*100+6] [expr ($i-1)*100+20000+$n_br+1] 1 2; #braces
} else {
equalDOF [expr ($i-1)*100+2] [expr ($i-1)*100+20001] 1 2; #braces
equalDOF [expr ($i-1)*100+5] [expr ($i-1)*100+20000+$n_br+1] 1 2; #braces
}
}


#column-column joint
uniaxialMaterial Elastic 99 92640000
uniaxialMaterial Elastic 101 926400000
uniaxialMaterial ElasticBilin $GIR_num $EP1 $EP2 $epsP2 $EN1 $EN2 $epsN2
#for {set i 1} {$i <= [expr $n_st-1]} { incr i} {

#no rotation stiffness
uniaxialMaterial Elastic 100 10
#for {set i 1} {$i <= [expr $n_st-1]} { incr i} {
#  if {$i ==1} {
#	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 $GIR_num 100 -dir 1 2 3;
#	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 $GIR_num 100 -dir 1 2 3;  
#  } else {
#  if {[expr fmod($i,2)]>0} {
#	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 99 101 -dir 1 2 3;
#	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 $GIR_num 100 -dir 1 2 3;
#	 } else {
#	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 $GIR_num 100 -dir 1 2 3;
#	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 99 101 -dir 1 2 3;
#	 }
#	 }
#}

uniaxialMaterial Steel01 102 3153920 11662933 0.01
uniaxialMaterial Steel01 103 1536000 5680000 0.01
for {set i 1} {$i <= [expr $n_st-1]} { incr i} {
  if {$i ==1} {
	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 $GIR_num 100 -dir 1 2 3;
	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 $GIR_num 100 -dir 1 2 3;  
  } else {
  if {[expr fmod($i,2)]>0} {
	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 99 101 -dir 1 2 3;
	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 $GIR_num 100 -dir 1 2 3;
	 } else {
	element zeroLength [expr ($i-1)*100+7] [expr ($i-1)*100+2] [expr ($i)*100+1] -mat 99 $GIR_num 100 -dir 1 2 3;
	element zeroLength [expr ($i-1)*100+9] [expr ($i-1)*100+6] [expr ($i)*100+5] -mat 99 99 101 -dir 1 2 3;
	 }
	 }
equalDOF [expr ($i)*1000+2] [expr ($i+1)*1000+1] 1 2;
}

###boundary condition
fix 1 1 1 0
fix 5 1 1 0
#leaning column
fix 1001 1 1 0


source Get_Rendering.tcl
createODB "Modelplan"  "none"   0
createODB "Modelplan"  "Push"   0
# constraints Transformation
# numberer RCM
# system UmfPack
# #test NormDispIncr 1.e-8 30
# test NormDispIncr 1.e-8 30
# algorithm NewtonLineSearch
# #integrator LeeNewmark 0.5 0.25 0.02 4 0.02 143
# #integrator LeeNewmark 0.5 0.25 0.02 7.513
#
# #integrator LeeNewmark .5 .25 0.04125 0.0309 0.04125 0.1247 1 8.0167
# integrator Newmark 0.5 0.25
# analysis Transient
if {$loadingtype == 1} {
    puts "Running Static Analysis"

    source 5_Static_analysis.tcl
} elseif {$loadingtype == 2} {
puts "Running Dynamic Analysis..."
source 3_Dynamic_analysis.tcl
} else {
    puts "Running Pushover Analysis"

    source 5_Static_analysis.tcl

}