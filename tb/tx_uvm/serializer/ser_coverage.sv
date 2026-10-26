package ser_coverage;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ser_seq_item::*;

    class ser_coverage extends uvm_component;
        `uvm_component_utils(ser_coverage)

        uvm_analysis_export #(ser_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ser_seq_item) item_fifo;

        ser_seq_item item;

        covergroup ser_cg;
            cp_reset : coverpoint item.rst_n {
                bins reset  = {0};
                bins active = {1};
            }
            cp_parallel_data : coverpoint item.parallel_data {
                bins all_zero = {10'b0000000000};
                bins all_one  = {10'b1111111111};
                bins alternating_01 = {10'b0101010101};
                bins alternating_10 = {10'b1010101010};
                bins other = default;
            }
            cp_serial_out : coverpoint item.serial_out {
                bins zero = {0};
                bins one  = {1};
            }
            data_serial_cross : cross cp_parallel_data, cp_serial_out;
        endgroup

        function new(string name="ser_coverage",uvm_component parent=null);
            super.new(name,parent);
            ser_cg = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export",this);
            item_fifo = new("item_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(item_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                item_fifo.get(item);
                ser_cg.sample();
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("SER_COVERAGE",
                $sformatf("Functional coverage = %0.2f%%",
                          ser_cg.get_coverage()),
                UVM_MEDIUM)
        endfunction

    endclass
endpackage