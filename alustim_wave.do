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
# Decimal displays two's-complement data as signed values.
add wave  -noupdate -label "A_2" -radix binary /alustim/A 
add wave  -noupdate -label "A_10" -radix decimal /alustim/A 
add wave  -noupdate -label "B_2" -radix binary /alustim/B 
add wave  -noupdate -label "B_10" -radix decimal /alustim/B 
add wave  -noupdate -label "cntrl" -radix binary /alustim/cntrl 

add wave  -noupdate -divider {Result and flags}
add wave  -noupdate -label "result" -radix decimal /alustim/result
add wave  -noupdate -label "negative" /alustim/negative 
add wave  -noupdate -label "zero" /alustim/zero 
add wave  -noupdate -label "overflow" /alustim/overflow 
add wave  -noupdate -label "carry_out" /alustim/carry_out 

add wave  -noupdate -divider {Shared adder}
add wave  -noupdate -label "b_add" -radix decimal /alustim/dut/add_sub_op/b_add 
add wave  -noupdate -label "sum" -radix decimal /alustim/dut/sum 
add wave  -noupdate -label "carry" -radix binary /alustim/dut/add_sub_op/carry 

add wave  -noupdate -divider {Bitwise operation results}
add wave  -noupdate -label "and_out" -radix binary /alustim/dut/and_out 
add wave  -noupdate -label "or_out" -radix binary /alustim/dut/or_out 
add wave  -noupdate -label "xor_out" -radix binary /alustim/dut/xor_out 

configure wave -namecolwidth 240
configure wave -valuecolwidth 220
configure wave -timelineunits ns
update

# Run the simulation and show the full waveform.
run -all
wave zoom full
