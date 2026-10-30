onerror {resume}
quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate /decoder_3by8_testbench/RegWrite
add wave -noupdate /decoder_3by8_testbench/Register
add wave -noupdate /decoder_3by8_testbench/Write_Register
add wave -noupdate /decoder_3by8_testbench/i
add wave -noupdate /decoder_3by8_testbench/k

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
