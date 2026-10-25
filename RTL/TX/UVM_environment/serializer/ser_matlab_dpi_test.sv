//==============================================================================
// Test: ser_matlab_dpi_test
// Description: UVM test demonstrating and verifying MATLAB connection via DPI-C
//==============================================================================

package ser_matlab_dpi_test;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ser_test::*;
    import matlab_dpi_pkg::*;

    class ser_matlab_dpi_test extends ser_test;
        `uvm_component_utils(ser_matlab_dpi_test)

        function new(string name="ser_matlab_dpi_test", uvm_component parent=null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            int in_a = 20;
            int in_b = 30;
            int matlab_result;
            int expected_result;

            phase.raise_objection(this);

            `uvm_info("UVM_MATLAB_DPI", "==================================================================", UVM_NONE)
            `uvm_info("UVM_MATLAB_DPI", "[DPI-C TEST] Testing UVM <--> MATLAB connection using DPI-C...", UVM_NONE)
            `uvm_info("UVM_MATLAB_DPI", $sformatf("[DPI-C TEST] Calling MATLAB function matlab_func(a=%0d, b=%0d)...", in_a, in_b), UVM_NONE)

            // Direct call to MATLAB function through DPI-C wrapper
            matlab_result = call_matlab_func(in_a, in_b);
            expected_result = (in_a + in_b) * 2; // (20 + 30) * 2 = 100

            `uvm_info("UVM_MATLAB_DPI", $sformatf("[DPI-C TEST] Result returned from MATLAB: %0d (Expected: %0d)", matlab_result, expected_result), UVM_NONE)

            if (matlab_result == expected_result) begin
                `uvm_info("UVM_MATLAB_DPI", "[DPI-C TEST] >>> SUCCESS: MATLAB and UVM are connected and communicating via DPI-C! <<<", UVM_NONE)
            end else begin
                `uvm_error("UVM_MATLAB_DPI", $sformatf("[DPI-C TEST] >>> ERROR: Expected %0d but received %0d from MATLAB! <<<", expected_result, matlab_result))
            end
            `uvm_info("UVM_MATLAB_DPI", "==================================================================", UVM_NONE)

            phase.drop_objection(this);

            // Execute the standard serializer sequences as well
            super.run_phase(phase);
        endtask
    endclass
endpackage
