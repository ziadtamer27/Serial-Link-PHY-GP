package ser_seq_item;
import uvm_pkg::*;
`include "uvm_macros.svh"
class ser_seq_item extends uvm_sequence_item;
    `uvm_object_utils(ser_seq_item);

        rand logic rst_n;
        rand logic [9:0] parallel_data;
        logic serial_out;

    function new (string name="ser_seq_item");
        super.new(name);
    endfunction

    constraint rst_n_c {
        rst_n dist {0 := 5, 1 := 95};
    }

    function string convert2string();
        return $sformatf("rst_n=%0b, parallel_data=%0d, serial_out=%0b", rst_n, parallel_data, serial_out);
    endfunction
    /*
    function string convert2string_stimulus();
        return $sformatf("A=%0d , B=%0d, AluControlout=%0s, shift_amt=%0d", A, B, AluControlout_e.name, shift_amt);
    endfunction
    */
endclass
endpackage
