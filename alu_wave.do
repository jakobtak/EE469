# Waveform setup for alu_testbench; loaded by alu.do.
onerror {abort}
onbreak {resume}
view wave
delete wave *

add wave -noupdate -divider {Inputs}
# Decimal displays two's-complement data as signed values.
add wave -noupdate -radix decimal /alu_testbench/A
add wave -noupdate -radix decimal /alu_testbench/B
add wave -noupdate -radix binary /alu_testbench/cntrl

add wave -noupdate -divider {Result and flags}
add wave -noupdate -radix decimal /alu_testbench/result
add wave -noupdate /alu_testbench/negative
add wave -noupdate /alu_testbench/zero
add wave -noupdate /alu_testbench/overflow
add wave -noupdate /alu_testbench/carry_out

add wave -noupdate -divider {Shared adder}
add wave -noupdate -radix decimal /alu_testbench/dut/add_sub_op/b_add
add wave -noupdate -radix decimal /alu_testbench/dut/sum
add wave -noupdate -radix binary /alu_testbench/dut/add_sub_op/carry

add wave -noupdate -divider {Bitwise operation results}
add wave -noupdate -radix decimal /alu_testbench/dut/and_out
add wave -noupdate -radix decimal /alu_testbench/dut/or_out
add wave -noupdate -radix decimal /alu_testbench/dut/xor_out

configure wave -namecolwidth 240
configure wave -valuecolwidth 220
configure wave -timelineunits ns
update
