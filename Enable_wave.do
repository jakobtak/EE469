# Run from the project folder: do Enable_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./mux_8by1.sv"
vlog -sv "./mux_32by1.sv"
vlog -sv "./mux_64by32by1.sv"
vlog -sv "./D_FF.sv"
vlog -sv "./decoder_5by32.sv"
vlog -sv "./Enable.sv"
vlog -sv "./regfile.sv"
vlog -sv "./decoder_3by8.sv"
vlog -sv "./regstim.sv"
vlog -sv "./register.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work Enable_testbench
view wave
view structure
view signals
delete wave *

quietly WaveActivateNextPane {} 0

# Add signals.
add wave -noupdate -radix binary /Enable_testbench/clk
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

# Run the simulation and show the full waveform.
run -all
wave zoom full
