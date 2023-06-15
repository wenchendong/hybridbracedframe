puts "loading"
#####Gravity load#########
#wipeAnalysis
set factorG 9800;#scale factor for gravity to change m to mm;
  pattern Plain 100 Linear {
      #leaning columns
      for {set i 1} {$i <= [expr $n_st]} { incr i} {
        if {$i < $n_st} {
        load [expr ($i-1)*100+2] 0.0 [expr -$mass_f*$factorG] 0.0
        load [expr ($i-1)*100+4] 0.0 [expr -$mass_f*$factorG] 0.0
        load [expr ($i+1)*1000+1] 0.0 [expr -$mass_lean_f*$factorG] 0.0
        } else {
        load [expr ($i-1)*100+2] 0.0 [expr -$mass_r*$factorG] 0.0
        load [expr ($i-1)*100+4] 0.0 [expr -$mass_r*$factorG] 0.0
        load [expr ($i+1)*1000+1] 0.0 [expr -$mass_lean_r*$factorG] 0.0          
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
  loadConst  -time 0.0

set tol2 [expr pow(10.,-8)];###Tolerance judgement
#damping model
if {$Damp_model <=1} {
puts "Modal analysis"
##Mass only damping
set modeCount 1;
set pi [expr 2*asin(1.0)]
set lambdaN [eigen $modeCount];        # eigenvalue analysis for modeCount modes
set lambdaI [lindex $lambdaN [expr 0]];     # eigenvalue mode i = 1
set w1 [expr pow($lambdaI,0.5)];
#set w1 5.571035931430029 
puts "$w1"
rayleigh [expr 2*$xDamp*$w1] 0.0 0.0 0.0;
####Analysis setting
  constraints Transformation
  numberer RCM
  system BandGeneral
  test NormDispIncr $tol2 30
  algorithm NewtonLineSearch
  integrator Newmark 0.5 0.25
  analysis Transient
######
} else {
  constraints Plain
  numberer Plain
  system LeeSparse
  #test NormDispIncr $tol2 30
  test EnergyIncr $tol2 30
  algorithm Newton
  #algorithm SecantNewton
  integrator LeeNewmark .5 .25 0.0142    0.0080    0.0076    0.0080  0.0142 0.065 0.299 1 3.342 15.276 
  analysis Transient  
}



#### reading Intervals and NPTS
#set jjj 1
set inFilename3 time_Intervals_and_NPTS.txt
set fileId3 [open $inFilename3 "r"]
set count 0
while {[gets $fileId3 line] != -1} {
    incr count
    if {$count == $jjj} {  
    set dt [lindex $line 0];
    set npts [lindex $line 1];
    puts "$dt $npts"
    }
}
set eqPath "EQ/EQ_$jjj.acc"


set npts [expr $npts + 60.0/$dt]; #after the recorder, analysis for another 10s
set F 1.0;#scale factor read from file;


#set AccelSeries "Series -dt $dt -filePath $eqPath -factor [expr $F*$factorG]"
set AccelSeries 1
timeSeries Path $AccelSeries -dt $dt -filePath $eqPath -factor [expr $F*$factorG]
#puts "$AccelSeries"
pattern UniformExcitation $jjj 1 -accel $AccelSeries
#proc doDynamicAnalysis {npts dt stories h nodes modelType tol subSteps} {
source 4_recorder.tcl

set maxDiv 1024
set minDiv 8
set driftLimit 0.25; ##25% drift is huge

  #constraints Transformation
  #numberer RCM
  #system UmfPack
  ##test NormDispIncr 1.e-8 30
  #test NormDispIncr $tol2 30
  #algorithm NewtonLineSearch
  #integrator Newmark 0.5 0.25
  #analysis Transient



  set step 0
  set ok 0
  set break 0
  set maxDrift 0

while {$step<=$npts && $ok==0 && $break==0} {
  set step [expr $step+1]
  set ok 2
  set div $minDiv
  set len $maxDiv
  while {$div <= $maxDiv && $len > 0 && $break == 0} {
    set stepSize [expr $dt/$div]
    set ok [analyze 1 $stepSize]      
    if {$ok==0} {
      set len [expr $len-$maxDiv/$div]
      #check the drift
        set topDisp [nodeDisp 1 1]
        set botDisp [nodeDisp 2 1]
        set deltaDisp [expr abs($topDisp-$botDisp)]
        set drift [expr $deltaDisp/3600]
        if {$drift >= $driftLimit} {set break 1}  
    } else {
      set div [expr $div*2]
      puts "number of substeps increased to $div"
    }
  }
}
if {$break == 1} {
  set ok 1
}


  if {$ok == 0} {
  puts "analysis COMPLETED"
} elseif {$ok == 1} {
  puts "analysis FAILED - drift limit exceeded"
} else {
  puts "analysis FAILED - convergence problem"
}