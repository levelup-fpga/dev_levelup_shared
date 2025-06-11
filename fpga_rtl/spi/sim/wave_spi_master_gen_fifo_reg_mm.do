onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/g_CLK_DIV
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/g_SPI_CPOL
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/g_SPI_CPHA
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/rst_n
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/sys_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_addr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_wr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_wr_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_rd
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_rd_dv
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/reg_rd_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/irq_done_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/spi_cs
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/spi_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/spi_mosi
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/spi_miso
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_reg
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_fifo_wr_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_fifo_rd_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_sys_done_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_sys_fifo_rx_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_spi_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_spi_cs
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_spi_mosi
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_spi_miso
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_reg_wr_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_reg_wr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_reg_addr_d
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/s_reg_rd_d
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_rx_empty
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_rx_full
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_tx_empty
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_tx_full
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_busy
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_rx_lgt
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_tx_lgt
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_irq_en
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi_master_gen_fifo_reg_mm/a_start
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/g_RAM_ADDR_WIDTH
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/clk_sys
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/addr
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/writeEn
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/dataIn
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/readEn
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/readRdy
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/dataOut
add wave -noupdate -expand -group bus2bram -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_bus2bram/s_readEn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/g_MST_AD_WIDTH
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/rst_n
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/clk_sys
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/addr
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/writeEn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/dataOut
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/readEn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/dataIn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/spi_intf_clk
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/spi_intf_en
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/spi_intf_miso
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/spi_intf_mosi
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_done_8bit
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_done_8bit_d
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_data_out
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_data_in
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_spi_intf_en_d
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_sot_p
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_eot_p
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_trans_rwn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_trans_nb_32words
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_trans_base_reg_addr
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_trans_nb_8words
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_cnt_nb_8t
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_dataOut
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_addr
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_writeEn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_readEn
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_spi_intf_clk
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_spi_intf_en
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_spi_intf_miso
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/s_spi_intf_mosi
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_CMD_RANGE
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_RXN1_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_LGT0_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_TDB1_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_TDB0_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_ADR3_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_ADR2_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_ADR1_POS
add wave -noupdate -expand -group spi2bus -radix hexadecimal /tb_spi_master_gen_fifo_reg_mm/u_spi2bus/c_ADR0_POS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {209821 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 148
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
WaveRestoreZoom {190186 ns} {311266 ns}
