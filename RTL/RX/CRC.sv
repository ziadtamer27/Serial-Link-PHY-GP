timeunit 1ps;
timeprecision 1fs;
module CRC (input logic clk, input real V_diff, output logic recovered_clk);
    realtime t_rise,t_fall,t_diff;
    realtime min_t_diff = 1.0e308; 
    realtime half_t;
    real past_V_diff;
    bit valid = 0;

    initial begin
        recovered_clk = 0;
        wait(valid == 1);
        forever begin
            fork
                begin
                    recovered_clk = 0;
                    forever begin
                        #(half_t);
                        recovered_clk = ~recovered_clk;
                    end
                end
                begin
                    @(min_t_diff);
                end
            join_any
            disable fork;
        end
    end

    always@(V_diff) begin
        if(past_V_diff > 0 && V_diff < 0) begin
            t_fall = $realtime();
        end
        else if(past_V_diff < 0 && V_diff > 0) begin
            t_rise = $realtime();
        end
        past_V_diff = V_diff;
       
    end

    always @(t_fall or t_rise) begin
        if(t_fall != 0 && t_rise != 0) begin
            t_diff = ((t_rise > t_fall) ? (t_rise - t_fall) : (t_fall - t_rise)) ;
        end
    end

    always@(t_diff) begin
        min_t_diff = (t_diff < min_t_diff)? t_diff : min_t_diff;
        half_t = min_t_diff/2; 
        valid = 1;
    end

endmodule