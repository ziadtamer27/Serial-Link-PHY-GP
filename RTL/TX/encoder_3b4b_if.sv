`timescale 1ns / 1ps
interface encoder_3b4b_if;
    logic       in_valid;
    logic [7:0] in_data;     // complete byte, for alternate .7 selection
    logic       in_is_k;
    logic       rd_mid;      // RD after the preceding 6-bit group
    logic       out_valid;
    logic [3:0] code4;       // fghj: [3] = f, [0] = j
    logic       rd_out;      // RD after the 4-bit group
    logic       invalid_k;   // unsupported K input (Appendix A-2)
    modport DUT (
        input  in_valid, in_data, in_is_k, rd_mid,
        output out_valid, code4, rd_out, invalid_k
    );
endinterface
