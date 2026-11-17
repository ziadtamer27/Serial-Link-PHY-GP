`ifndef RX_DRIVER_SV
`define RX_DRIVER_SV

package rx_driver_pkg;
    import uvm_pkg::*;
    import rx_config_pkg::*;
    import rx_transaction_pkg::*;
    `include "uvm_macros.svh"

    class rx_driver extends uvm_driver #(rx_transaction);
        `uvm_component_utils(rx_driver)
        rx_config cfg;
        virtual rx_if vif;
        function new(string name = "rx_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            rx_transaction tr;
            vif = cfg.get_vif();
            forever begin
                @(posedge vif.clk);
                seq_item_port.get_next_item(tr);
                vif.D_plus <= tr.D_plus;
                vif.D_minus <= tr.D_minus;
                vif.rst_n <= tr.rst_n;
                vif.Rx_Polarity <= tr.Rx_Polarity;
                seq_item_port.item_done();
            end
        endtask
    endclass
endpackage

`endif