//==============================================================================
// axis_master_byte_stream_seq.sv
// Byte stream (ARM IHI 0051 §2.1): the most general form. Every lane is kept
// (TKEEP=1, no null bytes), but a lane may be either a DATA byte {1,1} or a
// POSITION byte {1,0} (TSTRB low). Idle gaps between transfers are allowed.
//
// Per-lane independent -> a plain per-beat randomize is enough (no global state).
//==============================================================================
`ifndef AXIS_MASTER_BYTE_STREAM_SEQ_SV
`define AXIS_MASTER_BYTE_STREAM_SEQ_SV

class axis_master_byte_stream_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_byte_stream_seq)

    rand int unsigned len;     // number of beats/transfers
    constraint c_len { len inside {[2:6]}; }

    function new(string name = "axis_master_byte_stream_seq");
        super.new(name);
    endfunction

    task body();
        int pid = $urandom_range(0, 255);
        for (int i = 0; i < len; i++) begin
            req = axis_seq_item::type_id::create("req");
            start_item(req);
            req.num_bytes = num_bytes;
            if (!req.randomize() with {
                id   == pid;
                dest == 0;
                last == (i == (len - 1));
                foreach (data[j]) keep[j] == strb[j];   // no null bytes in a byte stream
                // strb left free: data {1,1} or position {1,0}
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_MASTER_BYTE_STREAM_SEQ_SV
