
interface scrambler_if(input logic clk);

    logic        rst_n;
    logic        in_valid;
    logic [7:0]  in_data;
    logic        in_is_k;
    logic        training_seq;
    logic        disable_scrambling;

    logic        out_valid;
    logic [7:0]  out_data;
    logic        out_is_k;
    logic [15:0] lfsr_state;

    modport DUT (
        input  clk,
        input  rst_n,
        input  in_valid,
        input  in_data,
        input  in_is_k,
        input  training_seq,
        input  disable_scrambling,

        output out_valid,
        output out_data,
        output out_is_k,
        output lfsr_state
    );

endinterface
