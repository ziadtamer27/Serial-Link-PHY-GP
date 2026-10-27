package encoder_test_pkg;
    timeunit 1ns;
    timeprecision 1ps;
    import uvm_pkg::*;
    import pack::*;
    `include "uvm_macros.svh"

    // Include the shared base before its derived tests.
    `include "encoder_base_test.svh"
    `include "encoder_exhaustive_test.svh"
    `include "encoder_regression_test.svh"
endpackage
