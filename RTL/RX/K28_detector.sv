module symbol_detector (
    input  logic       recovered_clk,
    input  logic       rst_n,
    input  logic [9:0] candidate_window,
    output logic       symbol_align,
    output logic       recovered_symbol_clk
);

    parameter logic [9:0] comma_plus  = 10'b1100000101;
    parameter logic [9:0] comma_minus = 10'b0011111010;

    logic [3:0] count;
    logic aligned;

    assign symbol_align = rst_n && !aligned &&((candidate_window == comma_plus) ||(candidate_window == comma_minus));

    always_ff @(posedge recovered_clk) begin

        if (!rst_n) begin
            recovered_symbol_clk <= 1'b0;
            count                <= 4'd0;
            aligned              <= 1'b0;
        end

        else if (symbol_align) begin
            recovered_symbol_clk <= 1'b1;
            count                <= 4'd0;
            aligned              <= 1'b1;
        end

        // Divide recovered bit clock by 10
        else if (aligned) begin

            if (count == 4'd4)
                recovered_symbol_clk <= 1'b0;
            else if (count == 4'd9)
                recovered_symbol_clk <= 1'b1;

            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 4'd1;

        end
    end

endmodule
