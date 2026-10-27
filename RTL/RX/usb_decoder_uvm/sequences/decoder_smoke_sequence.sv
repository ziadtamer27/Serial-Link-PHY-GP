class decoder_smoke_sequence extends decoder_base_sequence;

    `uvm_object_utils(decoder_smoke_sequence)

    function new(string name = "decoder_smoke_sequence");
        super.new(name);
    endfunction

    task body();
        send_legal(1'b0, 8'h00);
        send_legal(1'b0, 8'h55);
        send_legal(1'b0, 8'hAA);
        send_legal(1'b0, 8'hFF);
        send_legal(1'b1, 8'hBC); // COM: K28.5
        send_legal(1'b1, 8'h3C); // SKP: K28.1
        send_legal(1'b0, 8'h12);
        send_idle();
    endtask

endclass
