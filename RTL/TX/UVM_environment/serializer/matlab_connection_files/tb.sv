`timescale 1ns/1ps

module tb;

  // 1. Import the C/MATLAB bridge via DPI-C
  import "DPI-C" function void get_differential_out(
      input  bit   bit_val,
      output real  tx_p,
      output real  tx_n,
      output real  v_diff
  );
  import "DPI-C" function void close_matlab();

  // 2. Signals
  logic in_sig;
  logic out_sig;

  real tx_p;
  real tx_n;
  real v_diff;

  // 3. Instantiate DUT (NOT Gate)
  not_gate dut (
      .in  (in_sig),
      .out (out_sig)
  );

  // Helper function for floating point comparison with tolerance
  function automatic bit is_close(real a, real b, real tol = 0.001);
    real diff;
    diff = (a > b) ? (a - b) : (b - a);
    return (diff <= tol);
  endfunction

  // Test bit pattern: a stream of 8 bits to demonstrate differential waveforms
  logic test_pattern [8] = '{1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1};

  // 4. Testbench execution
  initial begin
    $display("==========================================================");
    $display("[TB] STARTING SYSTEMVERILOG <-> MATLAB DPI-C CO-SIMULATION");
    $display("==========================================================");

    for (int i = 0; i < 8; i++) begin
      real exp_tx_p, exp_tx_n, exp_v_diff;

      in_sig = test_pattern[i];
      #10; // Wait for logic propagation

      // Expected values based on NOT gate: out = ~in
      if (out_sig == 1'b1) begin
        exp_tx_p   = 1.4;
        exp_tx_n   = 1.0;
        exp_v_diff = 0.4;
      end else begin
        exp_tx_p   = 1.0;
        exp_tx_n   = 1.4;
        exp_v_diff = -0.4;
      end

      $display("\n--- [BIT %0d] in_sig = %b => out_sig = %b ---", i, in_sig, out_sig);

      // Digital Assertion
      assert (out_sig === ~in_sig)
        $display("[SV-ASSERTION PASSED] Digital: NOT gate output is correct (%b)", out_sig);
      else
        $error("[SV-ASSERTION FAILED] Digital mismatch! Expected %b, got %b", ~in_sig, out_sig);

      // Send output bit to MATLAB to calculate & plot differential voltages
      get_differential_out(out_sig, tx_p, tx_n, v_diff);

      // Analog Assertions on MATLAB calculated values
      assert (is_close(tx_p, exp_tx_p))
        $display("[SV-ASSERTION PASSED] TX+ = %0.3f V (Expected: %0.3f V)", tx_p, exp_tx_p);
      else
        $error("[SV-ASSERTION FAILED] TX+ mismatch! Expected %0.3f V, got %0.3f V", exp_tx_p, tx_p);

      assert (is_close(tx_n, exp_tx_n))
        $display("[SV-ASSERTION PASSED] TX- = %0.3f V (Expected: %0.3f V)", tx_n, exp_tx_n);
      else
        $error("[SV-ASSERTION FAILED] TX- mismatch! Expected %0.3f V, got %0.3f V", exp_tx_n, tx_n);

      assert (is_close(v_diff, exp_v_diff))
        $display("[SV-ASSERTION PASSED] Vdiff = %0.3f V (Expected: %0.3f V)", v_diff, exp_v_diff);
      else
        $error("[SV-ASSERTION FAILED] Vdiff mismatch! Expected %0.3f V, got %0.3f V", exp_v_diff, v_diff);
    end

    // Signal MATLAB to keep window open and bring figure to front
    $display("\n[TB] Finalizing co-simulation...");
    close_matlab();

    $display("\n==========================================================");
    $display("   ALL 8 BITS TESTED & ALL ASSERTIONS PASSED!             ");
    $display("   MATLAB WINDOW REMAINS OPEN WITH LIVE WAVEFORM PLOTS!   ");
    $display("==========================================================\n");

    $finish;
  end

endmodule
