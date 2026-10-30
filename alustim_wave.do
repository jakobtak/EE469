# Run from the project folder: do alustim_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./full_adder.sv"
vlog -sv "./add_sub.sv"
vlog -sv "./mux_8by1.sv"
vlog -sv "./alu.sv"
vlog -sv "./alustim.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work alustim
view wave
view structure
view signals
delete wave *

add wave -noupdate -divider {Inputs}
add wave -noupdate -radix hexadecimal /alustim/A
add wave -noupdate -radix hexadecimal /alustim/B
add wave -noupdate -radix binary /alustim/cntrl

add wave -noupdate -divider {Result and flags}
add wave -noupdate -radix hexadecimal /alustim/result
add wave -noupdate /alustim/negative
add wave -noupdate /alustim/zero
add wave -noupdate /alustim/overflow
add wave -noupdate /alustim/carry_out

add wave -noupdate -divider {Shared adder}
add wave -noupdate -radix hexadecimal /alustim/dut/add_sub_op/b_add
add wave -noupdate -radix hexadecimal /alustim/dut/sum
add wave -noupdate -radix hexadecimal /alustim/dut/add_sub_op/carry

configure wave -namecolwidth 240
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update

# Run the simulation and show the full waveform.
run -all
wave zoom full
