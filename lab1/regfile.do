# Run from the project folder: do lab1/regfile.do
# Run from lab1: do regfile.do

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
vlog -sv "$lab1_src_dir/decoder5_32.sv"
vlog -sv "$lab1_src_dir/mux32_1.sv"
vlog -sv "$lab1_src_dir/regfile.sv"
vlog -sv "$lab1_src_dir/regstim.sv"

# Call vsim to invoke simulator
vsim -voptargs="+acc" -t 1ps -lib work regstim

# Set the window types
view wave
view structure
view signals

# Set up the wave signals
# Clear the previous test's signals before adding this test.
delete wave *
add wave -noupdate -divider {Clock and control}
add wave -noupdate -radix binary /regstim/clk
add wave -noupdate -radix binary /regstim/RegWrite
add wave -noupdate -divider {Addresses}
add wave -noupdate -radix unsigned /regstim/ReadRegister1
add wave -noupdate -radix unsigned /regstim/ReadRegister2
add wave -noupdate -radix unsigned /regstim/WriteRegister
add wave -noupdate -divider {Write data}
add wave -noupdate -radix hexadecimal /regstim/WriteData
add wave -noupdate -divider {Read data}
add wave -noupdate -radix hexadecimal /regstim/ReadData1
add wave -noupdate -radix hexadecimal /regstim/ReadData2
add wave -noupdate -divider {Write decoder}
add wave -noupdate -radix hexadecimal /regstim/dut/write_enable
add wave -noupdate -divider {Register reset}
add wave -noupdate -label reset {/regstim/dut/genblk1[0]/reg64/reset}
add wave -noupdate -divider {Registers X0-X31}
add wave -noupdate -radix hexadecimal -label X0 {/regstim/dut/registers[0]}
add wave -noupdate -radix hexadecimal -label X1 {/regstim/dut/registers[1]}
add wave -noupdate -radix hexadecimal -label X2 {/regstim/dut/registers[2]}
add wave -noupdate -radix hexadecimal -label X3 {/regstim/dut/registers[3]}
add wave -noupdate -radix hexadecimal -label X4 {/regstim/dut/registers[4]}
add wave -noupdate -radix hexadecimal -label X5 {/regstim/dut/registers[5]}
add wave -noupdate -radix hexadecimal -label X6 {/regstim/dut/registers[6]}
add wave -noupdate -radix hexadecimal -label X7 {/regstim/dut/registers[7]}
add wave -noupdate -radix hexadecimal -label X8 {/regstim/dut/registers[8]}
add wave -noupdate -radix hexadecimal -label X9 {/regstim/dut/registers[9]}
add wave -noupdate -radix hexadecimal -label X10 {/regstim/dut/registers[10]}
add wave -noupdate -radix hexadecimal -label X11 {/regstim/dut/registers[11]}
add wave -noupdate -radix hexadecimal -label X12 {/regstim/dut/registers[12]}
add wave -noupdate -radix hexadecimal -label X13 {/regstim/dut/registers[13]}
add wave -noupdate -radix hexadecimal -label X14 {/regstim/dut/registers[14]}
add wave -noupdate -radix hexadecimal -label X15 {/regstim/dut/registers[15]}
add wave -noupdate -radix hexadecimal -label X16 {/regstim/dut/registers[16]}
add wave -noupdate -radix hexadecimal -label X17 {/regstim/dut/registers[17]}
add wave -noupdate -radix hexadecimal -label X18 {/regstim/dut/registers[18]}
add wave -noupdate -radix hexadecimal -label X19 {/regstim/dut/registers[19]}
add wave -noupdate -radix hexadecimal -label X20 {/regstim/dut/registers[20]}
add wave -noupdate -radix hexadecimal -label X21 {/regstim/dut/registers[21]}
add wave -noupdate -radix hexadecimal -label X22 {/regstim/dut/registers[22]}
add wave -noupdate -radix hexadecimal -label X23 {/regstim/dut/registers[23]}
add wave -noupdate -radix hexadecimal -label X24 {/regstim/dut/registers[24]}
add wave -noupdate -radix hexadecimal -label X25 {/regstim/dut/registers[25]}
add wave -noupdate -radix hexadecimal -label X26 {/regstim/dut/registers[26]}
add wave -noupdate -radix hexadecimal -label X27 {/regstim/dut/registers[27]}
add wave -noupdate -radix hexadecimal -label X28 {/regstim/dut/registers[28]}
add wave -noupdate -radix hexadecimal -label X29 {/regstim/dut/registers[29]}
add wave -noupdate -radix hexadecimal -label X30 {/regstim/dut/registers[30]}
add wave -noupdate -radix hexadecimal -label X31 {/regstim/dut/registers[31]}
configure wave -namecolwidth 220
configure wave -valuecolwidth 180
configure wave -timelineunits ns
update

# Run the simulation
onbreak {resume}
run -all
wave zoom full

# End
