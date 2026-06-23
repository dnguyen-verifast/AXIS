//==============================================================================
// axis_master_sparse_seq.sv
// Sparse stream (ARM IHI 0051 §2.1): DATA bytes {1,1} and NULL bytes {0,0} may
// appear in any lane (null bytes scattered anywhere, not just lead/trail). Each
// lane is therefore either data or null (TKEEP==TSTRB); at least one data byte
// per beat keeps every transfer meaningful.
//==============================================================================
`ifndef AXIS_MASTER_SPARSE_SEQ_SV
`define AXIS_MASTER_SPARSE_SEQ_SV

class axis_master_sparse_seq extends axis_master_base_seq;
    `uvm_object_utils(axis_master_sparse_seq)

    rand int unsigned len;     // number of beats/transfers
    rand bit sparse_byte;
    constraint c_len { len inside {[64:127]}; }

    function new(string name = "axis_master_sparse_seq");
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
                valid_delay == 0;
                foreach (keep[j]) {
                    keep[j] == 1'b1;
                }
                (strb.sum() with (int'(item))) <= num_bytes; 
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_MASTER_SPARSE_SEQ_SV
