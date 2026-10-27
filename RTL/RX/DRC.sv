module DRC(input real V_diff, input logic recovered_clk, output logic recovered_data);
    
    always@(posedge recovered_clk) begin
        recovered_data <= (V_diff > 0) ? 1'b1 : 1'b0;
    end
    
endmodule