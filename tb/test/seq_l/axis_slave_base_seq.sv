//==============================================================================
// axis_slave_base_seq.sv — base TREADY backpressure sequence.
//==============================================================================
`ifndef AXIS_SLAVE_BASE_SEQ_SV
`define AXIS_SLAVE_BASE_SEQ_SV

class axis_slave_base_seq extends uvm_sequence #(axis_slave_ready_item);
    `uvm_object_utils(axis_slave_base_seq)

    int unsigned ready_low_pct = 30;

    function new(string name = "axis_slave_base_seq");
        super.new(name);
    endfunction

    virtual task pre_start();
        axis_slave_sequencer sqr;
        if ($cast(sqr, m_sequencer) && sqr.cfg != null)
            ready_low_pct = sqr.cfg.ready_low_pct;
    endtask
endclass

`endif // AXIS_SLAVE_BASE_SEQ_SV
