onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/SAMPLE_WIDTH
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/DEFAULT_WAVEFORM
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/SIGNED_OUTPUT
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/clk
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/rst_n
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/waveform_sel
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/start_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/min_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/max_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/step_samples
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/change_period
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/sample_out
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/enable_sig
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/cnt_clk
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/cnt_enable
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/spp_current
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/spp_counter
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/phase_inc
add wave -noupdate -radix hexadecimal /tb_waveform_gen/DUT/TWO_PI
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6518583 ns} 0}
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
