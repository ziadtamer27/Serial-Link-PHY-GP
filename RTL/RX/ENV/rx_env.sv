`ifndef ALU_ENV_SV
`define ALU_ENV_SV

package alu_env_pkg;

    import uvm_pkg::*;
    import alu_agent_pkg::*;
    import alu_scoreboard_pkg::*;
    import alu_coveragecollector_pkg::*;

    `include "uvm_macros.svh"

    class alu_env extends uvm_env;

        `uvm_component_utils(alu_env)

        alu_agent agent;
        alu_scoreboard scoreboard;
        alu_coveragecollector coveragecollector;

        function new(string name = "alu_env",
                     uvm_component parent = null);

            super.new(name, parent);

        endfunction


        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = alu_agent::type_id::create("agent", this);
            scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
            coveragecollector = alu_coveragecollector::type_id::create("coveragecollector", this);
        endfunction


        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.agt_ap.connect(scoreboard.sb_export);
            agent.agt_ap.connect(coveragecollector.cvr_export);
        endfunction
    endclass
endpackage
`endif