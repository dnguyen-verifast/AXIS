//==============================================================================
// axis_master_base_seq.sv
// Base — discovers byte width from the sequencer's cfg.
//==============================================================================
`ifndef AXIS_MASTER_BASE_SEQ_SV
`define AXIS_MASTER_BASE_SEQ_SV

class axis_master_base_seq extends uvm_sequence #(axis_seq_item);
    `uvm_object_utils(axis_master_base_seq)

    int unsigned num_bytes = 4;

    function new(string name = "axis_master_base_seq");
        super.new(name);
    endfunction

    virtual task pre_start();
        axis_master_sequencer sqr;
        if ($cast(sqr, m_sequencer) && sqr.cfg != null)
            num_bytes = sqr.cfg.num_bytes();
    endtask
endclass

`endif // AXIS_MASTER_BASE_SEQ_SV
