//==============================================================================
// axis_master_packet_seq.sv
// A packet: N transfers sharing TID/TDEST, TLAST on the final transfer.
//==============================================================================
`ifndef AXIS_MASTER_PACKET_SEQ_SV
`define AXIS_MASTER_PACKET_SEQ_SV

class axis_master_packet_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_packet_seq)

    rand int unsigned len;
    rand int          pkt_id;
    rand int          pkt_dest;

    constraint c_len { len inside {[1:8]}; }
    constraint c_ids { pkt_id inside {[0:255]}; pkt_dest inside {[0:255]}; }

    function new(string name = "axis_master_packet_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i < len; i++) begin
            req = axis_seq_item::type_id::create("req");
            start_item(req);
            req.num_bytes = num_bytes;
            if (!req.randomize() with {
                id   == pkt_id;
                dest == pkt_dest;
                last == (i == (len - 1));
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_MASTER_PACKET_SEQ_SV
