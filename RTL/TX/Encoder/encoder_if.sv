
interface encoder_if(input logic clk);

    logic       rst_n;

    // Input from scrambler
    logic       in_valid;
    logic [7:0] in_data;
    logic       in_is_k;

    // Encoder output
    logic       out_valid;
    logic [9:0] out_data;

    // Status
    logic       rd_positive;
    logic       invalid_k;

    modport DUT (
        input  clk,
        input  rst_n,
        input  in_valid,
        input  in_data,
        input  in_is_k,

        output out_valid,
        output out_data,
        output rd_positive,
        output invalid_k
    );

endinterface
