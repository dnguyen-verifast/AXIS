//==============================================================================
// axis_master_single_seq.sv — one fully-random transfer.
//==============================================================================
`ifndef AXIS_MASTER_SINGLE_SEQ_SV
`define AXIS_MASTER_SINGLE_SEQ_SV

class axis_master_single_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_single_seq)

    function new(string name = "axis_master_single_seq");
        super.new(name);
    endfunction

    task body();
        req = axis_seq_item::type_id::create("req");
        start_item(req);
        req.num_bytes = num_bytes;
        if (!req.randomize())
            `uvm_fatal(get_type_name(), "randomize failed")
        finish_item(req);
    endtask
endclass

`endif // AXIS_MASTER_SINGLE_SEQ_SV
