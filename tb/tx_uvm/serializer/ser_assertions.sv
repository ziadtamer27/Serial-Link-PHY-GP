
module ser_assertions (
    input logic       clk,
    input logic       rst_n,
    input logic [9:0] parallel_data,
    input logic       serial_out,
    input logic [9:0] shift_reg,
    input logic [3:0] count
);

    logic [9:0] captured_data;
    logic [3:0] bit_count;
    logic       active;

    // --------------------------------------------------
    // Reference model: one word every 10 clock cycles
    // --------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            captured_data <= '0;
            bit_count     <= 0;
            active        <= 0;
        end
        else if (!active) begin
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

    // --------------------------------------------------
    // 1. Serial output must match the expected bit
    // --------------------------------------------------
    property p_serial_output;
        @(posedge clk)
        disable iff (!rst_n)
        active |-> (serial_out == captured_data[bit_count]);
    endproperty

    a_serial_output:
        assert property (p_serial_output)
        else $error(
            "[SERIAL DATA] t=%0t bit=%0d expected=%b actual=%b",
            $time,
            $sampled(bit_count),
            $sampled(captured_data[bit_count]),
            $sampled(serial_out)
        );

    // --------------------------------------------------
    // 2. Serial output must not be X or Z
    // --------------------------------------------------
    property p_serial_known;
        @(posedge clk)
        disable iff (!rst_n)
        active |-> !$isunknown(serial_out);
    endproperty

    a_serial_known:
        assert property (p_serial_known)
        else $error(
            "[SERIAL UNKNOWN] t=%0t serial_out=%b",
            $time, $sampled(serial_out)
        );

    // --------------------------------------------------
    // 3. Counter starts a new word at zero, then becomes 1
    // --------------------------------------------------
    property p_counter_start;
        @(posedge clk)
        disable iff (!rst_n)
        (count == 0) |=> (count == 1);
    endproperty

    a_counter_start:
        assert property (p_counter_start)
        else $error(
            "[COUNTER START] t=%0t count=%0d",
            $time, $sampled(count)
        );

    // --------------------------------------------------
    // 4. Counter increments from 1 through 8
    // --------------------------------------------------
    property p_counter_increment;
        @(posedge clk)
        disable iff (!rst_n)
        (count inside {[1:8]})
        |=> (count == ($past(count) + 1'b1));
    endproperty

    a_counter_increment:
        assert property (p_counter_increment)
        else $error(
            "[COUNTER INCREMENT] t=%0t count=%0d",
            $time, $sampled(count)
        );

    // --------------------------------------------------
    // 5. Counter wraps from 9 to 0
    // --------------------------------------------------
    property p_counter_wrap;
        @(posedge clk)
        disable iff (!rst_n)
        (count == 9) |=> (count == 0);
    endproperty

    a_counter_wrap:
        assert property (p_counter_wrap)
        else $error(
            "[COUNTER WRAP] t=%0t count=%0d",
            $time, $sampled(count)
        );

    // --------------------------------------------------
    // 6. Load the parallel word when count is zero
    // --------------------------------------------------
    property p_shift_load;
        @(posedge clk)
        disable iff (!rst_n)
        (count == 0)
        |=> (shift_reg == $past(parallel_data));
    endproperty

    a_shift_load:
        assert property (p_shift_load)
        else $error(
            "[SHIFT LOAD] t=%0t shift_reg=%h",
            $time, $sampled(shift_reg)
        );

    // --------------------------------------------------
    // 7. Shift right on each subsequent serialization edge
    // --------------------------------------------------
    property p_shift_right;
        @(posedge clk)
        disable iff (!rst_n)
        (count inside {[1:9]})
        |=> (shift_reg == {1'b0, $past(shift_reg[9:1])});
    endproperty

    a_shift_right:
        assert property (p_shift_right)
        else $error(
            "[SHIFT RIGHT] t=%0t shift_reg=%h",
            $time, $sampled(shift_reg)
        );

    // --------------------------------------------------
    // 8. Parallel input must be known when captured
    // --------------------------------------------------
    property p_parallel_known;
        @(posedge clk)
        disable iff (!rst_n)
        (count == 0) |-> !$isunknown(parallel_data);
    endproperty

    a_parallel_known:
        assert property (p_parallel_known)
        else $error(
            "[PARALLEL INPUT UNKNOWN] t=%0t data=%b",
            $time, $sampled(parallel_data)
        );

    // --------------------------------------------------
    // 9. Asynchronous reset check
    // --------------------------------------------------
    
    always @(negedge rst_n) begin
        #1step;

        if (rst_n === 1'b0) begin
            assert (
                serial_out === 1'b0 &&
                count      === 4'd0 &&
                shift_reg  === 10'd0
            )
            else $error(
                "[ASYNC RESET] t=%0t rst_n=%b count=%h shift_reg=%h serial_out=%b",
                $time, rst_n, count, shift_reg, serial_out
            );
        end
    end
    

endmodule
