#0) --- just for fun puts -----------------------------------------------------------

puts {
  ModelSim general compile script version 1.0 : gvr
}



#1) --- Path to hdl sources -----------------------------------------------------------
set RTL_SRC_SPI     "../"
set RTL_SRC_FIFO    "../../bram_fifo_ram_rom/"
set RTL_SRC_UTIL    "../../util_package/"
set RTL_SRC_BUS     "../../bus_stuff/simpleBus"


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


vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_BUS/bus2bram.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit     $RTL_SRC_FIFO/dpram_sc_v2.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_BUS/spi2bus.vhd

vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_SPI/spi_slave.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_SPI/spi_master_gen_fifo_reg_mm.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit     $RTL_SRC_SPI/spi_master_gen_fifo.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit       $RTL_SRC_SPI/spi_master_gen.vhd

vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   $RTL_SRC_FIFO/fifo_sc.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit     $RTL_SRC_FIFO/fifo_logic_sc.vhd
vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit     $RTL_SRC_FIFO/dpram_sc.vhd



vcom -work $WORK_LIB -$VHDL_VERSION $VIEW_SCOPE -explicit   tb_spi_master_gen_fifo_reg_mm.vhd



#4) --- Load the simulation ------------------------------------------------------------


vsim  tb_spi_master_gen_fifo_reg_mm



#5) --- Open some selected windows for viewing ------------------------------------------
# may be conditional
view structure
view signals
view wave



#6) --- load wave files ------------------------------------------------------------------
do wave_spi_master_gen_fifo_reg_mm.do



#7) --- Run the simulation -------------------------------------------------------------
#TODO : select between TIME specified or "auto-sim end in TB)
#run $SIM_TIME -all

when {s_stop_condition} {
  stop
  echo "Test: OK!!"
}


run -all
