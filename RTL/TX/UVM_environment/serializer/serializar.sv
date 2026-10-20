module serializer (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [9:0] parallel_data,
    output logic       serial_out
);
    //ahmed edited
    logic [9:0] shift_reg;
    logic [3:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg  <= '0;
            count      <= 0;
            serial_out <= 0;
        end
        else if (count == 0) begin
            // Load a new word and transmit bit 0
            shift_reg  <= parallel_data;
            serial_out <= parallel_data[0];
            count      <= 1;
        end
        else begin
            // Transmit the next bit and shift right
            shift_reg  <= {1'b0, shift_reg[9:1]};
            serial_out <= shift_reg[1];

            if (count == 9)
                count <= 0;
            else
                count <= count + 1'b1;
        end
    end

endmodule