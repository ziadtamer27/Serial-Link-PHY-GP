class decoder_agent extends uvm_agent;

    `uvm_component_utils(decoder_agent)

    // Agent Components
    decoder_sequencer sequencer;
    decoder_driver    driver;
    decoder_monitor   monitor;

    // Agent Analysis Port
    uvm_analysis_port #(decoder_sequence_item) ap;


    // Constructor
    function new(string name = "decoder_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create analysis port
        ap = new("ap", this);

        // Monitor exists in both active and passive modes
        monitor = decoder_monitor::type_id::create(
            "monitor", this
        );

        // Driver and sequencer exist only in active mode
        if (get_is_active() == UVM_ACTIVE) begin

            sequencer = decoder_sequencer::type_id::create(
                "sequencer", this
            );

            driver = decoder_driver::type_id::create(
                "driver", this
            );

        end

    endfunction


    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Forward monitor transactions through agent
        monitor.ap.connect(ap);

        // Connect driver to sequencer in active mode
        if (get_is_active() == UVM_ACTIVE) begin

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass
