add wave -position insertpoint sim:/top/clk
add wave -position insertpoint sim:/top/ser_if_inst/rst_n
add wave -position insertpoint sim:/top/ser_if_inst/parallel_data
add wave -position insertpoint sim:/top/ser_if_inst/serial_out

run -all

coverage save -onexit ser_coverage.ucdb
coverage report -file ser_coverage.txt -details -all
