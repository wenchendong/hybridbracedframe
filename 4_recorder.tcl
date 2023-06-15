puts "recorders"
if {$loadingtype ==2} {
for {set i 1} {$i <= [expr $n_st]} { incr i} {
recorder Node -file "results/EQ_($jjj)/Disp$i storey.out" -time -node [expr ($i-1)*100+2] -dof 1 disp
recorder Node -file "results/EQ_($jjj)/Acc$i storey.out" -timeSeries 1 -time -node [expr ($i-1)*100+2] -dof 1 accel
recorder Element -file "results/EQ_($jjj)/BRB$i storeydeformation.out" -time -element [expr ($i-1)*100+5] [expr ($i-1)*100+6] deformations
recorder Element -file "results/EQ_($jjj)/BRB$i storeyaxialforce.out" -time -element [expr ($i-1)*100+5] [expr ($i-1)*100+6] axialForce
recorder Element -file "results/EQ_($jjj)/Beam$i internalforce.out" -time -element [expr ($i-1)*100+3] [expr ($i-1)*100+4] globalForce;##will output Fx,Fy Mz
recorder Element -file "results/EQ_($jjj)/Column$i internalforce.out" -time -element [expr ($i-1)*100+1] [expr ($i-1)*100+2] globalForce;##will output Fx,Fy Mz
#recorder Node -file "results/EQ_($jjj)/Acc$i storey.out" -time -node [expr ($i-1)*100+2] -dof 1 accel
}
recorder Node -file "results/EQ_($jjj)/reaction1 storey.out" -time -node 1 3 1001 -dof 1 2 reaction;###reaction forces
} elseif {$loadingtype ==1} {
recorder Node -file Dispbased_movement.out -time -node $node -dof 1 disp; ##cyclic loading; more recorders need to be added/
for {set i 1} {$i <= [expr $n_st]} { incr i} {    
recorder Node -file "results/Disp$i storey.out" -time -node [expr ($i-1)*100+2] -dof 1 disp
recorder Element -file "results/BRB$i storeydeformation.out" -time -element [expr ($i-1)*100+5] [expr ($i-1)*100+6] deformations
recorder Element -file "results/BRB$i storeyaxialforce.out" -time -element [expr ($i-1)*100+5] [expr ($i-1)*100+6] axialForce
recorder Element -file "results/Beam$i internalforce.out" -time -element [expr ($i-1)*100+3] [expr ($i-1)*100+4] globalForce;##will output Fx,Fy Mz
recorder Element -file "results/Column$i internalforce.out" -time -element [expr ($i-1)*100+1] [expr ($i-1)*100+2] globalForce;##will output Fx,Fy Mz (positive in anti-clockwize direction)
}
recorder Node -file "results/reaction1 storey.out" -time -node 1 3 5 1001 20001 30011 -dof 1 2 reaction;###reaction forces
recorder Node -file "results/reaction2 storey.out" -time -node 20001 30011 -dof 1 2 reaction;###reaction forces
} else {
for {set i 1} {$i <= [expr $n_st]} { incr i} {    
recorder Node -file "results/Disp$i storey.out" -time -node [expr ($i-1)*100+2] -dof 1 disp
recorder Element -file "results/brace$i leftstoreydeformation.out" -time -element [expr ($i-1)*100+20001] [expr ($i-1)*100+20000+$n_br] deformations
recorder Element -file "results/brace$i leftstoreyglobalforce.out" -time -element [expr ($i-1)*100+20001] [expr ($i-1)*100+20000+$n_br] globalForce
recorder Element -file "results/brace$i leftstoreylocalforce.out" -time -element [expr ($i-1)*100+20001] [expr ($i-1)*100+20000+$n_br] localForce
recorder Element -file "results/brace$i rightstoreydeformation.out" -time -element [expr ($i-1)*100+30001] [expr ($i-1)*100+30000+$n_br] deformations
recorder Element -file "results/brace$i rightstoreyglobalforce.out" -time -element [expr ($i-1)*100+30001] [expr ($i-1)*100+30000+$n_br] globalForce
recorder Element -file "results/brace$i rightstoreylocalforce.out" -time -element [expr ($i-1)*100+30001] [expr ($i-1)*100+30000+$n_br] localForce
recorder Element -file "results/Beam$i internalforce.out" -time -element [expr ($i-1)*100+4] [expr ($i-1)*100+5] localForce;##will output Fx,Fy Mz
recorder Element -file "results/Column$i internalforce.out" -time -eleRange [expr ($i-1)*100+1] [expr ($i-1)*100+3] localForce;##will output Fx,Fy Mz
recorder Node -file "results/bracedeformation$i calculation.out" -time -node [expr ($i-1)*100+4] -dof 1 2 disp;##middle span deformation
recorder Element -file "results/bracefibre$i stressstrain.out" -ele [expr ($i-1)*100+20001] section $i fiber 0.0 0.0 stressStrain;
#recorder Node -file "results/bracedeformation$i calculation2.out" -time -node 4 -dof 1 disp;##middle span deformation
}
for {set i 1} {$i < [expr $n_st]} {incr i} {
recorder Element -file "results/link$i internalforce.out" -time -eleRange [expr ($i-1)*100+7] [expr ($i-1)*100+9] localForce;##will output Fx,Fy Mz
recorder Element -file "results/link$i deformation.out" -time -eleRange [expr ($i-1)*100+7] [expr ($i-1)*100+9] deformations;##will output Fx,Fy Mz
recorder Element -file "results/link$i internalforce2.out" -time -element [expr ($i-1)*100+7] [expr ($i-1)*100+9] localForce;##will output Fx,Fy Mz
}
recorder Node -file "results/reaction1 storey.out" -time -node 1 3 5 1001 20001 30011 -dof 1 2 reaction;###reaction forces

}