class decoder_idle_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_idle_sequence)

    int unsigned num_idle_cycles = 16;

    function new(string name = "decoder_idle_sequence");
        super.new(name);
    endfunction

    task body();
        // Idle inputs must retain data and clear all output flags.
        send_legal(1'b0, 8'h55);
        repeat (num_idle_cycles)
            send_idle(10'b0000000000);

        send_legal(1'b1, 8'hBC);
        repeat (num_idle_cycles)
            send_idle(10'b1111111111);

        send_legal(1'b1, 8'h3C);
        repeat (num_idle_cycles)
            send_idle(10'($urandom_range(0, 1023)));

        // Legal traffic must resume with the RD preserved across idle.
        send_legal(1'b0, 8'hAA);
        send_idle();
    endtask

endclass
