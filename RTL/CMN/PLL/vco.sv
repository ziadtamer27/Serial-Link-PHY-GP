module vco #(
    parameter real K = 50e6,
    parameter real FBIAS = 100e6,
    parameter real VBIAS = 0.5
)(
    input real vctrl,
    output reg vco_clk,
    output real fvco
);
    realtime period;

    timeunit 1ps / 1fs;

    
    initial begin
        vco_clk = 0;
        forever begin
            fvco = FBIAS + K*(vctrl - VBIAS);
            
            period = 1s /fvco;

            #(period/2);
            vco_clk = ~vco_clk;   
            
        end
    end



endmodule