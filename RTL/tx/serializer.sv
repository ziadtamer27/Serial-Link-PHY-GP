module serializer (
    input  logic       pclk,
    input  logic       bit_rate_clk,
    input  logic       rst_n,
    input  logic       enable,
    input  logic [9:0] parallel_data,
    output logic       serial_out
);

    logic [9:0] parallel_reg; // holding register for parallel data
    logic       word_ready;

    logic [9:0] shift_reg;
    logic [3:0] count;
    logic       active;

    always_ff @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_reg <= 0;
            word_ready   <= 1'b0;
        end
        else if (enable) begin
            parallel_reg <= parallel_data;
            word_ready   <= 1'b1;
        end
    end

    always_ff @(posedge bit_rate_clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg  <= 0;
            count      <= 0;
            active     <= 0;
            serial_out <= 0;
        end
        else begin
            // Load a captured word and transmit bit 0
            if (!active && word_ready) begin
                shift_reg  <= {1'b0, parallel_reg[9:1]};
                serial_out <= parallel_reg[0];
                count      <= 1;
                active     <= 1;
                // word_ready   <= 1'b0;
            end
            // Transmit remaining bits
            else if (active) begin
                serial_out <= shift_reg[0];
                shift_reg  <= {1'b0, shift_reg[9:1]};

                if (count == 9) begin
                    count  <= 0;
                    active <= 0;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
