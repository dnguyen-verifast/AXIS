//==============================================================================
// axis_slave_sequencer.sv — runs the TREADY backpressure profile.
//==============================================================================
`ifndef AXIS_SLAVE_SEQUENCER_SV
`define AXIS_SLAVE_SEQUENCER_SV

class axis_slave_sequencer extends uvm_sequencer #(axis_slave_ready_item);
    `uvm_component_utils(axis_slave_sequencer)

    axis_slave_cfg cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : axis_slave_sequencer

`endif // AXIS_SLAVE_SEQUENCER_SV
