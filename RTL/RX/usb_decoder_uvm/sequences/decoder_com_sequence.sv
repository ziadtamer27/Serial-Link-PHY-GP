class decoder_com_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_com_sequence)

    int unsigned num_symbols = 16;

    function new(string name = "decoder_com_sequence");
        super.new(name);
    endfunction

    task body();
        // Repeated COM symbols exercise both incoming disparities.
        repeat (num_symbols)
            send_legal(1'b1, 8'hBC);

        // Check that the comma flag clears on data and idle cycles.
        send_legal(1'b0, 8'h00);
        send_idle();
    endtask

endclass
