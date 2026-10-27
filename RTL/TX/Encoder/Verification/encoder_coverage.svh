`ifndef ENCODER_COVERAGECOLLECTOR_SV
`define ENCODER_COVERAGECOLLECTOR_SV

// Coverage samples stimulus with its own expected running-disparity state.
class encoder_coverage extends uvm_component;
    `uvm_component_utils(encoder_coverage)

    uvm_analysis_export #(encoder_seq_item) cvr_export;
    uvm_tlm_analysis_fifo #(encoder_seq_item) cvr_fifo;
    encoder_reference_model model;
    bit require_full_coverage = 0;
    bit seen_data[2][256];
    bit seen_k[2][256];
    bit seen_invalid[2][256];
    int unsigned legal_count, invalid_count, reset_count, idle_count;
    int unsigned valid_streak, idle_streak;

    covergroup cvr_grp with function sample(
        bit reset_n, bit valid, bit is_k, bit legal, bit rd_in,
        bit rd_out, bit [7:0] data, int symbol_ones,
        int gap_length, int burst_length, bit alternate7
    );
        option.per_instance = 1;
        option.name = "encoder_functional_coverage";
        cp_reset: coverpoint reset_n {
            bins asserted = {0}; bins released = {1};
            bins recovery = (0 => 1); bins reassertion = (1 => 0);
        }
        cp_kind: coverpoint {valid, is_k, legal} iff (reset_n) {
            bins idle_data = {3'b001};
            bins idle_control = {3'b010, 3'b011};
            bins data = {3'b101};
            bins legal_k = {3'b111};
            bins invalid_k = {3'b110};
            ignore_bins impossible = {3'b000, 3'b100};
        }
        cp_data: coverpoint data iff (reset_n && valid && !is_k) {
            bins bytes[] = {[0:255]};
        }
        cp_data_rd: coverpoint rd_in iff (reset_n && valid && !is_k) {
            bins negative = {0}; bins positive = {1};
        }
        data_by_rd: cross cp_data, cp_data_rd iff (reset_n && valid && !is_k);
        cp_k: coverpoint data iff (reset_n && valid && is_k && legal) {
            bins k28_0 = {8'h1c}; bins k28_1 = {8'h3c};
            bins k28_2 = {8'h5c}; bins k28_3 = {8'h7c};
            bins k28_4 = {8'h9c}; bins k28_5 = {8'hbc};
            bins k28_6 = {8'hdc}; bins k28_7 = {8'hfc};
            bins k23_7 = {8'hf7}; bins k27_7 = {8'hfb};
            bins k29_7 = {8'hfd}; bins k30_7 = {8'hfe};
        }
        cp_k_rd: coverpoint rd_in iff (reset_n && valid && is_k && legal) {
            bins negative = {0}; bins positive = {1};
        }
        control_by_rd: cross cp_k, cp_k_rd iff (reset_n && valid && is_k && legal);
        cp_invalid: coverpoint data iff (reset_n && valid && is_k && !legal) {
            bins bytes[] = {[0:255]};
            ignore_bins legal_controls = {
                8'h1c, 8'h3c, 8'h5c, 8'h7c, 8'h9c, 8'hbc,
                8'hdc, 8'hfc, 8'hf7, 8'hfb, 8'hfd, 8'hfe
            };
        }
        cp_invalid_rd: coverpoint rd_in iff (reset_n && valid && is_k && !legal) {
            bins negative = {0}; bins positive = {1};
        }
        invalid_by_rd: cross cp_invalid, cp_invalid_rd iff (reset_n && valid && is_k && !legal);
        cp_rd_change: coverpoint {rd_in, rd_out} iff (reset_n && valid && legal) {
            bins neg_hold = {2'b00}; bins neg_to_pos = {2'b01};
            bins pos_to_neg = {2'b10}; bins pos_hold = {2'b11};
        }
        cp_disparity: coverpoint symbol_ones iff (reset_n && valid && legal) {
            bins negative = {4}; bins balanced = {5}; bins positive = {6};
        }
        cp_dot7_x: coverpoint data[4:0]
            iff (reset_n && valid && !is_k && data[7:5] == 7) {
            bins x[] = {[0:31]};
        }
        cp_dot7_rd: coverpoint rd_in
            iff (reset_n && valid && !is_k && data[7:5] == 7) {
            bins negative = {0}; bins positive = {1};
        }
        dot7_by_rd: cross cp_dot7_x, cp_dot7_rd iff (reset_n && valid && !is_k && data[7:5] == 7);
        cp_alternate7: coverpoint alternate7
            iff (reset_n && valid && !is_k && data[7:5] == 7) {
            bins primary = {0}; bins alternate = {1};
        }
        cp_gap: coverpoint gap_length iff (reset_n && valid) {
            bins none = {0}; bins one = {1};
            bins short_gap = {[2:4]}; bins long_gap = {[5:$]};
        }
        cp_burst: coverpoint burst_length iff (reset_n && valid && legal) {
            bins single = {1}; bins pair = {2};
            bins short_burst = {[3:8]}; bins sustained = {[9:$]};
        }
        cp_reset_rd: coverpoint rd_in iff (!reset_n) {
            bins from_negative = {0}; bins from_positive = {1};
        }
        cp_reset_valid: coverpoint valid iff (!reset_n) {
            bins quiet = {0}; bins active = {1};
        }
    endgroup

    function new(string name = "encoder_coverage", uvm_component parent = null);
        super.new(name, parent);
        cvr_grp = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cvr_export = new("cvr_export", this);
        cvr_fifo = new("cvr_fifo", this);
        model = encoder_reference_model::type_id::create("model");
        void'(uvm_config_db#(bit)::get(this, "", "require_full_coverage", require_full_coverage));
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cvr_export.connect(cvr_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        encoder_seq_item tr;
        bit rd_before, legal, exp_valid, exp_invalid, exp_rd;
        logic [9:0] exp_data;
        forever begin
            cvr_fifo.get(tr);
            rd_before = model.rd;
            legal = !tr.in_is_k || encoder_reference_model::is_legal_k(tr.in_data);
            model.predict(tr, exp_valid, exp_data, exp_invalid, exp_rd);
            if (!tr.rst_n) begin
                reset_count++;
                valid_streak = 0;
            end else if (!tr.in_valid) begin
                idle_count++;
                idle_streak++;
                valid_streak = 0;
            end else if (legal) begin
                valid_streak++;
                if (!tr.in_is_k && !seen_data[rd_before][tr.in_data]) begin
                    seen_data[rd_before][tr.in_data] = 1;
                    legal_count++;
                end else if (tr.in_is_k && !seen_k[rd_before][tr.in_data]) begin
                    seen_k[rd_before][tr.in_data] = 1;
                    legal_count++;
                end
            end else begin
                valid_streak = 0;
                if (!seen_invalid[rd_before][tr.in_data]) begin
                    seen_invalid[rd_before][tr.in_data] = 1;
                    invalid_count++;
                end
            end
            cvr_grp.sample(tr.rst_n, tr.in_valid, tr.in_is_k, legal,
                rd_before, exp_rd, tr.in_data, $countones(exp_data),
                idle_streak, valid_streak,
                exp_data[3:0] inside {4'b0111, 4'b1000});
            if (!tr.rst_n || tr.in_valid) idle_streak = 0;
        end
    endtask

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (require_full_coverage && (legal_count != 536 || invalid_count != 488))
            `uvm_error("COVERAGE_INCOMPLETE", $sformatf(
                "Expected legal 536/536 and illegal 488/488 input/RD combinations; got %0d/536 and %0d/488",
                legal_count, invalid_count))
        if (cvr_fifo.used() != 0)
            `uvm_error("COVERAGE_PENDING", "Test ended before coverage FIFO drained")
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("ENCODER_COVERAGE", $sformatf(
            "Legal combinations %0d/536; illegal K combinations %0d/488; reset cycles %0d; idle cycles %0d; covergroup %.2f%%",
            legal_count, invalid_count, reset_count, idle_count, cvr_grp.get_inst_coverage()), UVM_LOW)
    endfunction
endclass
`endif

