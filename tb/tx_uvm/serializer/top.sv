import ser_test::*;
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
    .clk           (clk),
    .rst_n         (rst_n),
    .parallel_data (parallel_data),
    .serial_out    (serial_out),
    .shift_reg     (shift_reg),
    .count         (count)
    );

    initial begin
        uvm_config_db#(virtual ser_if)::set(null,"uvm_test_top","vif",ser_if_inst);
        run_test("ser_test");
    end
endmodule
    
