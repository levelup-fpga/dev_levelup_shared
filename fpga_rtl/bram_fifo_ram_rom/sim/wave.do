onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group fifo_sc /tb_sc/uut/g_dwidth
add wave -noupdate -expand -group fifo_sc /tb_sc/uut/g_ddepth
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/clk
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/rst_n
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_din
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_wr
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_full
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_dout
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_rd
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/Fifo_empty
add wave -noupdate -expand -group fifo_sc /tb_sc/uut/Fifo_level
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_data_wr
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_addr_wr
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_wr
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_data_rd
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_addr_rd
add wave -noupdate -expand -group fifo_sc -radix hexadecimal /tb_sc/uut/s_Ram_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/g_dwidth
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/g_ddepth
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/clk
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/rst_n
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_din
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_full
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_dout
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Fifo_empty
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_data_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_addr_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_data_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_addr_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/Ram_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/s_fifo_full
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/s_fifo_empty
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/s_ram_cpt_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/s_ram_cpt_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/a_ram_addr_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/a_ram_loop_rd
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/a_ram_addr_wr
add wave -noupdate -group fifo_logic_sc /tb_sc/uut/u_fifo_logic_sc/a_ram_loop_wr
add wave -noupdate /tb_sc/s_clk
add wave -noupdate /tb_sc/s_rst_n
add wave -noupdate -group dpram_sc /tb_sc/uut/u_dpram_sc/g_dwidth
add wave -noupdate -group dpram_sc /tb_sc/uut/u_dpram_sc/g_ddepth
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/clk
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/rst_n
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_data_wr
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_addr_wr
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_wr
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_data_rd
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_addr_rd
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/Ram_rd
add wave -noupdate -group dpram_sc -radix hexadecimal /tb_sc/uut/u_dpram_sc/s_ram
add wave -noupdate -expand -group bingray /tb_sc/u_binary2gray/g_dwidth
add wave -noupdate -expand -group bingray /tb_sc/u_binary2gray/Binary
add wave -noupdate -expand -group bingray /tb_sc/u_binary2gray/Gray
add wave -noupdate -expand -group bingray /tb_sc/u_gray2binary/Gray
add wave -noupdate -expand -group bingray /tb_sc/u_gray2binary/Binary
add wave -noupdate -expand -group bingray /tb_sc/u_gray2binary/s_binary
add wave -noupdate -radix unsigned /tb_sc/s_cpt_in
add wave -noupdate -radix unsigned /tb_sc/s_cpt_out
add wave -noupdate -radix unsigned /tb_sc/s_cpt_gray
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2261695 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
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
configure wave -timelineunits ps
update
WaveRestoreZoom {3045422 ps} {4050241 ps}
