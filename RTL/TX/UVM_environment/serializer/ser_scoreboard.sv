package ser_scoreboard;
import uvm_pkg::*;
import ser_seq_item::*;
`include "uvm_macros.svh"

class ser_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ser_scoreboard);

    uvm_analysis_export#(ser_seq_item) sb_export;
    uvm_tlm_analysis_fifo#(ser_seq_item) sb_fifo;
    ser_seq_item sb_seq_item;

    int correct_count, error_count;
    int bit_count;
    logic [9:0] expected_data;

    function new(string name="ser_scoreboard",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export",this);
        sb_fifo = new("sb_fifo",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        bit_count = 0;
        expected_data = 0;

        forever begin
            sb_fifo.get(sb_seq_item);

            if(!sb_seq_item.rst_n) begin
                bit_count = 0;
                expected_data = 0;
            end
            else begin
                if(bit_count == 0)
                    expected_data = sb_seq_item.parallel_data;

                if(sb_seq_item.serial_out === expected_data[bit_count]) begin
                    correct_count++;
                    `uvm_info("SER_SCOREBOARD",
                    $sformatf("PASS: bit_count=%0d expected=%0b actual=%0b",
                    bit_count,expected_data[bit_count],sb_seq_item.serial_out),UVM_MEDIUM)
                end
                else begin
                    error_count++;
                    `uvm_error("SER_SCOREBOARD",
                    $sformatf("FAIL: bit_count=%0d expected=%0b actual=%0b",
                    bit_count,expected_data[bit_count],sb_seq_item.serial_out))
                end

                if(bit_count == 9)
                    bit_count = 0;
                else
                    bit_count++;
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SER_SCOREBOARD",
        $sformatf("Correct bits = %0d, Error bits = %0d",
        correct_count,error_count),UVM_MEDIUM)

    endfunction

endclass
endpackage