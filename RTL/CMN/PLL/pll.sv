module pll(
    input fref,
    input rst_n,
    output vco_clk
);
    wire up;
    wire dn;
    wire vco_clk;
    wire fb_clk;

    real i_pump;
    real vctrl;
    real vco_freq_hz;

    pfd pfd_inst (
        .fref (fref),
        .fvco_N (fb_clk),
        .up   (up),
        .dn   (dn)
    );

    charge_pump #(
        .I_CP (100.0e-6)
    ) cp_inst (
        .up     (up),
        .dn     (dn),
        .i_pump (i_pump)
    );

    loop_filter #(
        .C_FARADS (10.0e-12),
        .R_OHMS   (1000.0),
        .V_INIT   (0.5)
    ) lf_inst (
        .i_pump (i_pump),
        .vctrl  (vctrl)
    );

    vco #(
        .K     (50.0e6),
        .FBIAS (95.0e6),
        .VBIAS (0.5)
    ) vco_inst (
        .vctrl   (vctrl),
        .vco_clk (vco_clk),
        .fvco    (vco_freq_hz)
    );

    freq_divider #(
        .N (10)
    ) div_inst (
        .vco_clk   (vco_clk),
        .rst_n     (rst_n),
        .vco_clk_N (fb_clk)
    );
endmodule