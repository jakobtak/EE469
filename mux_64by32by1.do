# Select the waveform file prefix.
if {$argc > 0} {
    set module $1
} else {
    set module mux_64by32by1
}

# Create the simulation library.
vlib work

# Compile SystemVerilog sources.
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

# Load the testbench.
vsim -voptargs="+acc" -t 1ps -lib work mux_64by32by1_testbench

# Load the waveform setup.
do ${module}_wave.do

# Show simulation windows.
view wave
view structure
view signals

# Run the simulation.
run -all

# vim: ft=tcl
