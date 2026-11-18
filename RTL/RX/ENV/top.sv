timeunit 1ps;
timeprecision 1fs;

`ifndef RX_TOP_SV
`define RX_TOP_SV

`ifdef RX_EXTERNAL_SOURCES
`else
    `include "../RTL/rx_wrapper.sv"
    `include "rx_sva.sv"
    `include "rx_if.sv"
    `include "rx_config_obj.sv"
    `include "rx_transaction.sv"
    `include "rx_overflow_sequence.sv" ///////////////////////////
    `include "rx_sequencer.sv"
    `include "rx_driver.sv"
    `include "rx_monitor.sv"
    `include "rx_scoreboard.sv"
    `include "rx_coveragecollector.sv"
    `include "rx_agent.sv"
    `include "rx_env.sv"
    `include "rx_test.sv"
`endif

import uvm_pkg::*;
import rx_test_pkg::*;
`include "uvm_macros.svh"
module top;

    bit clk;
    initial begin
        clk=0;
        forever #100 clk=~clk;
    end

    rx_if rx_if(clk);

    rx_wrapper dut (
        .D_plus(rx_if.D_plus),
        .D_minus(rx_if.D_minus),
        .rst_n(rx_if.rst_n),
        .Rx_Polarity(rx_if.Rx_Polarity),
        .recovered_clk(rx_if.recovered_clk),
        .recovered_data(rx_if.recovered_data),
        .parallel_data(rx_if.parallel_data),
        .symbol_valid(rx_if.symbol_valid),
        .recovered_symbol_clk(rx_if.recovered_symbol_clk)
    );

    // bind dut ALU_SVA sva_inst(
    //     .A(alu_if.A),
    //     .B(alu_if.B),
    //     .shift_amt(alu_if.shift_amt),
    //     .overflow(alu_if.overflow),
    //     .AluControlout(alu_if.AluControlout),
    //     .Result(alu_if.Result),
    //     .clk(clk)
    // );
    
    initial begin
        uvm_config_db#(virtual rx_if)::set(null,"*","rx_if",rx_if);
        run_test("rx_test");
        $dumpfile("dump.vcd");
        $dumpvars(0,top);
    end
endmodule

`endif