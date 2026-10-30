onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *

# Add signals.
add wave -noupdate -radix binary /regstim/clk
add wave -noupdate -radix hexadecimal /regstim/ReadData1
add wave -noupdate -radix hexadecimal /regstim/ReadData2
add wave -noupdate /regstim/ReadRegister1
add wave -noupdate /regstim/ReadRegister2
add wave -noupdate /regstim/RegWrite
add wave -noupdate -radix hexadecimal /regstim/WriteData
add wave -noupdate /regstim/WriteRegister
add wave -noupdate /regstim/i
add wave -noupdate -radix hexadecimal /regstim/dut/data_out

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
configure wave -timelineunits ns

update
wave zoom full
