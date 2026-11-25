# Create work library
vlib work
vmap work work

# Compile RTL and testbench
vlog -sv optional.sv
vlog -sv optional_tb.sv

# Start simulation
vsim -voptargs=+acc work.optional_tb

# Clocks and Reset
add wave -divider "Clocks and Reset"
add wave sim:/optional_tb/pclk
add wave sim:/optional_tb/symbol_clk
add wave sim:/optional_tb/rst_n

# Inputs
add wave -divider "Inputs"
add wave sim:/optional_tb/enable
add wave -radix hex sim:/optional_tb/tx_data
add wave -radix binary sim:/optional_tb/tx_data_k

# Holding Registers
add wave -divider "Holding Registers"
add wave -radix hex sim:/optional_tb/dut/parallel_reg
add wave -radix binary sim:/optional_tb/dut/parallel_k
add wave sim:/optional_tb/dut/word_ready

# Shift Registers
# add wave -divider "Shift Registers"
# add wave -radix hex sim:/optional_tb/dut/gen_wide/shift_reg
# add wave -radix binary sim:/optional_tb/dut/gen_wide/shift_k

# Control Signals
# add wave -divider "Control Signals"
# add wave -radix unsigned sim:/optional_tb/dut/gen_wide/count
# add wave sim:/optional_tb/dut/gen_wide/active

# Outputs
add wave -divider "Outputs"
add wave -radix hex sim:/optional_tb/data_out
add wave sim:/optional_tb/k_out
add wave sim:/optional_tb/valid_out

# Waveform configuration
configure wave -timelineunits ns

# Run simulation
run -all

wave zoom full