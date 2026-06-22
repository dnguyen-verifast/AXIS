//==============================================================================
// axis_continuous_vseq.sv
// Continuous: back-to-back continuous packets against an eager Receiver
// (always-ready). Demonstrates max-throughput streaming.
//==============================================================================
`ifndef AXIS_CONTINUOUS_VSEQ_SV
`define AXIS_CONTINUOUS_VSEQ_SV

class axis_continuous_vseq extends axis_base_vseq;
    `uvm_object_utils(axis_continuous_vseq)

    rand int unsigned num_packets;
    constraint c_n { num_packets inside {[4:10]}; }

    function new(string name = "axis_continuous_vseq");
        super.new(name);
    endfunction

    task body();
        axis_slave_always_ready_seq rdy = axis_slave_always_ready_seq::type_id::create("rdy");
        fork
            begin : RESP rdy.start(p_sequencer.slv_sqr); end
        join_none
        for (int i = 0; i < num_packets; i++) begin
            axis_master_continuous_seq c =
                axis_master_continuous_seq::type_id::create($sformatf("cont_%0d", i));
            if (!c.randomize())
                `uvm_fatal(get_type_name(), "continuous randomize failed")
            c.start(p_sequencer.mst_sqr);
        end
        disable RESP;
    endtask
endclass

`endif // AXIS_CONTINUOUS_VSEQ_SV
