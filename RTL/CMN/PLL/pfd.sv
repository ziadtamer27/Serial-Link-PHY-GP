module pfd(
    input fref,
    input fvco_N,
    output reg up,
    output reg dn
);
    wire rst;

    assign rst = up & dn;

    always @ (posedge fref or posedge rst) begin
        if (rst)
            up <= 0;
        else 
            up <= 1;
    end

    always @ (posedge fvco_N or posedge rst) begin
        if (rst)
            dn <= 0;
        else 
            dn <= 1;
    end
endmodule