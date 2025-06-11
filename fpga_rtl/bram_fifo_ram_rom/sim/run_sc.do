

vlib work

vcom -93 -explicit -work work ../../util_package/util_pkg.vhd
vcom -93 -explicit -work work ../binary2gray.vhd
vcom -93 -explicit -work work ../gray2binary.vhd
vcom -93 -explicit -work work ../dpram_sc.vhd
vcom -93 -explicit -work work ../fifo_logic_sc.vhd
vcom -93 -explicit -work work ../fifo_sc.vhd
vcom -93 -explicit -work work ./tb_sc.vhd


vsim tb_sc

#Open some selected windows for viewing
view structure
view signals
view wave


#Run the simulation for 40 ns
do wave.do
run 4000000
