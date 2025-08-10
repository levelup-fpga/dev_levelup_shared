onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/SAMPLE_WIDTH
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/SAMPLE_RATE
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/DEFAULT_WAVEFORM
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/SIGNED_OUTPUT
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/clk
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/rst_n
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/enable
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/waveform_sel
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/freq_hz
add wave -noupdate -format Analog-Step -height 84 -max 2047.0 -min -2047.0 -radix decimal -childformat {{/tb_waveform_gen/UUT/sample_out(11) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(10) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(9) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(8) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(7) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(6) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(5) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(4) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(3) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(2) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(1) -radix hexadecimal} {/tb_waveform_gen/UUT/sample_out(0) -radix hexadecimal}} -subitemconfig {/tb_waveform_gen/UUT/sample_out(11) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(10) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(9) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(8) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(7) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(6) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(5) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(4) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(3) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(2) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(1) {-radix hexadecimal} /tb_waveform_gen/UUT/sample_out(0) {-radix hexadecimal}} /tb_waveform_gen/UUT/sample_out
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/phase
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/TWO_PI
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/MAX_UNSIGNED_INT
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/MAX_SIGNED_INT
add wave -noupdate -radix hexadecimal /tb_waveform_gen/UUT/MIN_SIGNED_INT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18092839 ns} 0}
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
WaveRestoreZoom {0 ns} {52518514 ns}
