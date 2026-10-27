class decoder_random_legal_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_random_legal_sequence)

    int unsigned num_symbols = 1000;

    function new(string name = "decoder_random_legal_sequence");
        super.new(name);
    endfunction

    task body();
        bit [7:0] kcodes [12] = '{
            8'h1C, 8'h3C, 8'h5C, 8'h7C,
            8'h9C, 8'hBC, 8'hDC, 8'hFC,
            8'hF7, 8'hFB, 8'hFD, 8'hFE
        };
        bit [7:0] data_byte;

        repeat (num_symbols) begin
            // Mix data characters with the twelve defined K characters.
            if ($urandom_range(0, 4) == 0)
                send_legal(1'b1, kcodes[$urandom_range(0, 11)]);
            else begin
                data_byte = 8'($urandom_range(0, 255));
                send_legal(1'b0, data_byte);
            end
        end

        send_idle();
    endtask

endclass
