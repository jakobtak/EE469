# Find sources from files or do_lab1
set lab1_src_dir ".."
if {[file exists "./regstim.sv"]} {
  set lab1_src_dir "."
}

# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "$lab1_src_dir/D_FF.sv"
vlog "$lab1_src_dir/mux2_1.sv"
vlog "$lab1_src_dir/register64.sv"
vlog "$lab1_src_dir/decoder5_32.sv"
vlog "$lab1_src_dir/mux32_1.sv"
vlog "$lab1_src_dir/regfile.sv"
vlog "$lab1_src_dir/regstim.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work regstim

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do "$lab1_src_dir/do_lab1/regfile_wave.do"

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
