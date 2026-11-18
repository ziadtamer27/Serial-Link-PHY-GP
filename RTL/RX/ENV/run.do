vlib work
vlog top.sv +cover=bcetfs +define+SIM -covercells
vsim -voptargs="+acc +cover" work.top -classdebug -uvmcontrol=all -cover
add wave /top/rx_if/*
run -all
coverage save -onexit rx.ucdb
coverage report -file rx_cvr_report.txt -details -all
# -quit sim