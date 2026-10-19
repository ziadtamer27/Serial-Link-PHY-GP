module diff_reciever(
    input real D_plus,
    input real D_minus,
    
    output real V_diff;
);

assign V_diff = D_plus - D_minus;

endmodule