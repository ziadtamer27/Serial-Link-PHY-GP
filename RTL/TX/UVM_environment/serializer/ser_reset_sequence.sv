package ser_reset_sequence;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import ser_seq_item::*;

    class ser_reset_sequence extends uvm_sequence #(ser_seq_item);

        `uvm_object_utils(ser_reset_sequence)

        ser_seq_item seq_item;

        function new(string name = "ser_reset_sequence");
            super.new(name);
        endfunction

        virtual task body();

            seq_item = ser_seq_item::type_id::create("seq_item");
            `uvm_info(get_type_name(),
                      "Starting serializer reset sequence",
                      UVM_LOW)

            // Assert active-low reset for two cycles.
            repeat (2) begin
                start_item(seq_item);
                seq_item.rst_n         = 1'b0;
                seq_item.parallel_data = 10'b0;
                finish_item(seq_item);
            end
            `uvm_info(get_type_name(),
                      "Serializer reset sequence completed",
                      UVM_LOW)

        endtask

    endclass

endpackage
