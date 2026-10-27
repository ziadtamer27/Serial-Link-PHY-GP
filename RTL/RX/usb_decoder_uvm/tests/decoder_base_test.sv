
class decoder_base_test extends uvm_test;

    `uvm_component_utils(decoder_base_test)

    // UVM Environment
    decoder_env env;

    // Virtual Interface for synchronization
    virtual usb_8b10b_decoder_if.MONITOR vif;


    // Constructor
    function new(string name = "decoder_base_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create Environment
        env = decoder_env::type_id::create("env", this);

        // Get Virtual Interface
        if (!uvm_config_db#(
            virtual usb_8b10b_decoder_if.MONITOR
        )::get(this, "", "vif", vif)) begin

            `uvm_fatal("TEST_NOVIF",
                "Cannot get virtual interface")

        end

    endfunction


    // Wait until reset is released
    virtual task wait_for_reset_release();

        wait (vif.rst_n === 1'b1);

        // Synchronize to a complete monitor clock event
        @(vif.mon_cb);

        `uvm_info("BASE_TEST",
                  "Reset released",
                  UVM_MEDIUM)

    endtask


    // Allow final transactions to reach the scoreboard
    virtual task wait_for_decoder_drain();

        // DUT captures a driven symbol at the next posedge.
        // Allow two monitor events after sequence completion.
        repeat (2)
            @(vif.mon_cb);

    endtask


endclass
