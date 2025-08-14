onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_full_cycle_rom/s_stop_condition
add wave -noupdate /tb_full_cycle_rom/s_rst_n
add wave -noupdate /tb_full_cycle_rom/s_sys_clk
add wave -noupdate /tb_full_cycle_rom/s_rom_rd
add wave -noupdate /tb_full_cycle_rom/s_rom_dout
add wave -noupdate /tb_full_cycle_rom/s_rom_dfirst
add wave -noupdate /tb_full_cycle_rom/s_rom_dlast
add wave -noupdate /tb_full_cycle_rom/c_GBL_CLK_PERIOD
add wave -noupdate /tb_full_cycle_rom/c_RST_DURATION
add wave -noupdate /tb_full_cycle_rom/c_ADDR_WIDTH
add wave -noupdate /tb_full_cycle_rom/c_DATA_WIDTH
add wave -noupdate /tb_full_cycle_rom/c_MEM_IMG_FILENAME
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/g_ADDR_WIDTH
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/g_DATA_WIDTH
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/g_MEM_IMG_FILENAME
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/i_clk
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/i_re
add wave -noupdate /tb_full_cycle_rom/u_full_cycle_rom/u_rom/i_addr
add wave -noupdate -format Analog-Step -height 84 -max 32767.0 -min -32768.0 -radix decimal /tb_full_cycle_rom/u_full_cycle_rom/u_rom/o_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {955068 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1050 us}
