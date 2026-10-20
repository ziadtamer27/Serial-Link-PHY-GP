package ser_coverage;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import ser_seq_item::*;

    class ser_coverage extends uvm_component;
        `uvm_component_utils(ser_coverage)

        uvm_analysis_export #(ser_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ser_seq_item) item_fifo;

        ser_seq_item item;

        // Coverage implementation will be added later

        function new(string name="ser_coverage",uvm_component parent=null);
            super.new(name,parent);
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
            // Coverage sampling will be added later
        endtask

    endclass

endpackage