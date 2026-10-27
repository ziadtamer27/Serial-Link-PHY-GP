class decoder_reset_test extends decoder_base_test;

    `uvm_component_utils(decoder_reset_test)

    virtual usb_8b10b_decoder_if reset_vif;

    function new(string name = "decoder_reset_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual usb_8b10b_decoder_if)::get(
            this, "", "reset_vif", reset_vif)) begin
            `uvm_fatal("RESET_NOVIF", "Cannot get reset interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
        decoder_smoke_sequence seq;

        phase.raise_objection(this);
        wait_for_reset_release();

        seq = decoder_smoke_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        wait_for_decoder_drain();

        // Assert reset between clock edges after normal decoder activity.
        @(negedge reset_vif.clk);
        reset_vif.rst_n = 1'b0;
        repeat (3) @(negedge reset_vif.clk);
        reset_vif.rst_n = 1'b1;

        // Both the DUT and stimulus model restart with negative RD.
        seq.reset_rd_model();
        wait_for_reset_release();
        seq.start(env.agent.sequencer);

        wait_for_decoder_drain();
        phase.drop_objection(this);
    endtask

endclass
