`ifndef ENCODER_EXHAUSTIVE_SEQ_SV
`define ENCODER_EXHAUSTIVE_SEQ_SV

class encoder_exhaustive_sequence extends encoder_base_sequence;
    `uvm_object_utils(encoder_exhaustive_sequence)
    function new(string name = "encoder_exhaustive_sequence"); 
        super.new(name); 
    endfunction
    
    task body();
        // All 512 data, 24 legal K, and 488 illegal K combinations. Rejected
        // requests must preserve both the preceding output code and RD.
        for (int rd = 0; rd < 2; rd++) begin
            for (int k = 0; k < 2; k++) begin
                for (int data = 0; data < 256; data++) begin
                    prepare_rd(rd != 0);
                    send_cycle(data[7:0], 1, k != 0);
                end
            end
        end
        send_cycle(8'h00, 0);
    endtask
endclass

`endif