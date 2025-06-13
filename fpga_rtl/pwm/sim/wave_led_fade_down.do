onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_led_fade_down/u_led_fade_down/g_prescale_div
add wave -noupdate /tb_led_fade_down/u_led_fade_down/g_fade_step_cpt
add wave -noupdate /tb_led_fade_down/u_led_fade_down/sys_clk
add wave -noupdate /tb_led_fade_down/u_led_fade_down/rst_n
add wave -noupdate /tb_led_fade_down/u_led_fade_down/led_in
add wave -noupdate /tb_led_fade_down/u_led_fade_down/led_out
add wave -noupdate -format Analog-Step -height 84 -max 7.0000000000000009 -min -8.0 /tb_led_fade_down/u_led_fade_down/s_fade_step_cpt
add wave -noupdate /tb_led_fade_down/u_led_fade_down/s_dec_fade_p
add wave -noupdate -format Analog-Step -height 84 -max 100.0 /tb_led_fade_down/u_led_fade_down/s_duty_cycle
add wave -noupdate /tb_led_fade_down/u_led_fade_down/s_end_of_cycle_p
add wave -noupdate /tb_led_fade_down/u_led_fade_down/c_100_VEC
add wave -noupdate /tb_led_fade_down/u_led_fade_down/c_000_VEC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {686021 ns} 0} {{Cursor 2} {11009843 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {4210579 ns}
