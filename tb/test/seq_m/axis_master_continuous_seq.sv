//==============================================================================
// axis_master_continuous_seq.sv
// Continuous-packet style (ARM IHI 0051B 3.3): all data bytes, back-to-back.
//==============================================================================
`ifndef AXIS_MASTER_CONTINUOUS_SEQ_SV
`define AXIS_MASTER_CONTINUOUS_SEQ_SV

class axis_master_continuous_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_continuous_seq)

    rand int unsigned len;
    constraint c_len { len inside {[2:6]}; }

    function new(string name = "axis_master_continuous_seq");
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
                foreach (keep[j]) keep[j] == 1;
                foreach (strb[j]) strb[j] == 1;
                valid_delay == 0;
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_MASTER_CONTINUOUS_SEQ_SV
