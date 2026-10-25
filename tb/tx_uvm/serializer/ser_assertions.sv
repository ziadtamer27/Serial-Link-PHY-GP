
module ser_assertions (
    input logic       clk,
    input logic       rst_n,
    input logic [9:0] parallel_data,
    input logic       serial_out
);

    logic [9:0] captured_data;
    logic [3:0] bit_count;
    logic       active;

    // Reference model: capture a new word every 10 cycles.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            captured_data <= '0;
            bit_count     <= 0;
            active        <= 0;
        end
        else begin
            if (!active) begin
                captured_data <= parallel_data;
                bit_count     <= 0;
                active        <= 1;
            end
            else if (bit_count == 9) begin
                captured_data <= parallel_data;
                bit_count     <= 0;
            end
            else begin
                bit_count <= bit_count + 1'b1;
            end
        end
    end

    // Check the currently expected bit.
    property p_serial_output;
        @(posedge clk)
        disable iff (!rst_n)
        active |-> (serial_out == captured_data[bit_count]);
    endproperty

    a_serial_output:
        assert property (p_serial_output)
        else begin
            $error(
                "[ASSERT FAIL] time=%0t bit_count=%0d expected=%0b actual=%0b",
                $time,
                $sampled(bit_count),
                $sampled(captured_data[bit_count]),
                $sampled(serial_out)
            );
        end
endmodule

