
interface encoder_5b6b_if;

    logic       in_valid;
    logic [7:0] in_data;
    logic       in_is_k;
    logic       rd_in;

    logic       out_valid;
    logic [5:0] code6;
    logic       rd_mid;

    modport DUT (
        input  in_valid,
        input  in_data,
        input  in_is_k,
        input  rd_in,

        output out_valid,
        output code6,
        output rd_mid
    );

endinterface
