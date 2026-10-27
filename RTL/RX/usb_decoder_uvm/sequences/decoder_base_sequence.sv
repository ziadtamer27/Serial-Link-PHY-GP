
class decoder_base_sequence extends uvm_sequence #(decoder_sequence_item);

    `uvm_object_utils(decoder_base_sequence)

    // Independent USB 3.0 Appendix A codebook
    string codebook_file = "usb3_spec_vectors.mem";

    // Index: {is_k, incoming_rd, data_byte}
    // Entry: {defined, spec_order_10b_code}
    protected logic [10:0] golden [0:1023];

    protected bit codebook_loaded = 1'b0;

    // 0 = RD-, 1 = RD+
    protected bit rd_model = 1'b0;


    function new(string name = "decoder_base_sequence");
        super.new(name);
    endfunction


    // Load and validate the golden encoding table
    virtual task load_codebook();

        int fd;
        int defined_count;
        int unique_count;
        int code;
        bit seen [0:1023];

        if (codebook_loaded)
            return;

        fd = $fopen(codebook_file, "r");

        if (fd == 0)
            `uvm_fatal("SEQ_CODEBOOK",
                $sformatf("Cannot open codebook: %s",
                          codebook_file))

        $fclose(fd);

        foreach (golden[i])
            golden[i] = 'x;

        $readmemh(codebook_file, golden);

        foreach (seen[i])
            seen[i] = 1'b0;

        defined_count = 0;
        unique_count  = 0;

        foreach (golden[i]) begin

            if ($isunknown(golden[i]))
                `uvm_fatal("SEQ_CODEBOOK",
                    $sformatf("Invalid table entry: %0d", i))

            if (golden[i][10]) begin

                defined_count++;
                code = int'(golden[i][9:0]);

                if (!seen[code]) begin
                    seen[code] = 1'b1;
                    unique_count++;
                end

            end

        end

        if (defined_count != 536 || unique_count != 464)
            `uvm_fatal("SEQ_CODEBOOK",
                "Unexpected codebook size")

        // Known specification vectors
        if (golden[0]   !== 11'h674 ||
            golden[256] !== 11'h58B ||
            golden[700] !== 11'h4FA ||
            golden[956] !== 11'h705)
            `uvm_fatal("SEQ_CODEBOOK",
                "Golden-table sanity check failed")

        codebook_loaded = 1'b1;

        `uvm_info("SEQ_CODEBOOK",
            "USB 3.0 codebook loaded", UVM_LOW)

    endtask


    // Reverse 10-bit order for our DUT
    function automatic bit [9:0] reverse10(
        input bit [9:0] code
    );

        for (int i = 0; i < 10; i++)
            reverse10[i] = code[9-i];

    endfunction


    // Calculate the next running disparity
    function automatic bit calculate_next_rd(
        input bit [9:0] spec_code,
        input bit incoming_rd
    );

        int ones6;
        int ones4;
        bit rd;

        ones6 = 0;
        ones4 = 0;
        rd = incoming_rd;

        for (int i = 4; i < 10; i++)
            ones6 += int'(spec_code[i]);

        for (int i = 0; i < 4; i++)
            ones4 += int'(spec_code[i]);

        if (ones6 > 3)
            rd = 1'b1;
        else if (ones6 < 3)
            rd = 1'b0;

        if (ones4 > 2)
            rd = 1'b1;
        else if (ones4 < 2)
            rd = 1'b0;

        return rd;

    endfunction


    // Reset stimulus-model RD after an actual DUT reset
    function void reset_rd_model();
        rd_model = 1'b0;
    endfunction


    // Send the exact 10-bit value to the DUT interface
    virtual task send_raw(
        input bit active,
        input bit [9:0] wire_code
    );

        decoder_sequence_item req;

        req = decoder_sequence_item::type_id::create("req");

        start_item(req);

        req.valid_in = active;
        req.code_in  = wire_code;

        finish_item(req);

    endtask


    // Send a symbol using specification bit order
    virtual task send_spec_word(
        input bit active,
        input bit [9:0] spec_code
    );

        send_raw(active, reverse10(spec_code));

    endtask


    // Generate a legal 8b/10b character
    virtual task send_legal(
        input bit is_k,
        input bit [7:0] data_byte
    );

        logic [10:0] entry;

        load_codebook();

        entry = golden[{is_k, rd_model, data_byte}];

        if (entry[10] !== 1'b1)
            `uvm_fatal("SEQ_LEGAL",
                $sformatf(
                    "Undefined character K=%0b byte=%02h",
                    is_k, data_byte
                ))

        send_spec_word(1'b1, entry[9:0]);

        rd_model = calculate_next_rd(
            entry[9:0], rd_model
        );

    endtask


    // Generate an idle cycle
    virtual task send_idle(
        input bit [9:0] wire_code = 10'b0
    );

        send_raw(1'b0, wire_code);

    endtask


    // Establish the required incoming running disparity
    virtual task move_to_rd(input bit target_rd);

        if (rd_model != target_rd)
            send_legal(1'b1, 8'hBC);

        if (rd_model != target_rd)
            `uvm_fatal("SEQ_RD",
                "Could not establish requested RD")

    endtask

endclass
