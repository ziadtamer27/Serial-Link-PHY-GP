package decoder_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "decoder_sequence_item.sv"

    `include "decoder_base_sequence.sv"
    `include "decoder_smoke_sequence.sv"
    `include "decoder_com_sequence.sv"
    `include "decoder_skp_sequence.sv"
    `include "decoder_exhaustive_sequence.sv"
    `include "decoder_random_legal_sequence.sv"
    `include "decoder_invalid_code_sequence.sv"
    `include "decoder_disparity_error_sequence.sv"
    `include "decoder_idle_sequence.sv"

    `include "decoder_sequencer.sv"
    `include "decoder_driver.sv"
    `include "decoder_monitor.sv"
    `include "decoder_agent.sv"

    `include "decoder_reference_model.sv"
    `include "decoder_scoreboard.sv"
    `include "decoder_coverage.sv"
    `include "decoder_env.sv"

    `include "decoder_base_test.sv"
    `include "decoder_smoke_test.sv"
    `include "decoder_com_test.sv"
    `include "decoder_skp_test.sv"
    `include "decoder_exhaustive_test.sv"
    `include "decoder_random_legal_test.sv"
    `include "decoder_invalid_code_test.sv"
    `include "decoder_disparity_error_test.sv"
    `include "decoder_idle_test.sv"
    `include "decoder_reset_test.sv"

endpackage
