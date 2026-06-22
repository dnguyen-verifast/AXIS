//==============================================================================
// axis_base_vseq.sv
// Base virtual sequence — gives access to the virtual sequencer's sub-handles.
//==============================================================================
`ifndef AXIS_BASE_VSEQ_SV
`define AXIS_BASE_VSEQ_SV

class axis_base_vseq extends uvm_sequence;
    `uvm_object_utils(axis_base_vseq)
    `uvm_declare_p_sequencer(axis_virtual_sequencer)

    function new(string name = "axis_base_vseq");
        super.new(name);
    endfunction
endclass

`endif // AXIS_BASE_VSEQ_SV
