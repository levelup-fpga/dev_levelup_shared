#0) --- just for fun puts -----------------------------------------------------------

puts {
  ModelSim general compile script version 1.0 : gvr
}



#1) --- Path to hdl sources -----------------------------------------------------------
set RTL_SRC_PWM     "../"
set RTL_SRC_UTIL    "../../util_package/"


set RTL_SRC_SIM     ""

#2) --- vsim tool options  -----------------------------------------------------------
set WORK_LIB        "work"
set VHDL_VERSION    "93"
set SIM_TIME        "1000us"
set COVER_OPT       "bcst"
#for questasim (not used) => see if can be related to #5) views selection --
set VIEW_SCOPE      "+acc=rnp"




#3) --- vsim tool commands  -----------------------------------------------------------

#compile source in working directory ------------------------------------------------------
#TODO : add condition to delet and recompile (worth for all vcom cmds)

#tmpGV file delet -force $WORK_LIB
vlib $WORK_LIB

vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_UTIL/util_pkg.vhd


vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_PWM/pwm_gen.vhd



vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   tb_pwm_gen.vhd



#4) --- Load the simulation ------------------------------------------------------------


vsim  tb_pwm_gen



#5) --- Open some selected windows for viewing ------------------------------------------
# may be conditional
view structure
view signals
view wave



#6) --- load wave files ------------------------------------------------------------------
do wave_pwm_gen.do



#7) --- Run the simulation -------------------------------------------------------------
#TODO : select between TIME specified or "auto-sim end in TB)
#run $SIM_TIME -all

when {s_stop_condition} {
  stop
  echo "Test: OK!!"
}


run -all
