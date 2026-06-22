//==============================================================================
// axis_slave_random_ready_seq.sv
// Random backpressure — runs forever (a forever-responder). The virtual
// sequence forks this and kills it once master traffic completes.
//==============================================================================
`ifndef AXIS_SLAVE_RANDOM_READY_SEQ_SV
`define AXIS_SLAVE_RANDOM_READY_SEQ_SV

class axis_slave_random_ready_seq extends axis_slave_base_seq;
    `uvm_object_utils(axis_slave_random_ready_seq)

    function new(string name = "axis_slave_random_ready_seq");
        super.new(name);
    endfunction

    task body();
        forever begin
            req = axis_slave_ready_item::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {
                ready dist { 0 := ready_low_pct, 1 := (100 - ready_low_pct) };
            })
                `uvm_fatal(get_type_name(), "randomize failed")
            finish_item(req);
        end
    endtask
endclass

`endif // AXIS_SLAVE_RANDOM_READY_SEQ_SV
