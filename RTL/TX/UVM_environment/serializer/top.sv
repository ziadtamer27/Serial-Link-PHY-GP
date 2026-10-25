import ser_test::*;
import ser_matlab_dpi_test::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
module top();

    bit clk;
    initial begin
        clk = 0;
        forever begin
        #5 clk = ~clk;
        end
    end

    ser_if ser_if_inst(clk);
    serializer dut (
        .clk(clk),
        .rst_n(ser_if_inst.rst_n),
        .parallel_data(ser_if_inst.parallel_data),
        .serial_out(ser_if_inst.serial_out)
    );

    bind serializer ser_assertions ser_assertions_inst (
    .clk          (ser_if_inst.clk),
    .rst_n        (ser_if_inst.rst_n),
    .parallel_data(ser_if_inst.parallel_data),
    .serial_out   (ser_if_inst.serial_out)
    );

    initial begin
        uvm_config_db#(virtual ser_if)::set(null,"uvm_test_top","vif",ser_if_inst);
        run_test("ser_test");
    end
endmodule
    
