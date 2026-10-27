`timescale 1ns/1ps

module tb_usb_descrambler;
    logic       clk;
    logic       rst_n;
    logic       valid_in;
    logic [7:0] data_in;
    logic       is_comma;
    logic       is_skip;
    logic       is_kcode;
    logic       training_sequence;
    logic       valid_out;
    logic [7:0] data_out;

    integer      transcript_fd;
    integer      cycle_count;
    logic [15:0] lfsr_before_edge;

    usb_descrambler dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .valid_in          (valid_in),
        .data_in           (data_in),
        .is_comma          (is_comma),
        .is_skip           (is_skip),
        .is_kcode          (is_kcode),
        .training_sequence (training_sequence),
        .valid_out         (valid_out),
        .data_out          (data_out)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    initial begin
        cycle_count = 0;
        transcript_fd = $fopen("usb_descrambler_transcript.txt", "w");
        if (transcript_fd == 0)
            $fatal(1, "Could not open usb_descrambler_transcript.txt");

        $display("cycle | rst_n | valid_in | data_in | comma skip kcode training | valid_out | data_out | LFSR before -> after");
        $fdisplay(transcript_fd,"cycle | rst_n | valid_in | data_in | comma skip kcode training | valid_out | data_out | LFSR before -> after");
    end

    always @(posedge clk) begin
        lfsr_before_edge = dut.lfsr;
        #1;
        $display("%5d |   %b   |    %b     |   %02h    |   %b     %b     %b       %b      |     %b     |   %02h    |    %04h       %04h",
                 cycle_count, rst_n, valid_in, data_in,
                 is_comma, is_skip, is_kcode, training_sequence,
                 valid_out, data_out, lfsr_before_edge, dut.lfsr);
        $fdisplay(transcript_fd,
                  "%5d |   %b   |    %b     |   %02h    |   %b     %b     %b       %b      |     %b     |   %02h    |    %04h       %04h",
                  cycle_count, rst_n, valid_in, data_in,
                  is_comma, is_skip, is_kcode, training_sequence,
                  valid_out, data_out, lfsr_before_edge, dut.lfsr);
        cycle_count = cycle_count + 1;
    end

    function automatic logic [15:0] advance_lfsr(input logic [15:0] state);
        logic [15:0] next_state;
        begin
            next_state[0]  = state[8];
            next_state[1]  = state[9];
            next_state[2]  = state[10];
            next_state[3]  = state[11] ^ state[8];
            next_state[4]  = state[12] ^ state[9] ^ state[8];
            next_state[5]  = state[13] ^ state[10] ^ state[9] ^ state[8];
            next_state[6]  = state[14] ^ state[11] ^ state[10] ^ state[9];
            next_state[7]  = state[15] ^ state[12] ^ state[11] ^ state[10];
            next_state[8]  = state[0] ^ state[13] ^ state[12] ^ state[11];
            next_state[9]  = state[1] ^ state[14] ^ state[13] ^ state[12];
            next_state[10] = state[2] ^ state[15] ^ state[14] ^ state[13];
            next_state[11] = state[3] ^ state[15] ^ state[14];
            next_state[12] = state[4] ^ state[15];
            next_state[13] = state[5];
            next_state[14] = state[6];
            next_state[15] = state[7];
            advance_lfsr = next_state;
        end
    endfunction

    task automatic send_symbol(
        input string       scenario,
        input logic [7:0]  symbol,
        input logic        comma,
        input logic        skip,
        input logic        kcode,
        input logic        training
    );
        logic [15:0] state_before;
        logic [15:0] state_expected;
        logic [7:0]  data_expected;
        begin
            @(negedge clk);
            state_before = dut.lfsr;

            valid_in          = 1'b1;
            data_in           = symbol;
            is_comma          = comma;
            is_skip           = skip;
            is_kcode          = kcode;
            training_sequence = training;

            if (comma) begin
                state_expected = 16'hFFFF;
                data_expected  = symbol;
            end else if (skip) begin
                state_expected = state_before;
                data_expected  = symbol;
            end else begin
                state_expected = advance_lfsr(state_before);
                if (!kcode && !training)
                    data_expected = symbol ^ {
                        dut.lfsr[8], dut.lfsr[9], dut.lfsr[10], dut.lfsr[11],
                        dut.lfsr[12], dut.lfsr[13], dut.lfsr[14], dut.lfsr[15]
                    };
                else
                    data_expected = symbol;
            end

            @(posedge clk);
            #1;
            if (valid_out !== 1'b1)
                $fatal(1, "%s: valid_out was not asserted", scenario);
            if (data_out !== data_expected)
                $fatal(1, "%s: expected data %02h, got %02h",
                       scenario, data_expected, data_out);
            if (dut.lfsr !== state_expected)
                $fatal(1, "%s: expected LFSR %04h, got %04h",
                       scenario, state_expected, dut.lfsr);
        end
    endtask

    initial begin
        logic [15:0] idle_state;
        logic [7:0]  idle_data;

        valid_in          = 1'b0;
        data_in           = 8'h00;
        is_comma          = 1'b0;
        is_skip           = 1'b0;
        is_kcode          = 1'b0;
        training_sequence = 1'b0;
        rst_n             = 1'b0;

        #1;
        if (dut.lfsr !== 16'hFFFF)
            $fatal(1, "Reset failed: expected LFSR FFFF, got %04h", dut.lfsr);
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        send_symbol("ordinary data after reset", 8'h00,
                    1'b0, 1'b0, 1'b0, 1'b0);
        if (dut.lfsr !== 16'hE817)
            $fatal(1, "Known vector failed: expected LFSR E817, got %04h", dut.lfsr);

        send_symbol("K-code bypass + advance", 8'hBC,1'b0, 1'b0, 1'b1, 1'b0);

        send_symbol("training bypass + advance", 8'h1C,1'b0, 1'b0, 1'b0, 1'b1);

        send_symbol("SKIP bypass + hold", 8'h3C,
                    1'b0, 1'b1, 1'b0, 1'b0);

        send_symbol("ordinary data", 8'b01010101,
                    1'b0, 1'b0, 1'b0, 1'b0);

        @(negedge clk);
        idle_state = dut.lfsr;
        idle_data  = data_out;
        valid_in = 1'b0;
        @(posedge clk);
        #1;
        if (valid_out !== 1'b0)
            $fatal(1, "Idle cycle: valid_out should be low");
        if (dut.lfsr !== idle_state)
            $fatal(1, "Idle cycle: LFSR should hold at %04h, got %04h",
                   idle_state, dut.lfsr);
        if (data_out !== idle_data)
            $fatal(1, "Idle cycle: data_out should hold at %02h, got %02h",
                   idle_data, data_out);

        send_symbol("COMMA bypass + reset", 8'hBC,
                    1'b1, 1'b0, 1'b1, 1'b0);

        send_symbol("ordinary data after COMMA", 8'h00,
                    1'b0, 1'b0, 1'b0, 1'b0);
        if (dut.lfsr !== 16'hE817)
            $fatal(1, "Post-COMMA known vector failed: expected E817, got %04h",
                   dut.lfsr);

        @(negedge clk);
        valid_in = 1'b0;
        $display("All testbench checks passed. Transcript: usb_descrambler_transcript.txt");
        $fclose(transcript_fd);
        $finish;
    end
endmodule
