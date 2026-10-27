`ifndef ENCODER_REFERENCE_MODEL_SVH
`define ENCODER_REFERENCE_MODEL_SVH
// Generated from the vendored Python model, independent of DUT equations.
class encoder_reference_model extends uvm_object;
    `uvm_object_utils(encoder_reference_model)
    logic [10:0] lut [0:1023];
    bit rd;
    logic [9:0] held_data;
    string lut_path;

    function new(string name = "encoder_reference_model");
        int fd;
        super.new(name);

        lut_path = "reference/encoder_lut.mem";

        void'($value$plusargs("ENCODER_LUT=%s", lut_path));
        fd = $fopen(lut_path, "r");

        if (fd == 0)
            `uvm_fatal("ENC_LUT", $sformatf("Cannot open %s; use +ENCODER_LUT=<path>", lut_path))
        $fclose(fd);
        foreach (lut[i]) 
            lut[i] = 'x;
        $readmemh(lut_path, lut);

        foreach (lut[i]) begin
            if ((!i[9] || is_legal_k(i[7:0])) && $isunknown(lut[i]))
                `uvm_fatal("ENC_LUT", $sformatf("Missing/unknown legal LUT entry %0d", i))
        end
        if (lut[{1'b1,1'b0,8'hbc}] !== {1'b1,10'b0011111010} || 
            lut[{1'b1,1'b1,8'hbc}] !== {1'b0,10'b1100000101})
            `uvm_fatal("ENC_LUT", "K28.5 sanity check failed: wrong LUT format/bit order")
        reset();
    endfunction

    static function bit is_legal_k(input logic [7:0] data);
        return data inside {8'h1c,8'h3c,8'h5c,8'h7c,8'h9c,8'hbc,
                            8'hdc,8'hfc,8'hf7,8'hfb,8'hfd,8'hfe};
    endfunction

    function void reset();
        rd = 0;
        held_data = '0;
    endfunction

    function void predict(input encoder_seq_item tr,
                          output bit exp_valid,
                          output logic [9:0] exp_data,
                          output bit exp_invalid_k,
                          output bit exp_rd);
        logic [10:0] entry;
        exp_valid = 0;
        exp_invalid_k = 0;
        if (tr.rst_n === 1'b0) reset();
        else if (tr.in_valid === 1'b1) begin
            exp_invalid_k = tr.in_is_k && !is_legal_k(tr.in_data);
            exp_valid = !exp_invalid_k;
            if (exp_valid) begin
                entry = lut[{tr.in_is_k, rd, tr.in_data}];
                rd = entry[10];
                held_data = entry[9:0];
            end
        end

        exp_data = held_data;
        exp_rd = rd;

    endfunction

endclass
`endif