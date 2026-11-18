`ifndef RX_ENV_SV
`define RX_ENV_SV

package rx_env_pkg;

    import uvm_pkg::*;
    import rx_agent_pkg::*;
    import rx_scoreboard_pkg::*;
    import rx_coveragecollector_pkg::*;

    `include "uvm_macros.svh"

    class rx_env extends uvm_env;

        `uvm_component_utils(rx_env)

        rx_agent agent;
        rx_scoreboard scoreboard;
        rx_coveragecollector coveragecollector;

        function new(string name = "rx_env",
                     uvm_component parent = null);

            super.new(name, parent);

        endfunction


        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = rx_agent::type_id::create("agent", this);
            scoreboard = rx_scoreboard::type_id::create("scoreboard", this);
            coveragecollector = rx_coveragecollector::type_id::create("coveragecollector", this);
        endfunction


        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.agt_ap.connect(coveragecollector.cvr_export);
            agent.input_ap.connect(scoreboard.input_fifo.analysis_export);
            agent.output_ap.connect(scoreboard.output_fifo.analysis_export);
        endfunction
    endclass
endpackage
`endif