class decoder_random_legal_test extends decoder_base_test;

    `uvm_component_utils(decoder_random_legal_test)

    function new(string name = "decoder_random_legal_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        decoder_random_legal_sequence seq;

        phase.raise_objection(this);
        wait_for_reset_release();

        seq = decoder_random_legal_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        wait_for_decoder_drain();
        phase.drop_objection(this);
    endtask

endclass
