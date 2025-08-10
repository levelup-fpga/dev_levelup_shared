onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/N
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/M
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/SIGNED_MODE
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/PIPELINE
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/clk
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/rst
add wave -noupdate -expand -group signed -format Analog-Step -height 84 -max 127.0 -min -127.0 -radix decimal /tb_scale_bits_flex/uut1/din
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/din_valid
add wave -noupdate -expand -group signed -format Analog-Step -height 84 -max 31.000000000000004 -min -32.0 -radix decimal -childformat {{/tb_scale_bits_flex/uut1/dout(5) -radix decimal} {/tb_scale_bits_flex/uut1/dout(4) -radix hexadecimal} {/tb_scale_bits_flex/uut1/dout(3) -radix hexadecimal} {/tb_scale_bits_flex/uut1/dout(2) -radix hexadecimal} {/tb_scale_bits_flex/uut1/dout(1) -radix hexadecimal} {/tb_scale_bits_flex/uut1/dout(0) -radix hexadecimal}} -subitemconfig {/tb_scale_bits_flex/uut1/dout(5) {-height 14 -radix decimal} /tb_scale_bits_flex/uut1/dout(4) {-height 14 -radix hexadecimal} /tb_scale_bits_flex/uut1/dout(3) {-height 14 -radix hexadecimal} /tb_scale_bits_flex/uut1/dout(2) {-height 14 -radix hexadecimal} /tb_scale_bits_flex/uut1/dout(1) {-height 14 -radix hexadecimal} /tb_scale_bits_flex/uut1/dout(0) {-height 14 -radix hexadecimal}} /tb_scale_bits_flex/uut1/dout
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/dout_valid
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/din_s
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/din_u
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/dout_s
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/dout_u
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/dout_comb
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/data_pipe
add wave -noupdate -expand -group signed -radix hexadecimal /tb_scale_bits_flex/uut1/valid_pipe
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/N
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/M
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/SIGNED_MODE
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/PIPELINE
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/clk
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/rst
add wave -noupdate -expand -group unsigned -format Analog-Step -height 84 -max 262143.0 -min -262143.0 -radix decimal /tb_scale_bits_flex/uut2/din
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/din_valid
add wave -noupdate -expand -group unsigned -format Analog-Step -height 84 -max 63.0 -min -64.0 -radix decimal /tb_scale_bits_flex/uut2/dout
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/dout_valid
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/din_s
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/din_u
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/dout_s
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/dout_u
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/dout_comb
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/data_pipe
add wave -noupdate -expand -group unsigned -radix hexadecimal /tb_scale_bits_flex/uut2/valid_pipe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1495 ns} 0}
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
WaveRestoreZoom {0 ns} {4174 ns}
