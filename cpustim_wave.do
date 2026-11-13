# Run from the project folder: do cpustim_wave.do
onerror {abort}
onbreak {resume}
catch {quit -sim}

# Create the simulation library and compile the sources.
vlib work
vlog -sv "./D_FF.sv"
vlog -sv "./Enable.sv"
vlog -sv "./register.sv"
vlog -sv "./decoder_3by8.sv"
vlog -sv "./decoder_5by32.sv"
vlog -sv "./mux_8by1.sv"
vlog -sv "./mux_32by1.sv"
vlog -sv "./mux_64by32by1.sv"
vlog -sv "./regfile.sv"
vlog -sv "./full_adder.sv"
vlog -sv "./add_sub.sv"
vlog -sv "./alu.sv"
vlog -sv "./mux_2by1.sv"
vlog -sv "./control.sv"
vlog -sv "./instructmem.sv"
vlog -sv "./datamem.sv"
vlog -sv "./cpu.sv"
vlog -sv "./cpustim.sv"

# Load the testbench before adding waveform signals.
vsim -voptargs="+acc" -t 1ps -lib work cpustim
view wave
view structure
view signals
delete wave *

add wave -noupdate -divider {Clock and reset}
add wave -noupdate -label "clk" -radix binary /cpustim/clk
add wave -noupdate -label "reset" -radix binary /cpustim/reset

add wave -noupdate -divider {Program counter}
add wave -noupdate -label "PC" -radix unsigned /cpustim/dut/PC
add wave -noupdate -label "PC_next" -radix unsigned /cpustim/dut/PC_next
add wave -noupdate -label "instruction" -radix binary /cpustim/dut/instruction

add wave -noupdate -divider {Flags}
add wave -noupdate -label "negative" /cpustim/dut/flag_negative
add wave -noupdate -label "zero" /cpustim/dut/flag_zero
add wave -noupdate -label "overflow" /cpustim/dut/flag_overflow
add wave -noupdate -label "carry_out" /cpustim/dut/flag_carry_out

add wave -noupdate -divider {Control}
add wave -noupdate -label "Reg2Loc" /cpustim/dut/Reg2Loc
add wave -noupdate -label "ALUSrc" /cpustim/dut/ALUSrc
add wave -noupdate -label "ImmSel" /cpustim/dut/ImmSel
add wave -noupdate -label "MemToReg" /cpustim/dut/MemToReg
add wave -noupdate -label "RegWrite" /cpustim/dut/RegWrite
add wave -noupdate -label "MemWrite" /cpustim/dut/MemWrite
add wave -noupdate -label "MemRead" /cpustim/dut/MemRead
add wave -noupdate -label "UncondBr" /cpustim/dut/UncondBr
add wave -noupdate -label "BrTaken" /cpustim/dut/BrTaken
add wave -noupdate -label "RegBr" /cpustim/dut/RegBr
add wave -noupdate -label "Link" /cpustim/dut/Link
add wave -noupdate -label "FlagWrite" /cpustim/dut/FlagWrite
add wave -noupdate -label "ALUOp" -radix binary /cpustim/dut/ALUOp

add wave -noupdate -divider {Datapath}
add wave -noupdate -label "ReadData1" -radix decimal /cpustim/dut/ReadData1
add wave -noupdate -label "ReadData2" -radix decimal /cpustim/dut/ReadData2
add wave -noupdate -label "ALU_B" -radix decimal /cpustim/dut/ALU_B
add wave -noupdate -label "ALU_result" -radix decimal /cpustim/dut/ALU_result
add wave -noupdate -label "WriteRegister" -radix unsigned /cpustim/dut/WriteRegister
add wave -noupdate -label "WriteData" -radix decimal /cpustim/dut/WriteData

add wave -noupdate -divider {Registers}
# Decimal displays two's-complement data as signed values.
for {set i 0} {$i < 32} {incr i} {
    add wave -noupdate -label "X$i" -radix decimal "/cpustim/dut/regs/data_out\[$i\]"
}

add wave -noupdate -divider {Data memory}
add wave -noupdate -label "mem" -radix hexadecimal /cpustim/dut/dmem/mem

configure wave -namecolwidth 240
configure wave -valuecolwidth 220
configure wave -timelineunits ns
update

# Run the simulation and show the full waveform.
run -all
wave zoom full
