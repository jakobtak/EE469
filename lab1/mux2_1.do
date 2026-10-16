# Run from the project folder: do lab1/mux2_1.do
# Run from lab1: do mux2_1.do

# Find sources from files or lab1
set lab1_src_dir ".."
if {[file exists "./regstim.sv"]} {
  set lab1_src_dir "."
}

# Create work library
vlib work

# Compile Verilog
vlog -sv "$lab1_src_dir/mux2_1.sv"

# Call vsim to invoke simulator
vsim -voptargs="+acc" -t 1ps -lib work mux2_1_testbench

# Set the window types
view wave
view structure
view signals

# Set up the wave signals
# Clear the previous test's signals before adding this test.
delete wave *
add wave -noupdate -divider {Clock and select}
add wave -noupdate -radix binary /mux2_1_testbench/clk
add wave -noupdate -radix unsigned /mux2_1_testbench/sel
add wave -noupdate -divider {Inputs}
add wave -noupdate -radix binary /mux2_1_testbench/in
add wave -noupdate -divider {Output}
add wave -noupdate -radix binary /mux2_1_testbench/out
configure wave -namecolwidth 220
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update

# Run the simulation
onbreak {resume}
run -all
wave zoom full

# End
