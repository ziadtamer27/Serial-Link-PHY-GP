module top( 
            input logic clk, 
            input real D_plus, 
            input real D_minus, 
            output logic recovered_clk, 
            output logic recovered_data
);

    real V_diff;

    diff_receiver diff_receiver_inst(.D_plus(D_plus), .D_minus(D_minus), .V_diff(V_diff));
    wrapper_CDR wrapper_CDR_inst(.clk(clk), .V_diff(V_diff), .recovered_clk(recovered_clk), .recovered_data(recovered_data));
    
endmodule