class decoder_sequence_item extends uvm_sequence_item;

    // DUT Inputs
    rand bit        valid_in;
    rand bit [9:0]  code_in;

    // Reset status (monitor observation)
    logic           rst_n;
    bit             reset_event;

    // DUT Outputs
    logic           valid_out;
    logic [7:0]     data_out;
    logic           is_kcode;
    logic           RxDataK;
    logic           is_comma;
    logic           is_skip;
    logic           decode_error;
    logic           disparity_error;


    // UVM Factory Registration
    `uvm_object_utils(decoder_sequence_item)


    // Constructor
    function new(string name = "decoder_sequence_item");
        super.new(name);
    endfunction


    // Display Transaction Information
    function string convert2string();

        return $sformatf(
            {"rst_n=%b valid_in=%b code_in=%010b ",
             "valid_out=%b data_out=%02h ",
             "is_kcode=%b RxDataK=%b ",
             "is_comma=%b is_skip=%b ",
             "decode_error=%b disparity_error=%b"},

            rst_n,
            valid_in,
            code_in,
            valid_out,
            data_out,
            is_kcode,
            RxDataK,
            is_comma,
            is_skip,
            decode_error,
            disparity_error
        );

    endfunction

endclass
