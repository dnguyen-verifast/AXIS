//==============================================================================
// axis_virtual_sequencer.sv
// Holds handles to the master and slave sequencers so a single virtual sequence
// can coordinate stimulus on both VIPs.
//==============================================================================
`ifndef AXIS_VIRTUAL_SEQUENCER_SV
`define AXIS_VIRTUAL_SEQUENCER_SV

class axis_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(axis_virtual_sequencer)

    axis_master_sequencer mst_sqr;
    axis_slave_sequencer  slv_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : axis_virtual_sequencer

`endif // AXIS_VIRTUAL_SEQUENCER_SV
