`ifndef ENCODER_DRIVER_SV
`define ENCODER_DRIVER_SV
class encoder_driver extends uvm_driver #(encoder_seq_item);
    `uvm_component_utils(encoder_driver)
    encoder_config_obj cfg;
    virtual encoder_if vif;
    function new(string name = "encoder_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(encoder_config_obj)::get(this, "", "cfg", cfg))
            `uvm_fatal("ENC_CFG", "Driver configuration is missing")
        vif = cfg.get_vif();
    endfunction
    task run_phase(uvm_phase phase);
        encoder_seq_item tr;
        forever begin
            // Inputs settle half a clock before the DUT samples them.
            @(negedge vif.clk);
            seq_item_port.try_next_item(tr);
            if (tr == null) begin
                vif.rst_n = 1'b1;
                vif.in_valid = 1'b0;
                vif.in_data = '0;
                vif.in_is_k = 1'b0;
            end else begin
                vif.rst_n = tr.rst_n;
                vif.in_valid = tr.in_valid;
                vif.in_data = tr.in_data;
                vif.in_is_k = tr.in_is_k;
                @(posedge vif.clk);
                #1ns;
                seq_item_port.item_done();
            end
        end
    endtask
endclass
`endif