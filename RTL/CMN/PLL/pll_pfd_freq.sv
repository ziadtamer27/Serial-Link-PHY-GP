module pll_pfd_freq (
    input  logic fref,
    input  logic rst_n,
    input  logic vco_clk,
    output wire  up,
    output wire  dn,
    output wire  fb_clk
);
    timeunit 1ps;
    timeprecision 1fs;

    freq_divider #(.N(10)) u_div (
        .vco_clk   (vco_clk),
        .rst_n     (rst_n),
        .vco_clk_N (fb_clk)
    );

    pfd u_pfd (
        .fref   (fref),
        .fvco_N (fb_clk),
        .up     (up),
        .dn     (dn)
    );
endmodule