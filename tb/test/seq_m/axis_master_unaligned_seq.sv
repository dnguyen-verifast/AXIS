//==============================================================================
// axis_master_unaligned_seq.sv
// Continuous UNALIGNED stream (ARM IHI 0051 §2.1): contiguous data bytes that
// may start/end at any byte lane. The first beat has `lead` leading null bytes;
// the last beat has `trail` trailing null bytes; every other lane is data.
//
// Counted in BEATS (like axis_master_packet_seq / _continuous_seq) so it matches
// the item/driver model: one axis_seq_item == one beat == num_bytes lanes.
// `lead`/`trail` only shape the first/last beat — no cross-beat state needed.
//
//   W=4, len=3, lead=2, trail=3:
//     xfer0:  null null DATA DATA      (lead=2)
//     xfer1:  DATA DATA DATA DATA
//     xfer2:  DATA null null null      (trail=3, TLAST)
//==============================================================================
`ifndef AXIS_MASTER_UNALIGNED_SEQ_SV
`define AXIS_MASTER_UNALIGNED_SEQ_SV

class axis_master_unaligned_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_unaligned_seq)

    rand int unsigned len;    // number of beats/transfers (>=2)
    rand int unsigned lead;   // leading null bytes in the first beat
    rand int unsigned trail;  // trailing null bytes in the last beat

    constraint c_len   { len   inside {[128:255]}; }
    constraint c_lead  { lead  inside {[0:7]}; }
    constraint c_trail { trail inside {[0:7]}; }

    function new(string name = "axis_master_unaligned_seq");
        super.new(name);
    endfunction

    task body();
        int unsigned W  = num_bytes;     // bus byte-lanes (from cfg)
        int unsigned lp = lead  % W;     // clamp to a valid lane offset
        int unsigned tp = trail % W;
        int          pid = $urandom_range(0, 255);

        for (int unsigned t = 0; t < len; t++) begin
            // Each beat is independent: only the first/last beat is padded.
            int unsigned beat_lead  = (t == 0)       ? lp : 0;
            int unsigned beat_trail = (t == len - 1) ? tp : 0;

            axis_seq_item tr = axis_seq_item::type_id::create("tr");
            start_item(tr);
            tr.num_bytes   = W;
            tr.data        = new[W];
            tr.strb        = new[W];
            tr.keep        = new[W];
            tr.id          = pid;
            tr.dest        = 0;
            tr.user        = '0;
            tr.last        = (t == len - 1);
            tr.valid_delay = 0;          // continuous: back-to-back

            foreach (tr.data[lane]) begin
                bit is_null = (lane < beat_lead) || (lane >= W - beat_trail);
                tr.keep[lane] = 1'b1;          // null = {0,0}, data = {1,1}
                tr.strb[lane] = !is_null;
                tr.data[lane] = is_null ? '0 : $urandom;
            end

            finish_item(tr);
        end
    endtask
endclass

`endif // AXIS_MASTER_UNALIGNED_SEQ_SV
