# Run from the project folder: do alustim.do
onerror {abort}

vlib work
vlog -sv "./full_adder.sv"
vlog -sv "./add_sub.sv"
vlog -sv "./mux_8by1.sv"
vlog -sv "./alu.sv"
vlog -sv "./alustim.sv"

vsim -voptargs="+acc" -t 1ps -lib work alustim
view wave
view structure
view signals
do "./alustim_wave.do"
run -all
wave zoom full
