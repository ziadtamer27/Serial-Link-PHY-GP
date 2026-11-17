`ifndef ALU_COVERAGECOLLECTOR_SV    
`define ALU_COVERAGECOLLECTOR_SV
package alu_coveragecollector_pkg;
import uvm_pkg::*;
import alu_transaction_pkg::*;
`include "uvm_macros.svh"
class alu_coveragecollector extends uvm_component;
    `uvm_component_utils(alu_coveragecollector)
    alu_transaction trans;
    uvm_analysis_export #(alu_transaction) cvr_export;
    uvm_tlm_analysis_fifo #(alu_transaction) cvr_fifo;
    covergroup cvr_grp;
        cp_aluControlOut : coverpoint trans.AluControlout{
            bins and_op = {4'b0000};
            bins or_op  = {4'b0001};
            bins add_op = {4'b0010};
            bins sub_op = {4'b0110};
            bins slt = {4'b0111};
            bins nor_op = {4'b1100};
            bins srl = {4'b1101};
            bins sra = {4'b1110};
            bins sll = {4'b1111};
            bins dont_care = default;        
        }

        cp_overflow_cp : coverpoint trans.overflow{
            bins overflow = {1'b1};
            bins no_overflow = {1'b0};
        }

        cp_shift_amt: coverpoint trans.shift_amt {
        bins no_shift = {0};
        bins small_val    = {[1:7]};
        bins medium_val   = {[8:15]};
        bins large_val    = {[16:31]};
        }

        cp_A_sign: coverpoint trans.A[31] {
        bins positive = {0};
        bins negative = {1};
        }

        cp_B_sign: coverpoint trans.B[31] {
        bins positive = {0};
        bins negative = {1};
        }

        cp_result_sign: coverpoint trans.Result[31] {
        bins positive = {0};
        bins negative = {1};
        }

        cp_result_zero: coverpoint trans.Result {
        bins zero     = {32'd0};
        bins non_zero = default;
        }

        cp_add_signs: cross cp_aluControlOut, cp_A_sign, cp_B_sign {
        bins ADD_PP = binsof(cp_aluControlOut.add_op) &&
                      binsof(cp_A_sign.positive) &&
                      binsof(cp_B_sign.positive);

        bins ADD_NN = binsof(cp_aluControlOut.add_op) &&
                      binsof(cp_A_sign.negative) &&
                      binsof(cp_B_sign.negative);

        bins ADD_PN = binsof(cp_aluControlOut.add_op) &&
                      binsof(cp_A_sign.positive) &&
                      binsof(cp_B_sign.negative);

        bins ADD_NP = binsof(cp_aluControlOut.add_op) &&
                      binsof(cp_A_sign.negative) &&
                      binsof(cp_B_sign.positive);
        }


        cp_sub_signs: cross cp_aluControlOut, cp_A_sign, cp_B_sign {
        bins SUB_PP = binsof(cp_aluControlOut.sub_op) &&
                      binsof(cp_A_sign.positive) &&
                      binsof(cp_B_sign.positive);

        bins SUB_NN = binsof(cp_aluControlOut.sub_op) &&
                      binsof(cp_A_sign.negative) &&
                      binsof(cp_B_sign.negative);

        bins SUB_PN = binsof(cp_aluControlOut.sub_op) &&
                      binsof(cp_A_sign.positive) &&
                      binsof(cp_B_sign.negative);

        bins SUB_NP = binsof(cp_aluControlOut.sub_op) &&
                      binsof(cp_A_sign.negative) &&
                      binsof(cp_B_sign.positive);
        }
    endgroup
    function new(string name = "alu_coveragecollector",uvm_component parent = null);
        super.new(name,parent);
        cvr_grp = new();
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cvr_export = new("cvr_export",this);
        cvr_fifo = new("cvr_fifo",this);
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cvr_export.connect(cvr_fifo.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cvr_fifo.get(trans);
            cvr_grp.sample();
        end
    endtask
endclass
endpackage
`endif