add wave -noupdate -divider {Control}
add wave -noupdate /regstim/clk
add wave -noupdate /regstim/RegWrite
add wave -noupdate -label reset {/regstim/dut/gen_registers[0]/reg64/reset}

add wave -noupdate -divider {Addresses}
add wave -noupdate -radix unsigned /regstim/ReadRegister1
add wave -noupdate -radix unsigned /regstim/ReadRegister2
add wave -noupdate -radix unsigned /regstim/WriteRegister

add wave -noupdate -divider {Data}
add wave -noupdate -radix hexadecimal /regstim/WriteData
add wave -noupdate -radix hexadecimal /regstim/ReadData1
add wave -noupdate -radix hexadecimal /regstim/ReadData2
add wave -noupdate -radix hexadecimal /regstim/dut/write_enable

add wave -noupdate -divider {Registers}
for {set i 0} {$i < 32} {incr i} {
  add wave -noupdate -radix hexadecimal -label X$i [format {/regstim/dut/registers[%d]} $i]
}

configure wave -namecolwidth 180
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {500000 ns}
