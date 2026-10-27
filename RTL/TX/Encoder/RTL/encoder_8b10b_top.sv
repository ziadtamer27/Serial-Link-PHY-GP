module encoder_8b10b_top #(
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       in_valid,
    input  logic [7:0] in_data,
    input  logic       in_is_k,
    output logic       out_valid,
    output logic [9:0] out_data,
    output logic       invalid_k,
    output logic       rd_positive
);
    logic rd_q;
    encoder_5b6b_if if5();
    encoder_3b4b_if if3();

    assign if5.in_valid = in_valid;
    assign if5.in_data  = in_data;
    assign if5.in_is_k  = in_is_k;
    assign if5.rd_in    = rd_q;
    encoder_5b6b_boolean u_5b6b(if5);

    assign if3.in_valid = if5.out_valid;
    assign if3.in_data  = in_data;
    assign if3.in_is_k  = in_is_k;
    assign if3.rd_mid   = if5.rd_mid;
    encoder_3b4b_boolean u_3b4b(if3);
    

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_q        <= 1'b0;  // initial RD-: chosen for repeatable tests
            out_data    <= 10'b0;
            out_valid   <= 1'b0;
            invalid_k   <= 1'b0;
        end else begin
            out_valid <= if3.out_valid;
            invalid_k <= if3.invalid_k;
            if (if3.out_valid) begin
                out_data <= {if5.code6, if3.code4};
                rd_q <= if3.rd_out;
            end
        end
    end
    assign rd_positive = rd_q;
endmodule