`timescale 1ns/1ps

// Exhaustive reference data is extracted directly from USB 3.0 Appendix A.
// Locate vectors beside this source or in common project launch folders.
// +VECTORS=<path> explicitly overrides discovery. No encoder oracle is used.
module tb_usb_8b10b_decoder;
    bit test_passed = 1'b0;
    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic rst_n = 1'b1;
    logic valid_in = 1'b0;
    logic [9:0] code_in = '0;
    wire valid_out;
    wire [7:0] data_out;
    wire is_kcode, is_comma, is_skip, code_error, disparity_error;
    wire RxDataK;

    usb_8b10b_decoder dut (.decode_error(code_error), .*);

    logic [15:0] vectors [0:1023];
    string vector_path;
    integer vector_fd;

    function automatic string find_vector_file;
        string source_file;
        string candidates [0:3];
        integer last_separator, index, fd;
        begin
            source_file = `__FILE__;
            last_separator = -1;
            for (index = 0; index < source_file.len(); index = index + 1)
                if (source_file[index] == 8'h2f || source_file[index] == 8'h5c)
                    last_separator = index;
            candidates[0] = "usb_8b10b_vectors.mem";
            if (last_separator >= 0)
                candidates[0] = {source_file.substr(0, last_separator),
                                 "usb_8b10b_vectors.mem"};
            candidates[1] = "usb_8b10b_vectors.mem";
            candidates[2] = "DECODER/usb_8b10b_vectors.mem";
            candidates[3] = "RTL/RX/DECODER/usb_8b10b_vectors.mem";
            for (index = 0; index < 4; index = index + 1) begin
                fd = $fopen(candidates[index], "r");
                if (fd != 0) begin
                    $fclose(fd);
                    return candidates[index];
                end
            end
            return "";
        end
    endfunction
    logic ref_rd = 1'b0;
    logic ref_known = 1'b0;
    logic ref_valid = 1'b0;
    logic [7:0] ref_data = '0;
    logic ref_k = 1'b0, ref_comma = 1'b0, ref_skip = 1'b0;
    logic ref_code_error = 1'b0, ref_disparity_error = 1'b0;
    integer checks = 0;
    integer accepted = 0;
    integer invalid_codes = 0;
    integer disparity_violations = 0;
    integer i, state;

    task automatic compare_outputs;
        begin
            checks = checks + 1;
            if ({valid_out, data_out, is_kcode, RxDataK, is_comma, is_skip,
                 code_error, disparity_error} !==
                {ref_valid, ref_data, ref_k, ref_k, ref_comma, ref_skip,
                 ref_code_error, ref_disparity_error}) begin
                $error("Output mismatch check=%0d code=%010b valid=%b time=%0t",
                       checks, code_in, valid_in, $time);
                $error("Got valid/data/K/RxDataK/COM/SKP/code_err/disp_err=%b %02h %b %b %b %b %b %b",
                       valid_out, data_out, is_kcode, RxDataK, is_comma, is_skip,
                       code_error, disparity_error);
                $fatal(1, "Expected=%b %02h %b %b %b %b %b %b",
                       ref_valid, ref_data, ref_k, ref_k, ref_comma, ref_skip,
                       ref_code_error, ref_disparity_error);
            end
            // State checks catch silent disparity tracking mistakes even when
            // the next symbol happens to be legal for both polarities.
            if (dut.running_disparity !== ref_rd || dut.rd_known !== ref_known)
                $fatal(1, "RD state mismatch check=%0d code=%010b: got %b/%b expected %b/%b",
                       checks, code_in, dut.running_disparity, dut.rd_known,
                       ref_rd, ref_known);
        end
    endtask

    task automatic reset_decoder;
        begin
            // Assert away from an active edge to verify asynchronous reset.
            #2;
            rst_n = 1'b0;
            valid_in = 1'b0;
            code_in = '0;
            ref_rd = 1'b0;
            ref_known = 1'b0;
            ref_valid = 1'b0;
            ref_data = '0;
            ref_k = 1'b0;
            ref_comma = 1'b0;
            ref_skip = 1'b0;
            ref_code_error = 1'b0;
            ref_disparity_error = 1'b0;
            #1;
            compare_outputs();
            @(negedge clk);
            rst_n = 1'b1;
        end
    endtask

    task automatic drive(input logic valid, input logic [9:0] code);
        logic [15:0] entry;
        logic legal_neg, legal_pos, accepted_rd;
        begin
            @(negedge clk);
            valid_in = valid;
            code_in = code;
            ref_valid = valid;
            ref_k = 1'b0;
            ref_comma = 1'b0;
            ref_skip = 1'b0;
            ref_code_error = 1'b0;
            ref_disparity_error = 1'b0;
            if (valid) begin
                // A four-state input is never a valid code-table index.
                entry = 16'h0000;
                if ((^code) !== 1'bx)
                    entry = vectors[code];
                legal_neg = entry[15];
                legal_pos = entry[14];
                if (!(legal_neg || legal_pos)) begin
                    ref_data = 8'h9c;
                    ref_k = 1'b1;
                    ref_code_error = 1'b1;
                    ref_known = 1'b0;
                    invalid_codes = invalid_codes + 1;
                end else begin
                    ref_data = entry[8:1];
                    ref_k = entry[11];
                    ref_comma = entry[10];
                    ref_skip = entry[9];
                    ref_disparity_error = ref_known &&
                        ((ref_rd && !legal_pos) || (!ref_rd && !legal_neg));
                    // Legal in one column: use that column even on RD error.
                    // Legal in both: retain the receiver's current polarity.
                    accepted_rd = legal_neg && legal_pos ? ref_rd : legal_pos;
                    ref_rd = accepted_rd ? entry[12] : entry[13];
                    if (legal_neg ^ legal_pos)
                        ref_known = 1'b1;
                    accepted = accepted + 1;
                    if (ref_disparity_error)
                        disparity_violations = disparity_violations + 1;
                end
            end
            @(posedge clk);
            #1;
            compare_outputs();
        end
    endtask

    task automatic seed_known(input logic rd);
        begin
            // K28.5: RD+ spelling exits negative; RD- spelling exits positive.
            drive(1'b1, rd ? 10'h17c : 10'h283);
            if (!ref_known || ref_rd !== rd)
                $fatal(1, "Reference COM seeding failed");
        end
    endtask

    initial begin
        if (!$value$plusargs("VECTORS=%s", vector_path))
            vector_path = find_vector_file();
        vector_fd = 0;
        if (vector_path != "") vector_fd = $fopen(vector_path, "r");
        if (vector_fd == 0)
            $fatal(1, "Cannot open vectors '%s'. Relaunch with +VECTORS=<full-path>/usb_8b10b_vectors.mem", vector_path);
        $fclose(vector_fd);
        $display("Loading decoder vectors from %s", vector_path);
        $readmemh(vector_path, vectors);
        for (i = 0; i < 1024; i = i + 1)
            if ((^vectors[i]) === 1'bx)
                $fatal(1, "Missing vector %0d from %s", i, vector_path);

        // Every possible code from each known incoming RD and from unknown RD.
        for (state = 0; state < 3; state = state + 1) begin
            for (i = 0; i < 1024; i = i + 1) begin
                reset_decoder();
                if (state < 2)
                    seed_known(state == 1);
                drive(1'b1, i[9:0]);
            end
        end

        // An uninterrupted stream exercises back-to-back registered results,
        // error recovery, and repeated unknown-to-known acquisition.
        reset_decoder();
        for (i = 0; i < 1024; i = i + 1)
            drive(1'b1, i[9:0]);
        for (i = 1023; i >= 0; i = i - 1)
            drive(1'b1, i[9:0]);

        // Directed training, SKP, idle hold, corrupted symbols and recovery.
        reset_decoder();
        drive(1'b1, 10'h271); // D17.1, balanced in both subblocks: stays unknown.
        drive(1'b1, 10'h17c); // COM establishes positive RD.
        drive(1'b1, 10'h27c); // SKP with incoming RD-: disparity error, recover.
        drive(1'b0, 10'h000); // Idle: hold byte and state, clear flags.
        drive(1'b0, 10'h3ff);
        drive(1'b1, 10'h000); // Invalid: substitute K28.4 and forget RD.
        drive(1'b0, 10'h17c);
        drive(1'b1, 10'h283); // Reacquire without a disparity error.
        drive(1'b1, 10'bxxxxxxxxxx);
        drive(1'b1, 10'h17c);
        drive(1'b1, 10'bzzzzzzzzzz);
        drive(1'b1, 10'h283);
        drive(1'b0, 10'bxxxxxxxxxx);
        drive(1'b1, 10'b010x111100);
        drive(1'b1, 10'h17c);
        reset_decoder();
        drive(1'b0, 10'h000);

        test_passed = 1'b1;
        $display("PASS: %0d checks, %0d accepted symbols, %0d invalid symbols, %0d disparity errors",
                 checks, accepted, invalid_codes, disparity_violations);
        $display("Exhaustive: all 1024 codes at RD-, RD+, and unknown; two 1024-symbol streams; reset/idle/X/Z/recovery.");
        $finish;
    end

    initial begin
        #1000000;
        $fatal(1, "Simulation timeout");
    end
endmodule
