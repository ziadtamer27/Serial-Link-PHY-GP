`ifndef RX_OUTPUT_MONITOR_SV
`define RX_OUTPUT_MONITOR_SV

package rx_output_monitor_pkg;
    import uvm_pkg::*;
    import rx_config_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_output_monitor extends uvm_monitor;
        `uvm_component_utils(rx_output_monitor)
        rx_config cfg;
        virtual rx_if vif;
        rx_transaction trans;
        uvm_analysis_port #(rx_transaction) monitor_ap;


        function new(string name = "rx_output_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor_ap = new("mon_ap",this);
        endfunction

        task run_phase(uvm_phase phase);
            vif = cfg.get_vif();
            forever begin
                @(negedge vif.recovered_clk);

                if (vif.rst_n && vif.symbol_valid) begin

                    trans = rx_transaction::type_id::create("trans");

                    trans.parallel_data        = vif.parallel_data;
                    trans.symbol_valid         = vif.symbol_valid;
                    trans.recovered_symbol_clk = vif.recovered_symbol_clk;

                    monitor_ap.write(trans);

                end
            end
        endtask
    endclass
endpackage

`endif
