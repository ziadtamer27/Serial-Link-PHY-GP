`timescale 1ps/1fs

module tb_pfd;

    logic fref = 1'b0;
    logic fvco = 1'b0;
    wire up;
    wire dn;

    real i_pump;
    real vctrl;

    pfd dut (
        .fref (fref),
        .fvco (fvco),
        .up   (up),
        .dn   (dn)
    );

    charge_pump #(
        .I_CP (100.0e-6)
    ) cp (
        .up     (up),
        .dn     (dn),
        .i_pump (i_pump)
    );

    loop_filter #(
        .C_FARADS (10.0e-12),
        .R_OHMS   (0.0),
        .V_INIT   (0.5)
    ) lf (
        .i_pump (i_pump),
        .vctrl  (vctrl)
    );

    initial begin
        // The PFD has no external reset. Pulse its internal reset at startup.
        force dut.rst = 1'b0;
        #1;
        force dut.rst = 1'b1;
        #1;
        release dut.rst;

        // Case 1: fref leads by 40 ps.
        #98 fref = 1'b1;                 // 100 ps
        #40 fvco = 1'b1;                 // 140 ps
        #60 {fref, fvco} = 2'b00;        // 200 ps

        // Case 2: fvco leads by 40 ps.
        #100 fvco = 1'b1;                // 300 ps
        #40  fref = 1'b1;                // 340 ps
        #60  {fref, fvco} = 2'b00;       // 400 ps

        // Case 3: both rising edges arrive together.
        #100 {fref, fvco} = 2'b11;       // 500 ps
        #100 {fref, fvco} = 2'b00;       // 600 ps

        #100 $finish;                    // 700 ps
    end

endmodule