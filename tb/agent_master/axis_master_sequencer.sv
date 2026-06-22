//==============================================================================
// axis_master_sequencer.sv
//==============================================================================
`ifndef AXIS_MASTER_SEQUENCER_SV
`define AXIS_MASTER_SEQUENCER_SV

class axis_master_sequencer extends uvm_sequencer #(axis_seq_item);
    `uvm_component_utils(axis_master_sequencer)

    axis_master_cfg cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : axis_master_sequencer

`endif // AXIS_MASTER_SEQUENCER_SV
