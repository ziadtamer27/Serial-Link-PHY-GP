class decoder_skp_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_skp_sequence)

    int unsigned num_symbols = 16;

    function new(string name = "decoder_skp_sequence");
        super.new(name);
    endfunction

    task body();
        // Repeated SKP symbols exercise both incoming disparities.
        repeat (num_symbols)
            send_legal(1'b1, 8'h3C);

        // Check that the skip flag clears on data and idle cycles.
        send_legal(1'b0, 8'hFF);
        send_idle();
    endtask

endclass
