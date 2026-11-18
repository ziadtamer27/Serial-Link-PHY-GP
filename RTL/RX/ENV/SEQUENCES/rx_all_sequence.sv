`ifndef RX_ALL_SEQUENCE_SV
`define RX_ALL_SEQUENCE_SV

package rx_all_sequence_pkg;
    timeunit 1ps;
    timeprecision 1fs;

    import uvm_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_all_sequence extends uvm_sequence #(rx_transaction);

        `uvm_object_utils(rx_all_sequence)

        bit [9:0] tseq [0:31];

        function new(string name = "rx_all_sequence");
            super.new(name);
        endfunction

        task automatic send_bit(input bit value, input bit reset_n = 1'b1);
            rx_transaction tr;
            tr = rx_transaction::type_id::create("tr");
            start_item(tr);
            tr.tx_bit      = value;
            tr.rst_n       = reset_n;
            tr.Rx_Polarity = 1'b0;
            finish_item(tr);
        endtask

        task automatic send_symbol(input bit [9:0] symbol);
            for (int i = 9; i >= 0; i--) begin
                send_bit(symbol[i]);
            end
        endtask

        virtual task body();

            // Reset
            `uvm_info("RX_SEQ", "Resetting RX", UVM_LOW)
            repeat (20)
                send_bit(1'b0, 1'b0);

            //clock recovery training
            `uvm_info("RX_SEQ","Sending 010101... for clock recovery",UVM_LOW)
            repeat (20) begin
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b1);
                send_bit(1'b1);
                send_bit(1'b1);
                send_bit(1'b1);
                send_bit(1'b1);
            end
            repeat (20) begin
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b0);
                send_bit(1'b1);
                send_bit(1'b1);
                send_bit(1'b1);
            end
            repeat (20) begin
                send_bit(1'b0);
                send_bit(1'b1);
            end


            //initialize the TSEQ symbols
            tseq[0]  = 10'b0011111010; // K28.5
            tseq[1]  = 10'b0101001110; // D31.7
            tseq[2]  = 10'b0001011011; // D23.0
            tseq[3]  = 10'b0110000110; // D0.6
            tseq[4]  = 10'b0010111011; // D20.0
            tseq[5]  = 10'b0100111010; // D18.5
            tseq[6]  = 10'b0001110001; // D7.7
            tseq[7]  = 10'b1011010100; // D2.0
            tseq[8]  = 10'b1011010010; // D2.4
            tseq[9]  = 10'b0100111100; // D18.3
            tseq[10] = 10'b0111001100; // D14.3
            tseq[11] = 10'b1110011001; // D8.1
            tseq[12] = 10'b0110011010; // D6.5
            tseq[13] = 10'b1000011010; // D30.5
            tseq[14] = 10'b1011001100; // D13.3
            tseq[15] = 10'b1010111010; // D31.5
            //  D10.2
            for (int i = 16; i < 32; i++)
                tseq[i] = 10'b0101010101;

            // Send 32-symbol TSEQ
            `uvm_info("RX_SEQ","Sending 32 TSEQ symbols",UVM_LOW)
            for (int i = 0; i < 32; i++) begin
                send_symbol(tseq[i]);
                `uvm_info("RX_SEQ",$sformatf("TSEQ[%0d] = %010b",i, tseq[i]),UVM_MEDIUM)
            end
            `uvm_info("RX_SEQ", "TSEQ transmission completed",UVM_LOW)

        endtask
    endclass
endpackage

`endif
