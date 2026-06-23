//==============================================================================
// axis_unaligned_test.sv — continuous unaligned-stream packets.
//==============================================================================
`ifndef AXIS_UNALIGNED_TEST_SV
`define AXIS_UNALIGNED_TEST_SV

class axis_unaligned_test extends axis_base_test;
    `uvm_component_utils(axis_unaligned_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axis_unaligned_vseq vseq;
        super.run_phase(phase);
        phase.raise_objection(this);
        vseq = axis_unaligned_vseq::type_id::create("vseq");
        if (!vseq.randomize() with { num_packets == 2; })
            `uvm_fatal(get_type_name(), "vseq randomize failed")
        vseq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif // AXIS_UNALIGNED_TEST_SV
