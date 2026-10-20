package ser_main_sequence;
`include "uvm_macros.svh"
import uvm_pkg::*;
import ser_seq_item::*;
class ser_main_sequence extends uvm_sequence #(ser_seq_item);
    `uvm_object_utils(ser_main_sequence);

    ser_seq_item seq_item;

    function new(string name="ser_main_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item = ser_seq_item::type_id::create("seq_item");
        repeat(10000) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            finish_item(seq_item);
        end
    endtask
endclass

endpackage

