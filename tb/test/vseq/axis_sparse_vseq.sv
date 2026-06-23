//==============================================================================
// axis_sparse_vseq.sv
// Sparse stream: data + scattered null bytes, against random backpressure.
//==============================================================================
`ifndef AXIS_SPARSE_VSEQ_SV
`define AXIS_SPARSE_VSEQ_SV

class axis_sparse_vseq extends axis_base_vseq;
    `uvm_object_utils(axis_sparse_vseq)

    rand int unsigned num_packets;
    constraint c_n { num_packets inside {[1:3]}; }

    function new(string name = "axis_sparse_vseq");
        super.new(name);
    endfunction

    task body();
        axis_slave_random_ready_seq rdy = axis_slave_random_ready_seq::type_id::create("rdy");
        fork
            begin : RESP rdy.start(p_sequencer.slv_sqr); end
        join_none
        for (int i = 0; i < num_packets; i++) begin
            axis_master_sparse_seq s =
                axis_master_sparse_seq::type_id::create($sformatf("sparse_%0d", i));
            if (!s.randomize())
                `uvm_fatal(get_type_name(), "sparse randomize failed")
            s.start(p_sequencer.mst_sqr);
        end
        disable RESP;
    endtask
endclass

`endif // AXIS_SPARSE_VSEQ_SV
