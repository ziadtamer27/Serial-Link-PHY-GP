`ifndef ENCODER_SCOREBOARD_SV
`define ENCODER_SCOREBOARD_SV
class encoder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(encoder_scoreboard)
    uvm_analysis_export #(encoder_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(encoder_seq_item) sb_fifo;
    encoder_reference_model model;
    int unsigned correct_counter, error_counter;
    int unsigned reset_cycles, idle_cycles, encoded_symbols, rejected_symbols;

    function new(string name = "encoder_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export", this);
        sb_fifo = new("sb_fifo", this);
        model = encoder_reference_model::type_id::create("model");
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        encoder_seq_item tr;
        bit exp_valid, exp_invalid_k, exp_rd, rd_before;
        logic [9:0] exp_data;
        forever begin
            sb_fifo.get(tr);
            rd_before = model.rd;
            model.predict(tr, exp_valid, exp_data, exp_invalid_k, exp_rd);
            if (!tr.rst_n) reset_cycles++;
            else if (!tr.in_valid) idle_cycles++;
            else if (exp_invalid_k) rejected_symbols++;
            else encoded_symbols++;
            if ({tr.out_valid,tr.out_data,tr.invalid_k,tr.rd_positive} !==
                {exp_valid,exp_data,exp_invalid_k,exp_rd}) begin
                error_counter++;
                `uvm_error("ENC_MISMATCH", $sformatf(
                    "rst=%b valid=%b K=%b byte=%02h RDin=%b: expected valid/code/invalid/RD=%b/%03h/%b/%b got %b/%03h/%b/%b",
                    tr.rst_n,tr.in_valid,tr.in_is_k,tr.in_data,rd_before,
                    exp_valid,exp_data,exp_invalid_k,exp_rd,
                    tr.out_valid,tr.out_data,tr.invalid_k,tr.rd_positive))
            end else correct_counter++;
        end
    endtask


    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("ENC_SCOREBOARD", $sformatf(
            "matched=%0d mismatched=%0d encoded=%0d invalid=%0d idle=%0d reset=%0d",
            correct_counter,error_counter,encoded_symbols,rejected_symbols,idle_cycles,reset_cycles), UVM_LOW)
    endfunction
    
endclass
`endif