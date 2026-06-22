//==============================================================================
// axis_slave_driver.sv — Receiver driver. Drives TREADY according to the
// ready-control items it pulls from the slave sequencer.
//==============================================================================
`ifndef AXIS_SLAVE_DRIVER_SV
`define AXIS_SLAVE_DRIVER_SV

class axis_slave_driver extends uvm_driver #(axis_slave_ready_item);
    `uvm_component_utils(axis_slave_driver)

    virtual axi_stream_if vif;
    axis_slave_cfg        cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(axis_slave_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "slave cfg not set")
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        vif.TREADY <= 1'b0;
        @(posedge vif.ARESETn);
        @(vif.slv_cb);
        forever begin
            seq_item_port.get_next_item(req);
            drive_ready(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_ready(axis_slave_ready_item it);
        repeat (it.len) begin
            vif.slv_cb.TREADY <= it.ready;
            @(vif.slv_cb);
        end
    endtask

endclass : axis_slave_driver

`endif // AXIS_SLAVE_DRIVER_SV
