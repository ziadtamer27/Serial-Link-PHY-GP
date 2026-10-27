class decoder_monitor extends uvm_monitor;

    `uvm_component_utils(decoder_monitor)

    // Virtual Interface
    virtual usb_8b10b_decoder_if.MONITOR vif;

    // Analysis Port
    uvm_analysis_port #(decoder_sequence_item) ap;


    // Constructor
    function new(string name = "decoder_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(
            virtual usb_8b10b_decoder_if.MONITOR
        )::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON_NOVIF",
                       "Cannot get virtual interface")
        end

    endfunction


    // Run Phase
    task run_phase(uvm_phase phase);

        decoder_sequence_item tr;

        forever begin

            // Wait for monitor clocking event
            @(vif.mon_cb);

            // Create a new transaction
            tr = decoder_sequence_item::type_id::create("tr");

            // Sample DUT Inputs
            tr.rst_n    = vif.mon_cb.rst_n;
            tr.valid_in = vif.mon_cb.valid_in;
            tr.code_in  = vif.mon_cb.code_in;

            // Sample DUT Outputs
            tr.valid_out       = vif.mon_cb.valid_out;
            tr.data_out        = vif.mon_cb.data_out;
            tr.is_kcode        = vif.mon_cb.is_kcode;
            tr.RxDataK         = vif.mon_cb.RxDataK;
            tr.is_comma        = vif.mon_cb.is_comma;
            tr.is_skip         = vif.mon_cb.is_skip;
            tr.decode_error   = vif.mon_cb.decode_error;
            tr.disparity_error = vif.mon_cb.disparity_error;

            // Indicate a reset cycle
            tr.reset_event = (tr.rst_n === 1'b0);

            // Display transaction
            `uvm_info("DEC_MON",
                      tr.convert2string(),
                      UVM_HIGH)

            // Send transaction to subscribers
            ap.write(tr);

        end

    endtask

endclass
