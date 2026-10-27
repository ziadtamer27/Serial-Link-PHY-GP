
class decoder_reference_model extends uvm_object;

    `uvm_object_utils(decoder_reference_model)

    // USB 3.0 Appendix A encoding table
    // Index: {is_k, incoming_rd, data_byte}
    // Entry: {defined, encoded_10b}
    protected logic [10:0] spec_table [0:1023];

    // Lookup tables indexed by received 10-bit symbol
    protected bit       is_defined   [0:1023];
    protected bit       legal_rd_neg [0:1023];
    protected bit       legal_rd_pos [0:1023];
    protected bit [7:0] byte_lut     [0:1023];
    protected bit       k_lut        [0:1023];

    protected bit table_ready = 1'b0;

    // Reference model state
    protected bit         rd_state;
    protected bit         rd_known;
    protected logic [7:0] held_data;


    // Constructor
    function new(string name = "decoder_reference_model");
        super.new(name);
        reset_model();
    endfunction


    // Reset model state
    function void reset_model();

        rd_state  = 1'b0;
        rd_known  = 1'b0;
        held_data = 8'h00;

    endfunction


    // Load independent USB 3.0 encoding table
    function void init_codebook(
        string filename = "usb3_spec_vectors.mem"
    );

        int fd;
        int defined_entries;
        int distinct_codes;
        int code_idx;

        if (table_ready)
            return;

        fd = $fopen(filename, "r");

        if (!fd)
            `uvm_fatal("REF_FILE",
                $sformatf("Cannot open %s", filename))

        $fclose(fd);

        foreach (spec_table[i])
            spec_table[i] = 'x;

        $readmemh(filename, spec_table);

        foreach (is_defined[i]) begin
            is_defined[i]   = 1'b0;
            legal_rd_neg[i] = 1'b0;
            legal_rd_pos[i] = 1'b0;
            byte_lut[i]     = '0;
            k_lut[i]        = 1'b0;
        end

        defined_entries = 0;
        distinct_codes  = 0;

        foreach (spec_table[idx]) begin

            if ($isunknown(spec_table[idx]))
                `uvm_fatal("REF_FILE",
                    $sformatf("Invalid table entry %0d", idx))

            if (!spec_table[idx][10])
                continue;

            defined_entries++;

            code_idx = int'(spec_table[idx][9:0]);

            if (is_defined[code_idx]) begin

                // Same codeword must decode to same character
                if ((byte_lut[code_idx] != idx[7:0]) ||
                    (k_lut[code_idx] != idx[9]))
                    `uvm_fatal("REF_TABLE",
                        "Ambiguous 8b/10b symbol")

            end
            else begin

                distinct_codes++;

                is_defined[code_idx] = 1'b1;
                byte_lut[code_idx]   = idx[7:0];
                k_lut[code_idx]      = idx[9];

            end

            if (idx[8])
                legal_rd_pos[code_idx] = 1'b1;
            else
                legal_rd_neg[code_idx] = 1'b1;

        end

        if (defined_entries != 536 || distinct_codes != 464)
            `uvm_fatal("REF_TABLE",
                "Unexpected USB 8b/10b table size")

        table_ready = 1'b1;

        `uvm_info("REF_TABLE",
            "USB 8b/10b codebook loaded",
            UVM_LOW)

    endfunction


    // Reverse bit order for current decoder interface
    function automatic bit [9:0] reverse10(
        input bit [9:0] value
    );

        for (int i = 0; i < 10; i++)
            reverse10[i] = value[9-i];

    endfunction


    // Calculate running disparity after a symbol
    function automatic bit next_disparity(
        input bit [9:0] symbol,
        input bit current_rd
    );

        int n6 = 0;
        int n4 = 0;
        bit rd;

        rd = current_rd;

        for (int i = 4; i < 10; i++)
            n6 += int'(symbol[i]);

        for (int i = 0; i < 4; i++)
            n4 += int'(symbol[i]);

        if (n6 > 3)
            rd = 1'b1;
        else if (n6 < 3)
            rd = 1'b0;

        if (n4 > 2)
            rd = 1'b1;
        else if (n4 < 2)
            rd = 1'b0;

        return rd;

    endfunction


    // Predict DUT outputs for one monitored clock cycle
    function void predict(
        input  decoder_sequence_item observed,
        output decoder_sequence_item expected
    );

        bit [9:0] symbol;
        bit neg_ok;
        bit pos_ok;
        bit assumed_incoming_rd;
        int idx;

        if (!table_ready)
            `uvm_fatal("REF_TABLE",
                "Call init_codebook() before predict()")

        expected = decoder_sequence_item::type_id::create(
            "expected"
        );

        expected.rst_n       = observed.rst_n;
        expected.reset_event = observed.reset_event;
        expected.valid_in    = observed.valid_in;
        expected.code_in     = observed.code_in;

        // Default registered output behavior
        expected.valid_out       = 1'b0;
        expected.data_out        = held_data;
        expected.is_kcode        = 1'b0;
        expected.RxDataK         = 1'b0;
        expected.is_comma        = 1'b0;
        expected.is_skip         = 1'b0;
        expected.decode_error   = 1'b0;
        expected.disparity_error = 1'b0;


        // Reset behavior
        if (observed.reset_event ||
            observed.rst_n !== 1'b1) begin

            reset_model();
            expected.data_out = held_data;
            return;

        end


        // Output valid follows input valid
        expected.valid_out = observed.valid_in;

        // Idle cycle: data retained, flags cleared
        if (!observed.valid_in)
            return;


        // Convert DUT interface bit order to specification order
        symbol = reverse10(observed.code_in);
        idx = int'(symbol);

        neg_ok = legal_rd_neg[idx];
        pos_ok = legal_rd_pos[idx];


        // Invalid 10-bit codeword
        if (!is_defined[idx]) begin

            expected.data_out      = 8'h9C;
            expected.is_kcode      = 1'b1;
            expected.RxDataK       = 1'b1;
            expected.decode_error = 1'b1;

            // Decoder loses disparity lock after decode error
            rd_known = 1'b0;

        end
        else begin

            // Legal 8b/10b character
            expected.data_out = byte_lut[idx];
            expected.is_kcode = k_lut[idx];
            expected.RxDataK  = k_lut[idx];

            expected.is_comma =
                k_lut[idx] && (byte_lut[idx] == 8'hBC);

            expected.is_skip =
                k_lut[idx] && (byte_lut[idx] == 8'h3C);


            // Running disparity verification
            expected.disparity_error =
                rd_known &&
                !(rd_state ? pos_ok : neg_ok);


            // Recovery using the symbol's permitted incoming RD
            assumed_incoming_rd = rd_state;

            if (neg_ok && !pos_ok)
                assumed_incoming_rd = 1'b0;

            if (pos_ok && !neg_ok)
                assumed_incoming_rd = 1'b1;

            rd_state = next_disparity(
                symbol,
                assumed_incoming_rd
            );

            if (neg_ok != pos_ok)
                rd_known = 1'b1;

        end

        // Store value for following idle cycles
        held_data = expected.data_out;

    endfunction

endclass
