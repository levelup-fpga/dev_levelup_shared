onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/g_prescale_div
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/sys_clk
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/rst_n
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/duty_cycle
add wave -noupdate /tb_pwm_gen/u_pwm_gen/end_of_cycle_p
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/pwm_out
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/s_prescale_cpt
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/s_pwm_cpt
add wave -noupdate -radix unsigned /tb_pwm_gen/u_pwm_gen/c_100_PERCENT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64005 ns} 0} {{Cursor 2} {11009843 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {11009781 ns} {11010133 ns}
