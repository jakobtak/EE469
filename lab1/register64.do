# Run from the project folder: do lab1/register64.do
# Run from lab1: do register64.do

# Find sources from files or lab1
set lab1_src_dir ".."
if {[file exists "./regstim.sv"]} {
  set lab1_src_dir "."
}

# Create work library
vlib work

# Compile Verilog
vlog -sv "$lab1_src_dir/D_FF.sv"
vlog -sv "$lab1_src_dir/mux2_1.sv"
vlog -sv "$lab1_src_dir/register64.sv"

# Call vsim to invoke simulator
vsim -voptargs="+acc" -t 1ps -lib work register64_testbench

# Set the window types
view wave
view structure
view signals

# Set up the wave signals
# Clear the previous test's signals before adding this test.
delete wave *
add wave -noupdate -divider {Clock and control}
add wave -noupdate -radix binary /register64_testbench/clk
add wave -noupdate -radix binary /register64_testbench/reset
add wave -noupdate -radix binary /register64_testbench/enable
add wave -noupdate -divider {Input}
add wave -noupdate -radix hexadecimal /register64_testbench/d
add wave -noupdate -divider {Stored output}
add wave -noupdate -radix hexadecimal /register64_testbench/q
add wave -noupdate -divider {DFF inputs}
add wave -noupdate -radix hexadecimal /register64_testbench/dut/mux_out
configure wave -namecolwidth 220
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update

# Run the simulation
onbreak {resume}
run -all
wave zoom full

# End
