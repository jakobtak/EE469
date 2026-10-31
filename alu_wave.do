# Run from the project folder: do alu_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./full_adder.sv"
vlog -sv "./add_sub.sv"
vlog -sv "./mux_8by1.sv"
vlog -sv "./alu.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work alu_testbench
view wave
view structure
view signals
delete wave *

add wave -noupdate -divider {Inputs}
# Decimal displays two's-complement data as signed values.
add wave  -noupdate -label "A_2" -radix binary /alu_testbench/A
add wave  -noupdate -label "A_10" -radix decimal /alu_testbench/A
add wave  -noupdate -label "B_2" -radix binary /alu_testbench/B
add wave  -noupdate -label "B_10" -radix decimal /alu_testbench/B
add wave  -noupdate -label "cntrl" -radix binary /alu_testbench/cntrl

add wave  -noupdate -divider {Result and flags}
add wave  -noupdate -label "result" -radix decimal /alu_testbench/result
add wave  -noupdate -label "negative" /alu_testbench/negative
add wave  -noupdate -label "zero" /alu_testbench/zero
add wave  -noupdate -label "overflow" /alu_testbench/overflow
add wave  -noupdate -label "carry_out" /alu_testbench/carry_out

add wave  -noupdate -divider {Shared adder}
add wave  -noupdate -label "b_add" -radix decimal /alu_testbench/dut/add_sub_op/b_add
add wave  -noupdate -label "sum" -radix decimal /alu_testbench/dut/sum
add wave  -noupdate -label "carry" -radix binary /alu_testbench/dut/add_sub_op/carry

add wave  -noupdate -divider {Bitwise operation results}
add wave  -noupdate -label "and_out" -radix binary /alu_testbench/dut/and_out
add wave  -noupdate -label "or_out" -radix binary /alu_testbench/dut/or_out
add wave  -noupdate -label "xor_out" -radix binary /alu_testbench/dut/xor_out

configure wave -namecolwidth 240
configure wave -valuecolwidth 220
configure wave -timelineunits ns
update

# Run the simulation and show the full waveform.
run -all
wave zoom full
