vlib work
vlog top.sv +cover=bcetfs +define+SIM -covercells
vsim -voptargs="+acc +cover" work.top -classdebug -uvmcontrol=all -cover
add wave /top/alu_if/*
run -all
coverage save -onexit alu.ucdb
coverage report -file alu_cvr_report.txt -details -all
# -quit sim