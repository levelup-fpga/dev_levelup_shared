onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/g_CLK_DIV
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/g_SPI_CPOL
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/g_SPI_CPHA
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/rst_n
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/sys_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_addr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_wr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_wr_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_rd
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_rd_dv
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/reg_rd_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/irq_done_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/spi_cs
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/spi_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/spi_mosi
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/spi_miso
add wave -noupdate -group spi_master -radix hexadecimal -childformat {{/tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(3) -radix hexadecimal} {/tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(2) -radix hexadecimal} {/tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(1) -radix hexadecimal} {/tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(0) -radix hexadecimal}} -expand -subitemconfig {/tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(3) {-height 15 -radix hexadecimal} /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(2) {-height 15 -radix hexadecimal} /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(1) {-height 15 -radix hexadecimal} /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg(0) {-height 15 -radix hexadecimal}} /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_fifo_wr_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_fifo_rd_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_sys_done_p
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_sys_fifo_rx_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_spi_clk
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_spi_cs
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_spi_mosi
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_spi_miso
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg_wr_data
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg_wr
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg_addr_d
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/s_reg_rd_d
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_rx_empty
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_rx_full
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_tx_empty
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_tx_full
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_busy
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_rx_lgt
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_tx_lgt
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_irq_en
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/a_start
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/c_REG_0
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/c_REG_1
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/c_REG_2
add wave -noupdate -group spi_master -radix hexadecimal /tb_spi2bus_xbar/u_spi_master_gen_fifo_reg_mm/c_REG_3
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/g_NB_SLV_CS
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/g_MST_ADDRW
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/clk
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/rst
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_addr
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_data_out
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_data_in
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_rd
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_wr
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/mst_ready
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/slv_addr
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/slv_data_in
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/slv_data_out
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/slv_rd
add wave -noupdate -group busXbar -radix hexadecimal -childformat {{/tb_spi2bus_xbar/u_busXbar/slv_wr(7) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(6) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(5) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(4) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(3) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(2) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(1) -radix hexadecimal} {/tb_spi2bus_xbar/u_busXbar/slv_wr(0) -radix hexadecimal}} -subitemconfig {/tb_spi2bus_xbar/u_busXbar/slv_wr(7) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(6) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(5) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(4) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(3) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(2) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(1) {-height 14 -radix hexadecimal} /tb_spi2bus_xbar/u_busXbar/slv_wr(0) {-height 14 -radix hexadecimal}} /tb_spi2bus_xbar/u_busXbar/slv_wr
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/slv_ready
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/s_sel
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/s_addr_i
add wave -noupdate -group busXbar -radix hexadecimal /tb_spi2bus_xbar/u_busXbar/s_data_i
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/g_MST_AD_WIDTH
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/rst_n
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/clk_sys
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/addr
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/writeEn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/dataOut
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/readEn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/dataIn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/spi_intf_clk
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/spi_intf_en
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/spi_intf_miso
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/spi_intf_mosi
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_done_8bit
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_done_8bit_d
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_data_out
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_data_in
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_spi_intf_en_d
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_sot_p
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_eot_p
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_trans_rwn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_trans_nb_32words
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_trans_base_reg_addr
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_cnt_nb_8t
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_dataOut
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_addr
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_writeEn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_readEn
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_spi_intf_clk
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_spi_intf_en
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_spi_intf_miso
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/s_spi_intf_mosi
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_CMD_RANGE
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_RXN1_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_LGT0_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_TDB1_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_TDB0_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_ADR3_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_ADR2_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_ADR1_POS
add wave -noupdate -group spi2bus -radix hexadecimal /tb_spi2bus_xbar/u_spi2bus/c_ADR0_POS
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/g_LED_WIDTH
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/rst_n
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/clk_sys
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/addr
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/writeEn
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/dataIn
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/readEn
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/readRdy
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/dataOut
add wave -noupdate -group k2000 -radix hexadecimal /tb_spi2bus_xbar/u_bus2k2000/led_out
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/g_RAM_ADDR_WIDTH
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/clk_sys
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/addr
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/writeEn
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/dataIn
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/readEn
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/readRdy
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/dataOut
add wave -noupdate -group ram1 -radix hexadecimal /tb_spi2bus_xbar/u1_bus2bram/s_readEn
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/addr
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/clk_sys
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/dataIn
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/dataOut
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/g_RAM_ADDR_WIDTH
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/readEn
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/readRdy
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/s_readEn
add wave -noupdate -expand -group ram2 -radix hexadecimal /tb_spi2bus_xbar/u2_bus2bram/writeEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {388565 ns} 0}
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
WaveRestoreZoom {0 ns} {3050389 ns}
