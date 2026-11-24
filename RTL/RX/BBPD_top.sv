`timescale 1ps/1fs

module BBPD_top (

    input logic rst_n,
    input logic clk0,
    input logic clk90,
    input logic clk180,
    input logic clk270,

    input logic P_even,
    input logic D_even,
    input logic P_odd,
    input logic D_odd,

    output logic Early_even,
    output logic Late_even,
    output logic signed [1:0] e_even,

    output logic Early_odd,
    output logic Late_odd,
    output logic signed [1:0] e_odd

);
    logic P_even_valid;
    logic D_even_valid;
    logic P_odd_valid;
    logic D_odd_valid;
    logic sample_valid_even;
    logic sample_valid_odd;
    logic even_valid;
    logic odd_valid;

    always_ff @(posedge clk0 or negedge rst_n) begin
        if (!rst_n)
            P_even_valid <= 1'b0;
        else
            P_even_valid <= 1'b1;
    end


    always_ff @(posedge clk90 or negedge rst_n) begin
        if (!rst_n)
            D_even_valid <= 1'b0;
        else
            D_even_valid <= 1'b1;
    end


    always_ff @(posedge clk180 or negedge rst_n) begin
        if (!rst_n)
            P_odd_valid <= 1'b0;
        else
            P_odd_valid <= 1'b1;
    end


    always_ff @(posedge clk270 or negedge rst_n) begin
        if (!rst_n)
            D_odd_valid <= 1'b0;
        else
            D_odd_valid <= 1'b1;
    end

    assign sample_valid_even = D_odd_valid & P_even_valid & D_even_valid;
    assign sample_valid_odd = D_even_valid & P_odd_valid & D_odd_valid;

    BBPD BBPD_EVEN (
        .clk          (clk180),
        .rst_n        (rst_n),
        .D_prev       (D_odd),
        .P_sample     (P_even),
        .D_curr       (D_even),
        .sample_valid (sample_valid_even),
        .Early        (Early_even),
        .Late         (Late_even),
        .phase_error  (e_even),
        .valid        (even_valid)
    );

    BBPD BBPD_ODD (
        .clk          (clk0),
        .rst_n        (rst_n),
        .D_prev       (D_even),
        .P_sample     (P_odd),
        .D_curr       (D_odd),
        .sample_valid (sample_valid_odd),
        .Early        (Early_odd),
        .Late         (Late_odd),
        .phase_error  (e_odd),
        .valid        (odd_valid)
    );

endmodule
