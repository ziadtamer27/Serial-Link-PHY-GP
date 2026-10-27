
module scrambler (scrambler_if.DUT sif);

    logic [15:0] lfsr_q;
    logic [7:0]  mask;
    logic        is_com;
    logic        is_skp;

    assign is_com = sif.in_is_k &&
                    (sif.in_data == 8'hBC);

    assign is_skp = sif.in_is_k &&
                    (sif.in_data == 8'h3C);

    assign mask = {
        lfsr_q[8],  lfsr_q[9],
        lfsr_q[10], lfsr_q[11],
        lfsr_q[12], lfsr_q[13],
        lfsr_q[14], lfsr_q[15]
    };

    function automatic logic [15:0] advance8(
        input logic [15:0] s
    );
        logic [15:0] n;

        n[0]  = s[8];
        n[1]  = s[9];
        n[2]  = s[10];
        n[3]  = s[11] ^ s[8];
        n[4]  = s[12] ^ s[9] ^ s[8];
        n[5]  = s[13] ^ s[10] ^ s[9] ^ s[8];
        n[6]  = s[14] ^ s[11] ^ s[10] ^ s[9];
        n[7]  = s[15] ^ s[12] ^ s[11] ^ s[10];
        n[8]  = s[0] ^ s[13] ^ s[12] ^ s[11];
        n[9]  = s[1] ^ s[14] ^ s[13] ^ s[12];
        n[10] = s[2] ^ s[15] ^ s[14] ^ s[13];
        n[11] = s[3] ^ s[15] ^ s[14];
        n[12] = s[4] ^ s[15];
        n[13] = s[5];
        n[14] = s[6];
        n[15] = s[7];

        return n;
    endfunction

    always_ff @(posedge sif.clk or negedge sif.rst_n) begin

        if (!sif.rst_n) begin
            lfsr_q       <= 16'hFFFF;
            sif.out_valid <= 1'b0;
            sif.out_data  <= 8'h00;
            sif.out_is_k  <= 1'b0;
        end

        else begin
            sif.out_valid <= sif.in_valid;

            if (sif.in_valid) begin

                sif.out_is_k <= sif.in_is_k;

                if (is_com) begin
                    sif.out_data <= sif.in_data;
                    lfsr_q      <= 16'hFFFF;
                end

                else if (is_skp) begin
                    sif.out_data <= sif.in_data;
                end

                else begin

                    if (!sif.in_is_k &&
                        !sif.training_seq &&
                        !sif.disable_scrambling)

                        sif.out_data <= sif.in_data ^ mask;

                    else
                        sif.out_data <= sif.in_data;

                    lfsr_q <= advance8(lfsr_q);

                end
            end
        end
    end

    assign sif.lfsr_state = lfsr_q;

endmodule
