
package ser_directed_sequence;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import ser_seq_item::*;

    class ser_directed_sequence extends uvm_sequence #(ser_seq_item);

        `uvm_object_utils(ser_directed_sequence)

        ser_seq_item seq_item;

        function new(string name = "ser_directed_sequence");
            super.new(name);
        endfunction

        task automatic send_word(input bit [9:0] data_value);

            seq_item = ser_seq_item::type_id::create("seq_item");
            repeat(10) begin
                start_item(seq_item);
                seq_item.rst_n         = 1'b1;
                seq_item.parallel_data = data_value;
                finish_item(seq_item);
            end

        endtask

        virtual task body();

            `uvm_info(get_type_name(),"Starting directed tests", UVM_LOW)
            send_word(10'b0101010101);
            //`uvm_info(get_type_name(),"Starting second test", UVM_LOW)
            send_word(10'b1100101011);
            //`uvm_info(get_type_name(),"Starting third test", UVM_LOW)
            send_word(10'b0000000000);
            
            send_word(10'b0000000001);
            send_word(10'b1000000000);

            send_word(10'b1111111111);
            send_word(10'b0000000000);
            //`uvm_info(get_type_name(),"Directed tests completed", UVM_LOW)

        endtask

    endclass

endpackage
