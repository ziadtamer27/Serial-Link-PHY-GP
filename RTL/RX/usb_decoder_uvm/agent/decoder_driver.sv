class decoder_driver extends uvm_driver #(decoder_sequence_item);

    `uvm_component_utils(decoder_driver)

    // Virtual Interface
    virtual usb_8b10b_decoder_if.DRIVER vif;


    // Constructor
    function new(string name = "decoder_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(
            virtual usb_8b10b_decoder_if.DRIVER
        )::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV_NOVIF",
                       "Cannot get virtual interface")
        end
    endfunction


    // Run Phase
    task run_phase(uvm_phase phase);

        decoder_sequence_item req;

        forever begin

            // Synchronize with the driver clocking block
            @(vif.drv_cb);

            // During reset, drive idle values
            if (vif.drv_cb.rst_n !== 1'b1) begin

                vif.drv_cb.valid_in <= 1'b0;
                vif.drv_cb.code_in  <= '0;

            end
            else begin

                req = null;

                // Check for an available transaction
                seq_item_port.try_next_item(req);

                if (req == null) begin

                    // No transaction: drive idle
                    vif.drv_cb.valid_in <= 1'b0;
                    vif.drv_cb.code_in  <= '0;

                end
                else begin

                    // Drive received transaction
                    vif.drv_cb.valid_in <= req.valid_in;
                    vif.drv_cb.code_in  <= req.code_in;

                    `uvm_info("DEC_DRV",
                        $sformatf(
                            "Driving: valid_in=%0b code_in=%010b",
                            req.valid_in,
                            req.code_in
                        ),
                        UVM_HIGH)

                    // Complete sequencer-driver handshake
                    seq_item_port.item_done();

                end

            end

        end

    endtask

endclass
