module loop_filter #(
    parameter real C_FARADS = 10.0e-12,
    parameter real R_OHMS   = 0.0,
    parameter real V_INIT   = 0.5
) (
    input real i_pump,
    output real vctrl
);

    timeunit 1ps;
    timeprecision 1fs;

    real v_cap        = V_INIT;
    real last_current = 0.0;
    realtime t1 = 0.0;
    real deltaT;

    always @(i_pump) begin
        deltaT = ($realtime - t1) * 1.0e-12;
        v_cap = v_cap + last_current * deltaT / C_FARADS;

        last_current = i_pump;
        t1 = $realtime;
    end

    assign vctrl = v_cap + i_pump * R_OHMS;

endmodule