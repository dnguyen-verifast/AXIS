//==============================================================================
// axis_slave_always_ready_seq.sv
// Always-ready — TREADY tied HIGH (eager Receiver, max throughput).
//==============================================================================
`ifndef AXIS_SLAVE_ALWAYS_READY_SEQ_SV
`define AXIS_SLAVE_ALWAYS_READY_SEQ_SV

class axis_slave_always_ready_seq extends axis_slave_base_seq;
    `uvm_object_utils(axis_slave_always_ready_seq)

    function new(string name = "axis_slave_always_ready_seq");
        super.new(name);
    endfunction

    task body();
        forever begin
            req = axis_slave_ready_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with { ready == 1; len == 5; })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_SLAVE_ALWAYS_READY_SEQ_SV
