module optional #(
    parameter int DATA_WIDTH = 16,
    localparam int NUM_BYTES = DATA_WIDTH / 8
)(
    input logic pclk,
    input logic symbol_clk,
    input logic rst_n,
    input logic enable,

    input logic [DATA_WIDTH-1:0] tx_data,
    input logic [NUM_BYTES-1:0] tx_data_k,

    output logic [7:0] data_out,
    output logic k_out,
    output logic valid_out
);

    logic [DATA_WIDTH-1:0] parallel_reg;
    logic [NUM_BYTES-1:0] parallel_k;
    logic word_ready;

    // Capture parallel data
    always_ff @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_reg <= '0;
            parallel_k   <= '0;
            word_ready   <= 1'b0;
        end
        else if (enable) begin
            parallel_reg <= tx_data;
            parallel_k   <= tx_data_k;
            word_ready   <= 1'b1;
        end
    end



    generate
        if (DATA_WIDTH == 8) begin : gen_8bit
            /*
            assign data_out  = parallel_reg;
            assign k_out     = parallel_k[0];
            assign valid_out = word_ready;
            */

            always_ff @(posedge symbol_clk or negedge rst_n) begin
                if (!rst_n) begin
                    data_out  <= '0;
                    k_out     <= 1'b0;
                    valid_out <= 1'b0;
                end
                else begin
                    data_out  <= parallel_reg;
                    k_out     <= parallel_k[0];
                    valid_out <= word_ready;
                end
            end

        end
        else begin : gen_wide

            logic [DATA_WIDTH-1:0] shift_reg;
            logic [NUM_BYTES-1:0] shift_k;

            logic [$clog2(NUM_BYTES)-1:0] count;
            logic active;

            always_ff @(posedge symbol_clk or negedge rst_n) begin
                if (!rst_n) begin
                    shift_reg <= '0;
                    shift_k   <= '0;
                    count     <= '0;
                    active    <= 1'b0;
                    data_out  <= '0;
                    k_out     <= 1'b0;
                    valid_out <= 1'b0;
                end
                else begin
                    valid_out <= 1'b0;

                    // Load word and transmit byte 0
                    if (!active && word_ready) begin
                        data_out  <= parallel_reg[7:0];
                        k_out     <= parallel_k[0];

                        shift_reg <= parallel_reg >> 8;
                        shift_k   <= parallel_k >> 1;

                        count     <= 1;
                        active    <= 1'b1;
                        valid_out <= 1'b1;
                    end

                    // Transmit remaining bytes
                    else if (active) begin
                        data_out  <= shift_reg[7:0];
                        k_out     <= shift_k[0];

                        shift_reg <= shift_reg >> 8;
                        shift_k   <= shift_k >> 1;

                        valid_out <= 1'b1;

                        if (count == NUM_BYTES-1) begin
                            count  <= '0;
                            active <= 1'b0;
                        end
                        else begin
                            count <= count + 1'b1;
                        end
                    end
                end
            end
        end
    endgenerate

endmodule