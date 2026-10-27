class decoder_invalid_code_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_invalid_code_sequence)

    function new(string name = "decoder_invalid_code_sequence");
        super.new(name);
    endfunction

    task body();
        bit legal_code [0:1023];

        load_codebook();

        foreach (legal_code[code])
            legal_code[code] = 1'b0;

        foreach (golden[i]) begin
            if (golden[i][10])
                legal_code[golden[i][9:0]] = 1'b1;
        end

        // The table contains 464 legal codes, leaving 560 invalid codes.
        foreach (legal_code[code]) begin
            if (!legal_code[code])
                send_spec_word(1'b1, code[9:0]);
        end

        // Invalid codes lose RD lock; a COM restores it before data.
        send_legal(1'b1, 8'hBC);
        send_legal(1'b0, 8'h00);
        send_idle();
    endtask

endclass
