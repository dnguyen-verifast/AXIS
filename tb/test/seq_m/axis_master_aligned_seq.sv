//==============================================================================
// axis_master_aligned_seq.sv
// Continuous ALIGNED stream (ARM IHI 0051 §2.1): every byte lane in every
// transfer is a DATA byte {TKEEP,TSTRB}={1,1}, back-to-back (no idle gaps).
// This is the canonical stream-type form; axis_master_continuous_seq drives the
// same pattern as a throughput demo.
//==============================================================================
`ifndef AXIS_MASTER_ALIGNED_SEQ_SV
`define AXIS_MASTER_ALIGNED_SEQ_SV

class axis_master_aligned_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_aligned_seq)

    rand int unsigned len;     // number of beats/transfers
    constraint c_len { len inside {[128:255]}; }

    function new(string name = "axis_master_aligned_seq");
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
                foreach (keep[j]) keep[j] == 1;   // all data bytes
                foreach (strb[j]) strb[j] == 1;
                valid_delay == 0;                 // continuous: back-to-back
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_MASTER_ALIGNED_SEQ_SV
