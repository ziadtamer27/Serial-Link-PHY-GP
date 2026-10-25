vlib work
vlog +define+SIM -f Src_files.list +cover=bcefst

vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover -sv_lib matlab_dpi/matlab_func_dpi +UVM_TESTNAME=ser_matlab_dpi_test


add wave -position insertpoint sim:/top/clk
add wave -position insertpoint sim:/top/ser_if_inst/rst_n
add wave -position insertpoint sim:/top/ser_if_inst/parallel_data
add wave -position insertpoint sim:/top/ser_if_inst/serial_out

run -all

coverage save -onexit ser_coverage.ucdb
coverage report -file ser_coverage.txt -details -all