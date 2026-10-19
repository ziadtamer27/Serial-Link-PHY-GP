module encoder_5b6b_boolean (encoder_5b6b_if.DUT sif);
    logic A, B, C, D, E;
    logic a, b, c, d, e, i;
    logic [5:0] base6, selected6;
    logic k28, rd_sensitive, invert6;
    logic [2:0] ones6;

    assign {E, D, C, B, A} = sif.in_data[4:0];
    assign k28 = sif.in_is_k && (sif.in_data[4:0] == 5'd28);

    // Boolean SOP equations minimized from RD- column of Appendix A-1.

    assign a = (A & E) |
            (A & B & ~C) |
            (A & B & ~D) |
            (A & C & ~B) |
            (D & ~B & ~C) |
            (~A & ~B & ~D & ~E) |
            (~A & ~C & ~D & ~E);

    assign b = (A & B & ~C) |
            (A & B & ~D) |
            (A & B & ~E) |
            (B & C & ~A) |
            (D & ~A & ~C) |
            (E & ~A & ~C) |
            (A & ~C & ~D & ~E) |
            (C & ~A & ~D & ~E);

    assign c = (C & E) |
            (A & C & ~B) |
            (A & C & ~D) |
            (B & C & ~A) |
            (A & ~B & ~D & ~E) |
            (B & ~A & ~D & ~E) |
            (D & ~A & ~B & ~E) |
            (E & ~A & ~B & ~D);

    assign d = (A & D & ~C) |
            (A & D & ~E) |
            (B & D & ~A) |
            (C & D & ~B) |
            (~A & ~B & ~D & ~E) |
            (~A & ~C & ~D & ~E) |
            (~B & ~C & ~D & ~E);

    assign e = E |
            (A & B & C & D) |
            (~A & ~B & ~C & ~D);

    assign i = (A & B & C & D) |
            (~A & ~B & ~C) |
            (~A & ~B & ~D) |
            (~A & ~B & ~E) |
            (~A & ~C & ~D) |
            (~A & ~C & ~E) |
            (~A & ~D & ~E) |
            (~B & ~C & ~D) |
            (~B & ~C & ~E) |
            (~B & ~D & ~E) |
            (~C & ~D & ~E);


    assign base6 = {a, b, c, d, e, i};

    // x values whose RD+ 6b symbol is complement of RD- (including x=7,
    // whose 6b groups are neutral, but still have alternative encodings).

    assign rd_sensitive = (A & B & C) |
            (A & B & D & E) |
            (A & C & D & E) |
            (B & C & D & E) |
            (~A & ~B & ~C) |
            (~A & ~B & ~D & ~E) |
            (~A & ~C & ~D & ~E) |
            (~B & ~C & ~D & ~E);


    // K28.x differs from D28.x. K28 RD- = 001111; RD+ = 110000.
    assign invert6 = sif.rd_in && (rd_sensitive || k28);
    assign selected6 = (k28 ? 6'b001111 : base6) ^ {6{invert6}};

    assign sif.code6 = selected6;
    assign sif.out_valid = sif.in_valid;

    // Count ones to obtain the RD state after 6b.
    // Six-bit code disparity: 4 ones => RD+, 2 ones => RD-.
    // Three ones => hold incoming RD.
    assign ones6 = {2'b00, selected6[0]} + {2'b00, selected6[1]}
                 + {2'b00, selected6[2]} + {2'b00, selected6[3]}
                 + {2'b00, selected6[4]} + {2'b00, selected6[5]};
    assign sif.rd_mid = ones6 > 3 ? 1'b1 :
                        ones6 < 3 ? 1'b0 : sif.rd_in;
endmodule
