package ser_main_sequence;
`include "uvm_macros.svh"
import uvm_pkg::*;
import ser_seq_item::*;
class ser_main_sequence extends uvm_sequence #(ser_seq_item);
    `uvm_object_utils(ser_main_sequence);

    ser_seq_item seq_item;

    function new(string name="ser_main_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item = ser_seq_item::type_id::create("seq_item");
        repeat(10000) begin
            start_item(seq_item);
            assert(seq_item.randomize());
            finish_item(seq_item);
        end
    endtask
endclass

endpackage



/*
class Alu_Opcode_Seq extends uvm_sequence #(Alu_Seq_Item);
`uvm_object_utils(Alu_Opcode_Seq);

Alu_Seq_Item seq_item;

function new(string name="Alu_Opcode_Seq");
    super.new(name);
endfunction

task body();     

int opcodes[] = '{0,1,2,6,7,12,13,14,15};

foreach (opcodes[i]) begin
     seq_item = Alu_Seq_Item::type_id::create("seq_item");
    repeat(1000) begin
        start_item(seq_item);
        assert(seq_item.randomize() with {
            AluControlout_e == Alu_Seq_Item::Alu_Opcode_e'(opcodes[i]);
        });
        finish_item(seq_item);
    end
end
endtask
endclass

class Alu_Overflow_Seq extends uvm_sequence #(Alu_Seq_Item);
    `uvm_object_utils(Alu_Overflow_Seq)

    Alu_Seq_Item seq_item;

    function new(string name = "Alu_Overflow_Seq");
        super.new(name);
    endfunction

    task body();

        // ADD: positive + positive -> overflow
    seq_item = Alu_Seq_Item::type_id::create("seq_item");
        repeat(1000) begin
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == 2;
                A > 32'sd1073741823;
                B > 32'sd1073741823;
            });

            finish_item(seq_item);
        end

        // ADD: negative + negative -> overflow
        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        repeat(1000) begin;
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == 2;
                A < -32'sd1073741824;
                B < -32'sd1073741824;
            });

            finish_item(seq_item);
        end

        // SUB: positive - negative -> overflow
        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        repeat(1000) begin
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == 6;
                    A > 32'sd1073741823;
                    B < -32'sd1073741823;
            });

            finish_item(seq_item);
        end

        // SUB: negative - positive -> overflow
        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        repeat(1000) begin
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == 6;
               A < -32'sd1073741824;
               B > 32'sd1073741823;
            });

            finish_item(seq_item);
        end

    endtask


endclass

class Alu_slt_seq extends uvm_sequence #(Alu_Seq_Item);
    `uvm_object_utils(Alu_slt_seq)

    Alu_Seq_Item seq_item;

    function new(string name = "Alu_slt_seq");
        super.new(name);
    endfunction

    task body();

        // A < B
        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == Alu_Seq_Item::slt_op;
                A < B;
            });

            finish_item(seq_item);
        end

        // A > B
        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == Alu_Seq_Item::slt_op;
                A > B;
            });

            finish_item(seq_item);
        end

        // A == B
        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e == Alu_Seq_Item::slt_op;
                A == B;
            });

            finish_item(seq_item);
        end
        seq_item = Alu_Seq_Item::type_id::create("seq_item"); //corner case
        start_item(seq_item);
        seq_item.AluControlout_e=Alu_Seq_Item::slt_op;
        seq_item.A=-1;
        seq_item.B=1;
        seq_item.shift_amt=0;
        finish_item(seq_item);

        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.AluControlout_e=Alu_Seq_Item::slt_op;
        seq_item.A=1;
        seq_item.B=-1;
        seq_item.shift_amt=0;
        finish_item(seq_item);

        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.AluControlout_e=Alu_Seq_Item::slt_op;
        seq_item.A=32'h80000000;
        seq_item.B=32'h7fffffff;
        seq_item.shift_amt=0;
        finish_item(seq_item);

        
        seq_item = Alu_Seq_Item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.AluControlout_e=Alu_Seq_Item::slt_op;
        seq_item.A=32'h7fffffff;
        seq_item.B=32'h80000000;
        seq_item.shift_amt=0;
        finish_item(seq_item);


    endtask
endclass
class Alu_shift_seq extends uvm_sequence #(Alu_Seq_Item);
    `uvm_object_utils(Alu_shift_seq)

    Alu_Seq_Item seq_item;

    function new(string name = "Alu_shift_seq");
        super.new(name);
    endfunction

    task body();

        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e inside {Alu_Seq_Item::sll_op,Alu_Seq_Item::sra_op,Alu_Seq_Item::srl_op};
               shift_amt dist { 5'd0  := 20,
               5'd1  := 20,
               5'd2  := 20,
               5'd16 := 20,
               5'd31 := 20,
               [5'd3:5'd15] :/ 10,
               [5'd17:5'd30] :/ 10
    };
            });
            finish_item(seq_item);
        end

       repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                AluControlout_e inside {Alu_Seq_Item::sra_op};
                A<0;
                });

            finish_item(seq_item);
        end
    endtask
endclass

class Alu_corner_seq extends uvm_sequence #(Alu_Seq_Item);
    `uvm_object_utils(Alu_corner_seq)

    Alu_Seq_Item seq_item;

    function new(string name = "Alu_corner_seq");
        super.new(name);
    endfunction

    task body();

        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);

            assert(seq_item.randomize() with {
                A inside {0, 1, -1, 32'sh7FFFFFFF, -32'sh80000000};
                B inside {0, 1, -1, 32'sh7FFFFFFF, -32'sh80000000};
            AluControlout_e dist {Alu_Seq_Item::add_op:=40,Alu_Seq_Item::sub_op:=40,
            Alu_Seq_Item::and_op:=5,Alu_Seq_Item::or_op:=5,Alu_Seq_Item::nor_op:=5,
            Alu_Seq_Item::slt_op:=5,Alu_Seq_Item::sra_op:=5,Alu_Seq_Item::sll_op:=5,
            Alu_Seq_Item::srl_op:=5};});

            finish_item(seq_item);
        end

    endtask
endclass

class Alu_negative_seq extends uvm_sequence #(Alu_Seq_Item);
    `uvm_object_utils(Alu_negative_seq)

    Alu_Seq_Item seq_item;

    function new(string name = "Alu_negative_seq");
        super.new(name);
    endfunction

    task body();

        repeat(1000) begin
            seq_item = Alu_Seq_Item::type_id::create("seq_item");
            start_item(seq_item);
            seq_item.valid_opcode.constraint_mode(0);
            assert(seq_item.randomize() with {AluControlout_e inside {Alu_Seq_Item::unused_3,Alu_Seq_Item::unused_4, 
            Alu_Seq_Item::unused_5, Alu_Seq_Item::unused_8, Alu_Seq_Item::unused_9, Alu_Seq_Item::unused_10, Alu_Seq_Item::unused_11}; });
            finish_item(seq_item);
        end

    endtask
endclass

*/