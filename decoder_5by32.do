# Select the waveform file prefix.
if {$argc > 0} {
    set module $1
} else {
    set module decoder_5by32
}

# Create the simulation library.
vlib work

# Compile SystemVerilog sources.
vlog -sv "./decoder_5by32.sv"
vlog -sv "./decoder_3by8.sv"

# Load the testbench.
vsim -voptargs="+acc" -t 1ps -lib work decoder_5by32_testbench

# Load the waveform setup.
do ${module}_wave.do

# Show simulation windows.
view wave
view structure
view signals

# Run the simulation.
run -all

# vim: ft=tcl
