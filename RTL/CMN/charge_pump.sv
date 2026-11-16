module charge_pump #(parameter real I_CP = 100.0e-6)(
    input up,
    input dn,
    output real i_pump
);

    always_comb begin
        if(up & !dn)
            i_pump = I_CP;
        else if (dn & !up)
            i_pump = -I_CP;
        else 
            i_pump = 0.0;
    end
endmodule