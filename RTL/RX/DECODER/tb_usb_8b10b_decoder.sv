`timescale 1ns/1ps

// Simple decoder-only testbench. No external vector file is needed.
// Run: vsim -c -do run_decoder_simple.do
// Symbols below use the specification's abcdei_fghj order.
module tb_usb_8b10b_decoder_simple;
    logic clk = 1'b0;
    always #5 clk = ~clk; // 10 ns test clock; not a hardware timing test.

    logic rst_n = 1'b1;
    logic valid_in = 1'b0;
    logic [9:0] code_in = '0;
    logic valid_out;
    logic [7:0] data_out;
    logic is_kcode, RxDataK, is_comma, is_skip;
    logic decode_error, disparity_error;

    integer transcript_file;
    integer case_count = 0;
    integer failed_cases = 0;
    bit test_passed = 1'b0;
    string transcript_path = "usb_decoder_simple_transcript.txt";

    usb_8b10b_decoder dut (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in), .code_in(code_in),
        .valid_out(valid_out), .data_out(data_out),
        .is_kcode(is_kcode), .RxDataK(RxDataK),
        .is_comma(is_comma), .is_skip(is_skip),
        .decode_error(decode_error), .disparity_error(disparity_error)
    );

    // Print the same friendly text to Questa and to a plain text file.
    task automatic say(input string message);
        $display("%s", message);
        $fdisplay(transcript_file, "%s", message);
    endtask

    task automatic show_bit(
        input string signal_name,
        input logic expected_value,
        input logic actual_value
    );
        say($sformatf("  %-19s %b          %b        %s",
            signal_name, expected_value, actual_value,
            (actual_value === expected_value) ? "OK" : "MISMATCH"));
    endtask

    function automatic string rd_name(input logic rd, input logic known);
        if (known !== 1'b1) return "UNKNOWN (stored polarity is not yet trustworthy)";
        if (rd === 1'b1) return "RD+ / positive";
        if (rd === 1'b0) return "RD- / negative";
        return "X/Z (invalid stored polarity)";
    endfunction

    // Supply expected values by hand. This task does not decode the input.
    // Defaults describe an ordinary, error-free data symbol with known RD-.
    task automatic run_case(
        input string name,
        input string explanation,
        input logic [9:0] printed_symbol,
        input logic [7:0] expected_data,
        input bit expected_k = 1'b0,
        input bit expected_decode_error = 1'b0,
        input bit expected_disparity_error = 1'b0,
        input bit expected_rd = 1'b0,
        input bit expected_known = 1'b1,
        input bit input_valid = 1'b1,
        input bit reset_n = 1'b1
    );
        bit expected_valid, expected_comma, expected_skip;
        logic rd_before, known_before;
        bit case_ok;
        begin
            // Change inputs away from the rising edge to avoid races.
            @(negedge clk);
            rd_before = dut.running_disparity;
            known_before = dut.rd_known;
            rst_n = reset_n;
            valid_in = input_valid;
            // code_in[0]=a, while printed_symbol[9]=a: reverse the bits.
            code_in = {<<{printed_symbol}};

            if (!reset_n)
                #1; // Check asynchronous reset without waiting for a clock.
            else begin
                @(posedge clk);
                #1; // Wait for the registered outputs to settle.
            end

            expected_valid = reset_n && input_valid;
            // COM and SKP are defined by the expected byte AND its K flag.
            expected_comma = expected_valid && expected_k && (expected_data == 8'hBC);
            expected_skip  = expected_valid && expected_k && (expected_data == 8'h3C);

            case_count = case_count + 1;
            say("");
            say("====================================================================");
            say($sformatf("CASE %0d: %s", case_count, name));
            say($sformatf("WHY: %s", explanation));
            say($sformatf("INPUT at %0t: clk=%b, rst_n=%b, valid_in=%b",
                $time, clk, rst_n, valid_in));
            say($sformatf("  Specification order abcdei_fghj = %06b_%04b",
                printed_symbol[9:4], printed_symbol[3:0]));
            say($sformatf("  Actual code_in[9:0]             = %010b", code_in));
            say($sformatf("  RD before this input: %s", rd_name(rd_before, known_before)));
            say("OUTPUT / DEBUG STATE   EXPECTED   ACTUAL   CHECK");
            show_bit("valid_out", expected_valid, valid_out);
            say($sformatf("  %-19s 0x%02h       0x%02h     %s", "data_out",
                expected_data, data_out,
                (data_out === expected_data) ? "OK" : "MISMATCH"));
            show_bit("is_kcode", expected_k, is_kcode);
            show_bit("RxDataK", expected_k, RxDataK);
            show_bit("is_comma", expected_comma, is_comma);
            show_bit("is_skip", expected_skip, is_skip);
            show_bit("decode_error", expected_decode_error, decode_error);
            show_bit("disparity_error", expected_disparity_error, disparity_error);
            show_bit("running_disparity*", expected_rd, dut.running_disparity);
            show_bit("rd_known*", expected_known, dut.rd_known);
            say($sformatf("  Expected RD after: %s", rd_name(expected_rd, expected_known)));
            say($sformatf("  Actual RD after:   %s", rd_name(dut.running_disparity, dut.rd_known)));

            // Four-state comparison also catches unexpected X or Z values.
            case_ok = {valid_out, data_out, is_kcode, RxDataK, is_comma,
                       is_skip, decode_error, disparity_error,
                       dut.running_disparity, dut.rd_known} ===
                      {expected_valid, expected_data, expected_k, expected_k,
                       expected_comma, expected_skip, expected_decode_error,
                       expected_disparity_error, expected_rd, expected_known};
            if (case_ok)
                say("RESULT: PASS - every checked value matches.");
            else begin
                failed_cases = failed_cases + 1;
                say("RESULT: FAIL - see the MISMATCH rows above.");
            end
        end
    endtask

    initial begin
        $timeformat(-9, 0, " ns", 8);
        if ($value$plusargs("TRANSCRIPT=%s", transcript_path)) begin end
        transcript_file = $fopen(transcript_path, "w");
        if (transcript_file == 0)
            $fatal(1, "Cannot create transcript: %s", transcript_path);

        say("USB 3.0 8b/10b DECODER - SIMPLE WALKTHROUGH");
        say("Expected values are written in the test cases; Actual comes from the DUT.");
        say("INPUTS:");
        say("  clk: sample a symbol on the rising edge (10 ns test period).");
        say("  rst_n: 0 resets immediately; 1 allows normal operation.");
        say("  valid_in: 1 accepts code_in; 0 ignores it and holds the last byte/RD.");
        say("  code_in: aligned 10-bit input; bit 0 is the first transmitted bit a.");
        say("OUTPUTS:");
        say("  valid_out: 1 means this output byte is valid; 0 means no new byte.");
        say("  data_out: decoded byte; invalid codes produce SUB = 0x9C.");
        say("  is_kcode / RxDataK: 1 means control (K); 0 means data (D).");
        say("  is_comma: K28.5 / COM; is_skip: K28.1 / SKP.");
        say("  decode_error: the ten-bit input is absent from both legal RD columns.");
        say("  disparity_error: legal code, but wrong for the previously known RD.");
        say("DEBUG STATE (* internal signals, not output ports):");
        say("  running_disparity: 0 = RD-, 1 = RD+; rd_known: 1 = trustworthy.");
        say("  With rd_known=0, the stored RD is a placeholder; no disparity error.");
        say("TIMING: ordinary cases check 1 ns after a rising edge.");
        say("        Reset cases check 1 ns after reset assertion at a falling edge.");
        say("FLAGS DEFAULT TO ZERO; EXPECTED RD DEFAULTS TO KNOWN RD-.");

        run_case(.name("Asynchronous reset"),
            .explanation("Reset must clear outputs immediately, even with valid_in=1."),
            .printed_symbol(10'b111111_1111), .expected_data(8'h00),
            .expected_known(0), .reset_n(0));

        run_case(.name("Balanced D3.1 while RD is unknown"),
            .explanation("Both groups are balanced. Decode 0x23, but do not learn a polarity."),
            .printed_symbol(10'b110001_1001), .expected_data(8'h23),
            .expected_known(0));

        run_case(.name("Another balanced data symbol: D5.2"),
            .explanation("Decode 0x45. A second balanced symbol still cannot establish RD."),
            .printed_symbol(10'b101001_0101), .expected_data(8'h45),
            .expected_known(0));

        run_case(.name("COM acquires the positive incoming column"),
            .explanation("This COM spelling requires incoming RD+. It leaves RD- and marks RD known."),
            .printed_symbol(10'b110000_0101), .expected_data(8'hBC), .expected_k(1));

        run_case(.name("D28.5: same byte as COM, but ordinary data"),
            .explanation("0xBC alone does not mean COM. This is a D character, so both K flags are 0."),
            .printed_symbol(10'b001110_1010), .expected_data(8'hBC));

        run_case(.name("SKP from the negative column"),
            .explanation("K28.1 decodes to 0x3C. Assert K and SKP; outgoing RD becomes positive."),
            .printed_symbol(10'b001111_1001), .expected_data(8'h3C),
            .expected_k(1), .expected_rd(1));

        run_case(.name("D28.1: same byte as SKP, but ordinary data"),
            .explanation("Decode 0x3C with K=0 and SKP=0. Balanced groups preserve RD+."),
            .printed_symbol(10'b001110_1001), .expected_data(8'h3C), .expected_rd(1));

        run_case(.name("Correct positive-column D7.1"),
            .explanation("Balanced six-bit D7 must use 000111 for incoming RD+."),
            .printed_symbol(10'b000111_1001), .expected_data(8'h27), .expected_rd(1));

        run_case(.name("Wrong disparity: negative-column D7.1"),
            .explanation("111000 is the other D7 spelling. Keep byte 0x27, flag disparity_error, recover to RD-."),
            .printed_symbol(10'b111000_1001), .expected_data(8'h27),
            .expected_disparity_error(1));

        run_case(.name("Alternate A7 data: D17.7"),
            .explanation("For x=17 with RD-, use alternate 0111. It remains data, not a K character."),
            .printed_symbol(10'b100011_0111), .expected_data(8'hF1), .expected_rd(1));

        run_case(.name("Control character K23.7"),
            .explanation("The full control code decodes to 0xF7 with K=1, COM=0, and SKP=0."),
            .printed_symbol(10'b000101_0111), .expected_data(8'hF7),
            .expected_k(1), .expected_rd(1));

        run_case(.name("Data character D23.7"),
            .explanation("This also produces 0xF7, but a different four-bit suffix makes K=0."),
            .printed_symbol(10'b000101_1110), .expected_data(8'hF7), .expected_rd(1));

        run_case(.name("Invalid all-zero code becomes SUB"),
            .explanation("Return SUB 0x9C with K=1 and decode_error=1. Hold RD and clear rd_known."),
            .printed_symbol(10'b000000_0000), .expected_data(8'h9C), .expected_k(1),
            .expected_decode_error(1), .expected_rd(1), .expected_known(0));

        run_case(.name("Idle cycle ignores an invalid input"),
            .explanation("valid_in=0: hold byte 0x9C and RD, but clear valid_out and all output flags."),
            .printed_symbol(10'b111111_1111), .expected_data(8'h9C),
            .expected_rd(1), .expected_known(0), .input_valid(0));

        run_case(.name("Balanced data after a decode error"),
            .explanation("Accept data 0x3C. Both columns allow it, so RD remains unknown."),
            .printed_symbol(10'b001110_1001), .expected_data(8'h3C),
            .expected_rd(1), .expected_known(0));

        run_case(.name("COM reacquires the negative incoming column"),
            .explanation("Accept the negative-column COM without a disparity error while RD is unknown."),
            .printed_symbol(10'b001111_1010), .expected_data(8'hBC),
            .expected_k(1), .expected_rd(1));

        run_case(.name("SKP from the positive column"),
            .explanation("The other legal SKP spelling still gives 0x3C with K=1 and SKP=1."),
            .printed_symbol(10'b110000_0110), .expected_data(8'h3C), .expected_k(1));

        run_case(.name("Recognized halves, forbidden A7 combination"),
            .explanation("A7 is not allowed for D0.7 here. Valid-looking halves still produce a decode error."),
            .printed_symbol(10'b100111_0111), .expected_data(8'h9C),
            .expected_k(1), .expected_decode_error(1), .expected_known(0));

        run_case(.name("Reset in the middle of a receive session"),
            .explanation("Asynchronous reset clears held data, error flags, and running-disparity history."),
            .printed_symbol(10'b111111_1111), .expected_data(8'h00),
            .expected_known(0), .reset_n(0));

        run_case(.name("Idle after reset"),
            .explanation("No symbol is accepted. Data stays 0x00 and RD stays unknown."),
            .printed_symbol(10'b111111_1111), .expected_data(8'h00),
            .expected_known(0), .input_valid(0));

        say("");
        say("====================================================================");
        say($sformatf("SUMMARY: %0d cases, %0d passed, %0d failed.",
            case_count, case_count - failed_cases, failed_cases));
        say("This is a directed learning test; the separate exhaustive testbench remains available.");
        $fclose(transcript_file);
        if (failed_cases != 0)
            $fatal(1, "Decoder walkthrough failed: %0d case(s). See %s", failed_cases, transcript_path);
        test_passed = 1'b1;
        $display("All decoder walkthrough cases passed. Transcript: %s", transcript_path);
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "Testbench timeout");
    end
endmodule
