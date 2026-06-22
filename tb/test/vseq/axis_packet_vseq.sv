//==============================================================================
// axis_packet_vseq.sv
// Packet: many multi-transfer packets against random backpressure.
//==============================================================================
`ifndef AXIS_PACKET_VSEQ_SV
`define AXIS_PACKET_VSEQ_SV

class axis_packet_vseq extends axis_base_vseq;
    `uvm_object_utils(axis_packet_vseq)

    rand int unsigned num_packets;
    constraint c_n { num_packets inside {[5:20]}; }

    function new(string name = "axis_packet_vseq");
        super.new(name);
    endfunction

    task body();
        axis_slave_random_ready_seq rdy = axis_slave_random_ready_seq::type_id::create("rdy");
        fork
            begin : RESP rdy.start(p_sequencer.slv_sqr); end
        join_none
        for (int i = 0; i < num_packets; i++) begin
            axis_master_packet_seq pkt =
                axis_master_packet_seq::type_id::create($sformatf("pkt_%0d", i));
            if (!pkt.randomize())
                `uvm_fatal(get_type_name(), "packet randomize failed")
            pkt.start(p_sequencer.mst_sqr);
        end
        disable RESP;
    endtask
endclass

`endif // AXIS_PACKET_VSEQ_SV
