# Run from the project folder: do lab1/decoder5_32.do
# Run from lab1: do decoder5_32.do

# Find sources from files or lab1
set lab1_src_dir ".."
if {[file exists "./regstim.sv"]} {
  set lab1_src_dir "."
}

# Create work library
vlib work

# Compile Verilog
vlog -sv "$lab1_src_dir/decoder5_32.sv"

# Call vsim to invoke simulator
vsim -voptargs="+acc" -t 1ps -lib work decoder5_32_testbench

# Set the window types
view wave
view structure
view signals

# Set up the wave signals
# Clear the previous test's signals before adding this test.
delete wave *
add wave -noupdate -divider {Clock and enable}
add wave -noupdate -radix binary /decoder5_32_testbench/clk
add wave -noupdate -radix binary /decoder5_32_testbench/enable
add wave -noupdate -divider {Address}
add wave -noupdate -radix unsigned /decoder5_32_testbench/addr
add wave -noupdate -divider {Output}
add wave -noupdate -radix hexadecimal /decoder5_32_testbench/out
configure wave -namecolwidth 220
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update

# Run the simulation
onbreak {resume}
run -all
wave zoom full

# End
