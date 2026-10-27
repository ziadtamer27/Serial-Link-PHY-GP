class decoder_env extends uvm_env;

    `uvm_component_utils(decoder_env)

    // Environment Components
    decoder_agent      agent;
    decoder_scoreboard scoreboard;
    decoder_coverage   coverage;


    // Constructor
    function new(string name = "decoder_env",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create Agent
        agent = decoder_agent::type_id::create(
            "agent", this
        );

        // Create Scoreboard
        scoreboard = decoder_scoreboard::type_id::create(
            "scoreboard", this
        );

        // Create Coverage Collector
        coverage = decoder_coverage::type_id::create(
            "coverage", this
        );

    endfunction


    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect Agent Monitor to Scoreboard
        agent.ap.connect(scoreboard.analysis_export);

        // Connect Agent Monitor to Coverage
        agent.ap.connect(coverage.analysis_export);

    endfunction

endclass
