//==============================================================================
// axis_smoke_vseq.sv
// Smoke: a few random single transfers against random backpressure.
//==============================================================================
`ifndef AXIS_SMOKE_VSEQ_SV
`define AXIS_SMOKE_VSEQ_SV

class axis_smoke_vseq extends axis_base_vseq;
    `uvm_object_utils(axis_smoke_vseq)

    rand int unsigned num_xfers;
    constraint c_n { num_xfers inside {[5:15]}; }

    function new(string name = "axis_smoke_vseq");
        super.new(name);
    endfunction

    task body();
        axis_slave_random_ready_seq rdy = axis_slave_random_ready_seq::type_id::create("rdy");
        fork
            begin : RESP rdy.start(p_sequencer.slv_sqr); end
        join_none
        repeat (num_xfers) begin
            axis_master_single_seq s = axis_master_single_seq::type_id::create("s");
            s.start(p_sequencer.mst_sqr);
        end
        disable RESP;
    endtask
endclass

`endif // AXIS_SMOKE_VSEQ_SV
