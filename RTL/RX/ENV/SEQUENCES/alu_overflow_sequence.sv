`ifndef ALU_OVERFLOW_SEQUENCE_SV
`define ALU_OVERFLOW_SEQUENCE_SV

package alu_overflow_sequence_pkg;

    import uvm_pkg::*;
    import alu_transaction_pkg::*;
    `include "uvm_macros.svh"

    class alu_overflow_sequence extends uvm_sequence #(alu_transaction);

        `uvm_object_utils(alu_overflow_sequence)

        function new(string name = "alu_overflow_sequence");
            super.new(name);
        endfunction

        task body();

            alu_transaction tr;
            // pos + pos -> overflow
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd2;
                    A[31] == 1'b0;
                    B[31] == 1'b0;
                    A >= 32'sd1073741824;
                    B >= 32'sd1073741824;
                });

                finish_item(tr);

            end

            // neg + neg -> overflow
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd2;
                    A[31] == 1'b1;
                    B[31] == 1'b1;
                    A <= -32'sd1073741824;
                    B <= -32'sd1073741824;
                });

                finish_item(tr);

            end

            // pos - neg -> overflow
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd6;
                    A[31] == 1'b0;
                    B[31] == 1'b1;
                    A >= 32'sd1073741824;
                    B <= -32'sd1073741824;
                });

                finish_item(tr);

            end

            // neg - pos -> overflow
            repeat(50) begin

                tr = alu_transaction::type_id::create("tr");

                start_item(tr);

                assert(tr.randomize() with {
                    AluControlout == 4'd6;
                    A[31] == 1'b1;
                    B[31] == 1'b0;
                    A <= -32'sd1073741824;
                    B >= 32'sd1073741824;
                });

                finish_item(tr);

            end

        endtask

    endclass

endpackage

`endif