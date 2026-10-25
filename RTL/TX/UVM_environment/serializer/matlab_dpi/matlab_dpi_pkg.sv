//==============================================================================
// Package: matlab_dpi_pkg
// Description: SystemVerilog DPI-C package interfacing with MATLAB function
// Generated from MATLAB function: matlab_func.m
//==============================================================================

`timescale 1ns / 1ns

package matlab_dpi_pkg;

    // Direct DPI-C imports generated from MATLAB
    import "DPI-C" function chandle DPI_matlab_func_initialize(input chandle existhandle);
    import "DPI-C" function chandle DPI_matlab_func_reset(input chandle objhandle, input int a, input int b, output int result);
    import "DPI-C" function void DPI_matlab_func(input chandle objhandle, input int a, input int b, output int result);
    import "DPI-C" function void DPI_matlab_func_terminate(input chandle existhandle);

    // Convenient wrapper function for direct use in UVM sequence / scoreboard / test
    function automatic int call_matlab_func(int a, int b);
        chandle h;
        int result;
        h = DPI_matlab_func_initialize(null);
        DPI_matlab_func(h, a, b, result);
        DPI_matlab_func_terminate(h);
        return result;
    endfunction

endpackage : matlab_dpi_pkg
