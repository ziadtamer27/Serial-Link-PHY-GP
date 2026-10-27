class decoder_exhaustive_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_exhaustive_sequence)

    function new(string name = "decoder_exhaustive_sequence");
        super.new(name);
    endfunction

    task body();
        load_codebook();

        // Exercise every defined data/K character at both incoming RDs.
        foreach (golden[i]) begin
            if (golden[i][10]) begin
                move_to_rd(i[8]);
                send_legal(i[9], i[7:0]);
            end
        end

        // Exercise all 1024 input patterns, including invalid codes.
        // The scoreboard predicts disparity recovery for this raw sweep.
        for (int code = 0; code < 1024; code++)
            send_raw(1'b1, code[9:0]);

        send_idle();
    endtask

endclass
