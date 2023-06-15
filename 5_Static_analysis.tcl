puts "loading"
#####Gravity load#########
#wipeAnalysis
set factorG 9800;#scale factor for gravity to change m to mm;
  pattern Plain 100 Linear {
      #leaning columns
      for {set i 1} {$i <= [expr $n_st]} { incr i} {
        if {$i < $n_st} {
        load [expr ($i-1)*100+2] 0.0 [expr -$mass_f*$factorG] 0.0
		load [expr ($i-1)*100+6] 0.0 [expr -$mass_f*$factorG] 0.0
		load [expr ($i)*1000+2] 0.0 [expr -$mass_lean_f*$factorG] 0.0
        } else {
        load [expr ($i-1)*100+2] 0.0 [expr -$mass_r*$factorG] 0.0
		load [expr ($i-1)*100+6] 0.0 [expr -$mass_r*$factorG] 0.0
		load [expr ($i)*1000+2] 0.0 [expr -$mass_lean_r*$factorG] 0.0		
        }  
      }
  }
  constraints Transformation
  numberer RCM
  system UmfPack
  test NormDispIncr 1.0e-10 20
  algorithm Newton
  integrator LoadControl   0.1
  analysis Static
 
  analyze 10;#Load to full gravity in 10 steps
  loadConst  -time 0.0;#maintain constant gravity loads and reset time to zero

if {$loadingtype == 1} {
puts "Cyclic loading"

set P 1
pattern Plain 200 "Linear"  {
	load $node $P 0 0
}

constraints Plain
numberer RCM
system SparseGEN
test NormDispIncr 1.0e-12 30
algorithm Newton
integrator LoadControl 1
analysis Static
analyze 1

source SmartAnalyze.tcl
source 4_recorder.tcl
SmartAnalyzeStatic $node $dof $step $protocol
} elseif { $loadingtype == 3} {
puts "Pushover analysis"

set P 1
#pattern Plain 200 "Linear"  {
#for {set i 1} {$i <= $n_st} {incr i} {
#	load [expr ($i-1)*100+2] [expr $P*$i] 0 0
#}
#}

pattern Plain 200 "Linear"  {
	load 2 [expr $P*23.4] 0 0
	load 102 [expr $P*10.8] 0 0
	load 202 [expr $P*16.7] 0 0
	load 302 [expr $P*23.0] 0 0
	load 402 [expr $P*29.7] 0 0
	load 502 [expr $P*20.5] 0 0
}

source 4_recorder.tcl
#constraints Transformation
#numberer RCM
#system UmfPack
#test NormDispIncr 1.0e-12 30
#algorithm Newton
#integrator LoadControl 0.1
#analysis Static
#analyze 10
source SmartAnalyze.tcl

SmartAnalyzeStatic $node $dof $step $protocol

}
#damping model



