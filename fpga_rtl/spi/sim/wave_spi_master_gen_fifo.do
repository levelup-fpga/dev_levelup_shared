onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/rst_n
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_clk
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_start_r
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_tx_lgt
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_rx_lgt
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_done_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_busy
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_tx_wr_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_tx_data
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_tx_full
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_rx_rd_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_rx_data
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/sys_fifo_rx_empty
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/spi_cs
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/spi_clk
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/spi_mosi
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/spi_miso
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_start_r_d
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_start_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_txd_rd_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_txd
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_rxd_dv_p
add wave -noupdate -radix hexadecimal /tb_spi_master_gen_fifo/u_spi_master_gen_fifo/s_sys_rxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {184 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {1774 ns}
