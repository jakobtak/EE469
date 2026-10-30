onerror {resume}
quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate /Enable_testbench/clk
add wave -noupdate /Enable_testbench/data_out
add wave -noupdate /Enable_testbench/i
add wave -noupdate /Enable_testbench/k
add wave -noupdate /Enable_testbench/period
add wave -noupdate /Enable_testbench/Register
add wave -noupdate /Enable_testbench/reset
add wave -noupdate /Enable_testbench/WriteData

# Restore cursors.
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1

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
WaveRestoreZoom {0 ps} {845 ps}
