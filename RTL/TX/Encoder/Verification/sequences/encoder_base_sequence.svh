`ifndef ENCODER_SEQUENCES_SV
`define ENCODER_SEQUENCES_SV

// One item is one sampled rising edge; the driver changes the pins on the
// preceding falling edge, including asynchronous reset assertion/release.
class encoder_base_sequence extends uvm_sequence #(encoder_seq_item);
    `uvm_object_utils(encoder_base_sequence)
    function new(string name = "encoder_base_sequence"); super.new(name); endfunction

    task send_cycle(input logic [7:0] data = 8'h00, input bit valid = 1'b1, input bit is_k = 1'b0, input bit reset_n = 1'b1);
        encoder_seq_item req;
        req = encoder_seq_item::type_id::create("req");
        start_item(req);
        req.rst_n = reset_n;
        req.in_valid = valid;
        req.in_data = data;
        req.in_is_k = is_k;
        finish_item(req);
    endtask

    task reset_dut(input int unsigned cycles = 2);
        repeat (cycles) send_cycle(8'h00, 1'b0, 1'b0, 1'b0);
    endtask

    // Reset establishes RD-, then K28.5 changes it to RD+. Do not force
    // a DUT register or trust its RD output to establish the expected state.
    task prepare_rd(input bit positive);
        reset_dut(1);
        if (positive) send_cycle(8'hbc, 1'b1, 1'b1);
    endtask

    function bit legal_k(input logic [7:0] data);
        return data inside {8'h1c, 8'h3c, 8'h5c, 8'h7c,
                            8'h9c, 8'hbc, 8'hdc, 8'hfc,
                            8'hf7, 8'hfb, 8'hfd, 8'hfe};
    endfunction
endclass





`endif



