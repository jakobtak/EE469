# Run from the project folder: do mux_2by1_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./mux_2by1.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work mux_2by1_testbench
view wave
view structure
view signals
delete wave *

quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate /mux_2by1_testbench/out
add wave -noupdate /mux_2by1_testbench/in0
add wave -noupdate /mux_2by1_testbench/in1
add wave -noupdate /mux_2by1_testbench/sel
add wave -noupdate /mux_2by1_testbench/i

# Restore cursors.
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {81 ps} 0}
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

# Run the simulation and show the full waveform.
run -all
wave zoom full
