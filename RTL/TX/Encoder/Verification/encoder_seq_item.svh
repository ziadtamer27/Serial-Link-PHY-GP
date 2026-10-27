`ifndef ENCODER_SEQ_ITEM_SV
`define ENCODER_SEQ_ITEM_SV

// Select negative traffic explicitly; ordinary random items are legal.
typedef enum {ENC_STIM_LEGAL, ENC_STIM_INVALID_K, ENC_STIM_MIXED}
    encoder_stimulus_mode_e;

class encoder_seq_item extends uvm_sequence_item;
    rand logic       rst_n;
    rand logic       in_valid;
    rand logic [7:0] in_data;
    rand logic       in_is_k;
    encoder_stimulus_mode_e stimulus_mode = ENC_STIM_LEGAL;
    logic       out_valid;
    logic [9:0] out_data;
    logic       rd_positive;
    logic       invalid_k;

    function new(string name = "encoder_seq_item"); 
        super.new(name); 
    endfunction

    constraint c_default_reset { soft rst_n == 1'b1; }

    constraint c_default_traffic {
        soft in_valid dist {1'b1 := 85, 1'b0 := 15};
        soft in_is_k dist {1'b0 := 75, 1'b1 := 25};
    }
    constraint c_control_symbols {
        solve in_is_k before in_data;

        if (stimulus_mode == ENC_STIM_LEGAL && in_is_k)
            in_data inside {8'h1c, 8'h3c, 8'h5c, 8'h7c,
                            8'h9c, 8'hbc, 8'hdc, 8'hfc,
                            8'hf7, 8'hfb, 8'hfd, 8'hfe};
                            
        if (stimulus_mode == ENC_STIM_INVALID_K) {
            in_is_k == 1'b1;
            !(in_data inside {8'h1c, 8'h3c, 8'h5c, 8'h7c,
                              8'h9c, 8'hbc, 8'hdc, 8'hfc,
                              8'hf7, 8'hfb, 8'hfd, 8'hfe});
        }
    }

    `uvm_object_utils_begin(encoder_seq_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(in_valid, UVM_ALL_ON)
        `uvm_field_int(in_data, UVM_ALL_ON)
        `uvm_field_int(in_is_k, UVM_ALL_ON)
        `uvm_field_enum(encoder_stimulus_mode_e, stimulus_mode, UVM_ALL_ON)
        `uvm_field_int(out_valid, UVM_ALL_ON)
        `uvm_field_int(out_data, UVM_ALL_ON)
        `uvm_field_int(rd_positive, UVM_ALL_ON)
        `uvm_field_int(invalid_k, UVM_ALL_ON)
    `uvm_object_utils_end


    function string convert2string();
        return $sformatf("rst_n=%b valid=%b data=%02h K=%b -> valid=%b code=%010b RD=%b invalid_K=%b",
                         rst_n, in_valid, in_data, in_is_k, out_valid,
                         out_data, rd_positive, invalid_k);
    endfunction

endclass
`endif


