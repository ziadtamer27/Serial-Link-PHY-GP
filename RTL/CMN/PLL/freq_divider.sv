module freq_divider #(
    parameter N = 10
)(
    input vco_clk,
    input rst_n,
    output reg vco_clk_N
);

localparam int WIDTH = $clog2(N/2);
reg [WIDTH-1:0] count;

always @(posedge vco_clk or negedge rst_n) begin
    if(!rst_n) begin
        count <= 0;
        vco_clk_N <= 0;
    end
    else if(count == (N/2)-1) begin
        vco_clk_N <= ~vco_clk_N;
        count <= 0; 
    end
    else begin
        count <= count + 1;
    end
    
end

endmodule