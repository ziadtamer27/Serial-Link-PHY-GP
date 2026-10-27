
class decoder_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(decoder_scoreboard)

    // Receives transactions from the single monitor
    uvm_analysis_imp #(decoder_sequence_item, decoder_scoreboard)
        analysis_export;

    // Reference model
    decoder_reference_model ref_model;

    // Golden table location
    string golden_file = "usb3_spec_vectors.mem";

    // Statistics
    int unsigned total_cycles;
    int unsigned passed_cycles;
    int unsigned failed_cycles;
    int unsigned reset_cycles;
    int unsigned active_cycles;
    int unsigned idle_cycles;


    // Constructor
    function new(string name = "decoder_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        analysis_export = new("analysis_export", this);

        ref_model = decoder_reference_model::type_id::create(
            "ref_model"
        );

        // Optional path override
        void'(uvm_config_db#(string)::get(
            this, "", "golden_file", golden_file
        ));

        ref_model.init_codebook(golden_file);
    endfunction


    // Receive and check one monitored transaction
    virtual function void write(decoder_sequence_item actual);

        decoder_sequence_item expected;
        string mismatches;

        if (actual == null)
            `uvm_fatal("DEC_SCB", "Received null transaction")

        // Get expected outputs from reference model
        ref_model.predict(actual, expected);

        total_cycles++;

        // Track transaction categories
        if (actual.reset_event || actual.rst_n !== 1'b1)
            reset_cycles++;
        else if (actual.valid_in === 1'b1)
            active_cycles++;
        else
            idle_cycles++;

        mismatches = "";

        // Compare every registered DUT output
        if (actual.valid_out !== expected.valid_out)
            mismatches = {mismatches, " valid_out"};

        if (actual.data_out !== expected.data_out)
            mismatches = {mismatches, " data_out"};

        if (actual.is_kcode !== expected.is_kcode)
            mismatches = {mismatches, " is_kcode"};

        if (actual.RxDataK !== expected.RxDataK)
            mismatches = {mismatches, " RxDataK"};

        if (actual.is_comma !== expected.is_comma)
            mismatches = {mismatches, " is_comma"};

        if (actual.is_skip !== expected.is_skip)
            mismatches = {mismatches, " is_skip"};

        if (actual.decode_error !== expected.decode_error)
            mismatches = {mismatches, " decode_error"};

        if (actual.disparity_error !== expected.disparity_error)
            mismatches = {mismatches, " disparity_error"};


        // Report result
        if (mismatches != "") begin

            failed_cycles++;

            `uvm_error("DEC_SCB",
                $sformatf(
                    "Cycle %0d mismatch in:%s\nEXPECTED: %s\nACTUAL:   %s",
                    total_cycles,
                    mismatches,
                    expected.convert2string(),
                    actual.convert2string()
                ))

        end
        else begin

            passed_cycles++;

            `uvm_info("DEC_SCB",
                $sformatf("Cycle %0d PASS: %s",
                          total_cycles, actual.convert2string()),
                UVM_HIGH)

        end

    endfunction


    // Report Phase
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("DEC_SCB_SUMMARY",
            $sformatf(
                "Checked=%0d Passed=%0d Failed=%0d Reset=%0d Active=%0d Idle=%0d",
                total_cycles,
                passed_cycles,
                failed_cycles,
                reset_cycles,
                active_cycles,
                idle_cycles
            ),
            UVM_NONE)

        if (total_cycles == 0)
            `uvm_error("DEC_SCB_EMPTY",
                       "No transactions reached the scoreboard")

    endfunction

endclass
