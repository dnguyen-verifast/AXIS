//==============================================================================
// axis_packet_test.sv
//==============================================================================
`ifndef AXIS_PACKET_TEST_SV
`define AXIS_PACKET_TEST_SV

class axis_packet_test extends axis_base_test;
    `uvm_component_utils(axis_packet_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axis_packet_vseq vseq;
        super.run_phase(phase);
        phase.raise_objection(this);
        vseq = axis_packet_vseq::type_id::create("vseq");
        if (!vseq.randomize() with { num_packets == 15; })
            `uvm_fatal(get_type_name(), "vseq randomize failed")
        vseq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif // AXIS_PACKET_TEST_SV
