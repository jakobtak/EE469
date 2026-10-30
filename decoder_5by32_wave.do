# Run from the project folder: do decoder_5by32_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./decoder_5by32.sv"
vlog -sv "./decoder_3by8.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work decoder_5by32_testbench
view wave
view structure
view signals
delete wave *

quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate /decoder_5by32_testbench/RegWrite
add wave -noupdate /decoder_5by32_testbench/Register
add wave -noupdate /decoder_5by32_testbench/Write_Register
add wave -noupdate /decoder_5by32_testbench/i
add wave -noupdate /decoder_5by32_testbench/k

# Restore cursors.
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0

# Configure the wave display.
configure wave -namecolwidth 300
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

# Run the simulation and show the full waveform.
run -all
wave zoom full
