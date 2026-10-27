class decoder_disparity_error_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_disparity_error_sequence)

    function new(string name = "decoder_disparity_error_sequence");
        super.new(name);
    endfunction

    task body();
        int other_rd_index;

        load_codebook();

        // Establish known RD before intentionally sending wrong-RD codes.
        send_legal(1'b1, 8'hBC);

        foreach (golden[i]) begin
            other_rd_index = i ^ 256;

            if (!golden[i][10])
                continue;

            // Codes valid at both RDs cannot cause disparity errors.
            if (golden[i][9:0] == golden[other_rd_index][9:0])
                continue;

            // Send the code for the opposite of the actual incoming RD.
            move_to_rd(!i[8]);
            send_spec_word(1'b1, golden[i][9:0]);

            // The DUT recovers using the received code's permitted RD.
            rd_model = calculate_next_rd(golden[i][9:0], i[8]);
            send_legal(1'b0, 8'h00);
        end

        send_idle();
    endtask

endclass
