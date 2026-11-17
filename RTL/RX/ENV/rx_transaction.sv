`ifndef RX_TRANSACTION_SV
`define RX_TRANSACTION_SV

package rx_transaction_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class rx_transaction extends uvm_sequence_item;
        `uvm_object_utils(rx_transaction)
        // real D_plus;
        // real D_minus;
        rand bit tx_bit;
        rand logic rst_n;
        rand logic Rx_Polarity;

        logic recovered_clk;
        logic recovered_data;
        logic [9:0] parallel_data;
        logic symbol_valid;
        logic recovered_symbol_clk;



        function new(string name = "rx_transaction");
            super.new(name);
        endfunction
    endclass
endpackage

`endif