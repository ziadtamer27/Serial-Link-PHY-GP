
# ==========================================
# COMPILE
# ==========================================

if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog +define+SIM -f Src_files.list +cover=bcefst

# ==========================================
# SIMULATE
# ==========================================

vsim -voptargs=+acc work.Tx_Wrapper_tb -classdebug -cover

# ==========================================
# CLOCKS AND RESET
# ==========================================

add wave -divider "CLOCKS AND RESET"

add wave -position insertpoint sim:/Tx_Wrapper_tb/pclk
add wave -position insertpoint sim:/Tx_Wrapper_tb/bit_rate_clk
add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/bit_rate_clk_div10
add wave -position insertpoint sim:/Tx_Wrapper_tb/rst_n

# ==========================================
# EXTERNAL TX INPUTS
# ==========================================

add wave -divider "EXTERNAL TX INPUTS"

add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_valid
add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_data
add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_data_k

# ==========================================
# OPTIONAL WIDTH CONVERSION
# ==========================================

add wave -divider "OPTIONAL WIDTH CONVERSION"

# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/encoder_data
# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/encoder_k


add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/optional_inst/*

# ==========================================
# 8b/10b ENCODER
# ==========================================

add wave -divider "8b/10b ENCODER"

# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/serializer_data
# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/serializer_valid

# add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_invalid_k
# add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_rd_positive

# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_encoder/rd_q

add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_encoder/*

# ==========================================
# SERIALIZER
# ==========================================

add wave -divider "SERIALIZER"

# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/serial_data

# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_serializer/shift_reg
# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_serializer/count
# add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_serializer/active

add wave -position insertpoint sim:/Tx_Wrapper_tb/DUT/u_serializer/*

# ==========================================
# DIFFERENTIAL OUTPUTS
# ==========================================

add wave -divider "DIFFERENTIAL OUTPUTS"

add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_serial_out
add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_p
add wave -position insertpoint sim:/Tx_Wrapper_tb/tx_n

# ==========================================
# TESTBENCH MONITORING
# ==========================================

add wave -divider "TESTBENCH MONITORING"

add wave sim:/Tx_Wrapper_tb/encoder_valid_count
add wave sim:/Tx_Wrapper_tb/invalid_k_count
add wave sim:/Tx_Wrapper_tb/serial_transition_count
add wave sim:/Tx_Wrapper_tb/differential_errors
add wave sim:/Tx_Wrapper_tb/divider_errors
add wave sim:/Tx_Wrapper_tb/data_errors

# ==========================================
# RUN
# ==========================================

run -all

# ==========================================
# COVERAGE
# ==========================================

coverage save wrapper_coverage.ucdb
coverage report -file wrapper_coverage.txt -details -all
