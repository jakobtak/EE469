onerror {resume}
quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate /regstim/ClockDelay
add wave -noupdate -radix hexadecimal /regstim/ReadData1
add wave -noupdate -radix hexadecimal /regstim/ReadData2
add wave -noupdate /regstim/ReadRegister1
add wave -noupdate /regstim/ReadRegister2
add wave -noupdate /regstim/RegWrite
add wave -noupdate -radix hexadecimal /regstim/WriteData
add wave -noupdate /regstim/WriteRegister
add wave -noupdate /regstim/i
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[0]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[1]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[2]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[3]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[4]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[5]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[6]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[7]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[8]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[9]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[10]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[11]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[12]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[13]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[14]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[15]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[16]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[17]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[18]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[19]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[20]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[21]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[22]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[23]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[24]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[25]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[26]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[27]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[28]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[29]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[30]}
add wave -noupdate -radix hexadecimal {/regstim/dut/data_out[31]}

# Restore cursors.
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0

# Configure the wave display.
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {1 ns}
