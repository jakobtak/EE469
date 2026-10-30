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
