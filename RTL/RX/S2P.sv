module serial_to_parallel (
    input  logic       recovered_clk,
    input  logic       recovered_data,
    input  logic       rst_n,
    input  logic       Rx_Polarity,
    input  logic       symbol_align,
    output logic [9:0] candidate_window,
    output logic [9:0] parallel_data,
    output logic       symbol_valid
);
    logic [9:0] bit_window;
    logic [3:0] bit_count;
    logic aligned;
    // wire serial_bit;
    // assign serial_bit = Rx_Polarity ? ~recovered_data : recovered_data;
    wire serial_bit = recovered_data ^ Rx_Polarity;

    assign candidate_window = {bit_window[8:0], serial_bit};

    always_ff @(posedge recovered_clk) begin
        if (!rst_n) begin
            bit_window    <= 10'b0;
            parallel_data <= 10'b0;
            symbol_valid  <= 1'b0;
            bit_count     <= 4'd0;
            aligned       <= 1'b0;
        end
        else begin
            bit_window   <= candidate_window;
            symbol_valid <= 1'b0;

            if (symbol_align) begin
                aligned       <= 1'b1;
                bit_count     <= 4'd0;
                parallel_data <= candidate_window;
                symbol_valid  <= 1'b1;
            end
            else if (aligned) begin
                if (bit_count == 4'd9) begin
                    parallel_data <= candidate_window;
                    symbol_valid  <= 1'b1;
                    bit_count     <= 4'd0;
                end
                else begin
                    bit_count <= bit_count + 4'd1;
                end
            end
        end
    end

endmodule
