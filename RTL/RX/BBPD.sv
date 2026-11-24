module BBPD(input logic clk,
    input logic rst_n,

    input logic D_prev,
    input logic P_sample,
    input logic D_curr,

    input logic sample_valid,

    output logic Early,
    output logic Late,

    output logic signed [1:0] phase_error,

    output logic valid );
    logic early0;
    logic late0;
    logic trans;
    logic signed [1:0] phase_error0;

    always@(*) begin
        trans = D_prev ^ D_curr;
        early0 = trans & (P_sample ^ D_curr);
        late0 = trans & (P_sample ^ D_prev);

        if (early0)
            phase_error0 = -2'sd1;

        else if (late0)
            phase_error0 = 2'sd1;

        else
            phase_error0 = 2'sd0;

    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

            Early       <= 1'b0;
            Late        <= 1'b0;
            phase_error <= 2'sd0;
            valid       <= 1'b0;

        end

        else begin

            valid <= sample_valid;

            if (sample_valid) begin

                Early       <= early0;
                Late        <= late0;
                phase_error <= error0;

            end

            else begin

                Early       <= 1'b0;
                Late        <= 1'b0;
                phase_error <= 2'sd0;

            end

        end

    end


endmodule