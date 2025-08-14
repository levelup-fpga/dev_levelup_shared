onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_waveform_gen/clk
add wave -noupdate -radix hexadecimal /tb_waveform_gen/rst_n
add wave -noupdate -radix hexadecimal /tb_waveform_gen/enable_sig
add wave -noupdate -radix hexadecimal /tb_waveform_gen/phase_inc
add wave -noupdate -radix hexadecimal /tb_waveform_gen/waveform_sel
add wave -noupdate -format Analog-Step -height 84 -max -1821.0 -min -1901.0 -radix decimal /tb_waveform_gen/sample_out
add wave -noupdate -radix hexadecimal /tb_waveform_gen/start_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/min_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/max_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/step_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/change_period
add wave -noupdate -radix hexadecimal /tb_waveform_gen/wave_ctrl
add wave -noupdate -radix hexadecimal /tb_waveform_gen/SAMPLE_WIDTH_C
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4345722 ns} 0}
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
WaveRestoreZoom {0 ns} {37216024 ns}
