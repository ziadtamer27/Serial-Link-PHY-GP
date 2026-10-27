class decoder_coverage extends uvm_subscriber #(decoder_sequence_item);

    `uvm_component_utils(decoder_coverage)

    // Coverage statistics
    int unsigned total_cycles;
    int unsigned reset_cycles;
    int unsigned idle_cycles;
    int unsigned active_cycles;
    int unsigned data_cycles;
    int unsigned kcode_cycles;
    int unsigned comma_cycles;
    int unsigned skip_cycles;
    int unsigned decode_error_cycles;
    int unsigned disparity_error_cycles;


    // Functional Coverage
    covergroup decoder_cg with function sample(
        input logic       rst_n,
        input bit         valid_in,
        input bit [9:0]   code_in,
        input logic       valid_out,
        input logic [7:0] data_out,
        input logic       is_kcode,
        input logic       is_comma,
        input logic       is_skip,
        input logic       decode_error,
        input logic       disparity_error
    );

        option.per_instance = 1;


        // Reset Coverage
        cp_reset: coverpoint rst_n {
            bins reset_asserted   = {1'b0};
            bins reset_deasserted = {1'b1};
        }


        // Input Valid Coverage
        cp_valid_in: coverpoint valid_in
            iff (rst_n === 1'b1) {

            bins idle   = {1'b0};
            bins active = {1'b1};
        }


        // Output Valid Coverage
        cp_valid_out: coverpoint valid_out
            iff (rst_n === 1'b1) {

            bins inactive = {1'b0};
            bins active   = {1'b1};
        }


        // All 1024 Possible 10-bit Input Patterns
        cp_code_in: coverpoint code_in
            iff (rst_n === 1'b1 && valid_in == 1'b1) {

            bins all_codewords[] = {[10'd0:10'd1023]};
        }


        // All 256 Data Characters
        cp_data: coverpoint data_out
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0 &&
                 is_kcode === 1'b0) {

            bins all_data[] = {[8'h00:8'hFF]};
        }


        // All 12 Defined K Characters
        cp_kcode: coverpoint data_out
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0 &&
                 is_kcode === 1'b1) {

            bins all_kcodes[] = {
                8'h1C, 8'h3C, 8'h5C, 8'h7C,
                8'h9C, 8'hBC, 8'hDC, 8'hFC,
                8'hF7, 8'hFB, 8'hFD, 8'hFE
            };
        }


        // COM Character Coverage
        cp_comma: coverpoint is_comma
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0 &&
                 is_kcode === 1'b1) {

            bins not_comma = {1'b0};
            bins comma     = {1'b1};
        }


        // SKP Character Coverage
        cp_skip: coverpoint is_skip
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0 &&
                 is_kcode === 1'b1) {

            bins not_skip = {1'b0};
            bins skip     = {1'b1};
        }


        // Decode Error Coverage
        cp_decode_error: coverpoint decode_error
            iff (rst_n === 1'b1 && valid_in == 1'b1) {

            bins no_error = {1'b0};
            bins error    = {1'b1};
        }


        // Legal Symbol Type
        cp_legal_type: coverpoint is_kcode
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0) {

            bins data_symbol = {1'b0};
            bins k_symbol    = {1'b1};
        }


        // Running Disparity Error Coverage
        cp_disparity_error: coverpoint disparity_error
            iff (rst_n === 1'b1 &&
                 valid_out === 1'b1 &&
                 decode_error === 1'b0) {

            bins correct_disparity = {1'b0};
            bins wrong_disparity   = {1'b1};
        }


        // Data/K Character vs Disparity Error
        cross_type_disparity:
            cross cp_legal_type, cp_disparity_error;


        // K Character vs Disparity Error
        cross_kcode_disparity:
            cross cp_kcode, cp_disparity_error;

    endgroup


    // Constructor
    function new(string name = "decoder_coverage",
                 uvm_component parent = null);

        super.new(name, parent);

        decoder_cg = new();

    endfunction


    // Receive Monitored Transaction
    virtual function void write(decoder_sequence_item t);

        if (t == null)
            `uvm_fatal("DEC_COV", "Received null transaction")

        total_cycles++;

        // Sample functional coverage
        decoder_cg.sample(
            t.rst_n,
            t.valid_in,
            t.code_in,
            t.valid_out,
            t.data_out,
            t.is_kcode,
            t.is_comma,
            t.is_skip,
            t.decode_error,
            t.disparity_error
        );


        // Collect statistics
        if (t.rst_n !== 1'b1) begin

            reset_cycles++;

        end
        else if (t.valid_in == 1'b0) begin

            idle_cycles++;

        end
        else begin

            active_cycles++;

            if (t.decode_error === 1'b1)
                decode_error_cycles++;

            if (t.disparity_error === 1'b1)
                disparity_error_cycles++;

            if (t.valid_out === 1'b1 &&
                t.decode_error === 1'b0) begin

                if (t.is_kcode === 1'b1)
                    kcode_cycles++;
                else if (t.is_kcode === 1'b0)
                    data_cycles++;

                if (t.is_comma === 1'b1)
                    comma_cycles++;

                if (t.is_skip === 1'b1)
                    skip_cycles++;

            end

        end

    endfunction


    // Coverage Report
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info("DEC_COV",
            $sformatf(
                {"Coverage = %0.2f%%\n",
                 "Total=%0d Reset=%0d Idle=%0d Active=%0d\n",
                 "Data=%0d Kcode=%0d COM=%0d SKP=%0d\n",
                 "Decode_errors=%0d Disparity_errors=%0d"},
                decoder_cg.get_inst_coverage(),
                total_cycles,
                reset_cycles,
                idle_cycles,
                active_cycles,
                data_cycles,
                kcode_cycles,
                comma_cycles,
                skip_cycles,
                decode_error_cycles,
                disparity_error_cycles
            ),
            UVM_LOW)

    endfunction

endclass
