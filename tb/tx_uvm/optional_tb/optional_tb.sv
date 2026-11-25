`timescale 1ns/1ps

module optional_tb;

    parameter DATA_WIDTH = 8;
    localparam K_WIDTH = DATA_WIDTH / 8;

    logic pclk;
    logic symbol_clk;
    logic rst_n;
    logic enable;

    logic [DATA_WIDTH-1:0] tx_data;
    logic [K_WIDTH-1:0] tx_data_k;

    logic [7:0] data_out;
    logic k_out;
    logic valid_out;

    // DUT instantiation
    optional #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .pclk       (pclk),
        .symbol_clk (symbol_clk),
        .rst_n      (rst_n),
        .enable     (enable),
        .tx_data    (tx_data),
        .tx_data_k  (tx_data_k),
        .data_out   (data_out),
        .k_out      (k_out),
        .valid_out  (valid_out)
    );

    // Symbol clock: 500 MHz
    initial begin
        symbol_clk = 1;
        forever #1 symbol_clk = ~symbol_clk;
    end

    // PCLK: 250 MHz
    initial begin
        pclk = 1;
        forever #1 pclk = ~pclk;
    end

    // Stimulus
    initial begin
        rst_n     = 0;
        enable    = 0;
        tx_data   = 0;
        tx_data_k = 0;

        // Release reset before first rising edge
        #1;
        rst_n     = 1;
        enable    = 1;

        tx_data   = 8'h12;
        tx_data_k = 1'b0;

        @(negedge pclk);
        tx_data   = 8'h34;
        tx_data_k = 1'b1;

        @(negedge pclk);
        tx_data   = 8'h56;
        tx_data_k = 1'b0;

        @(negedge pclk);
        tx_data   = 8'h9A;
        tx_data_k = 1'b1;

        @(negedge pclk);
        enable = 0;

        rst_n     = 0;
        enable    = 0;
        tx_data   = 0;
        tx_data_k = 0;

        // Release reset before first rising edge
        #0.5;
        rst_n     = 1;
        enable    = 1;

        tx_data   = 8'h12;
        tx_data_k = 1'b0;

        @(negedge pclk);
        tx_data   = 8'h34;
        tx_data_k = 1'b1;

        @(negedge pclk);
        tx_data   = 8'h56;
        tx_data_k = 1'b0;

        @(negedge pclk);
        tx_data   = 8'h9A;
        tx_data_k = 1'b1;

        @(negedge pclk);
        enable = 0;

        #10;
        $finish;
    end

    // Monitor what the encoder would sample
    always @(posedge symbol_clk) begin
        if (rst_n && valid_out)
            $display("Time=%0t | data_out=%h | k_out=%b",
                     $time, data_out, k_out);
    end

    // Waveform generation
    initial begin
        $dumpfile("optional_tb.vcd");
        $dumpvars(0, optional_tb);
    end

endmodule