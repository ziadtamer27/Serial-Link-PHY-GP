module wrapper_CDR(
        input logic clk, 
        input real V_diff, 
        output logic recovered_clk, 
        output logic recovered_data
);

    CRC crc_inst(.clk(clk), .V_diff(V_diff), .recovered_clk(recovered_clk));
    DRC drc_inst(.V_diff(V_diff), .recovered_clk(recovered_clk), .recovered_data(recovered_data));

endmodule