`ifndef RX_INPUT_MONITOR_SV
`define RX_INPUT_MONITOR_SV

package rx_input_monitor_pkg;
    import uvm_pkg::*;
    import rx_config_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_input_monitor extends uvm_monitor;
        `uvm_component_utils(rx_input_monitor)
        rx_config cfg;
        virtual rx_if vif;
        rx_transaction trans;
        uvm_analysis_port #(rx_transaction) monitor_ap;


        function new(string name = "rx_input_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            monitor_ap = new("mon_ap",this);
        endfunction

        task run_phase(uvm_phase phase);
            vif = cfg.get_vif();
            forever begin
                @(posedge vif.clk);
                trans = rx_transaction::type_id::create("trans");
                trans.D_plus = vif.D_plus;
                trans.D_minus = vif.D_minus;
                trans.rst_n = vif.rst_n;
                trans.Rx_Polarity = vif.Rx_Polarity;
                monitor_ap.write(trans);
            end
        endtask
    endclass
endpackage

`endif
