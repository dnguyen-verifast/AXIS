//==============================================================================
// axis_master_driver.sv — Transmitter driver. Drives TVALID + payload, honours
// TREADY backpressure from the slave VIP.
//==============================================================================
`ifndef AXIS_MASTER_DRIVER_SV
`define AXIS_MASTER_DRIVER_SV

class axis_master_driver extends uvm_driver #(axis_seq_item);
    `uvm_component_utils(axis_master_driver)

    virtual axi_stream_if vif;
    axis_master_cfg       cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(axis_master_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "master cfg not set")
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        drive_idle();
        @(posedge vif.ARESETn);
        @(vif.mst_cb);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    // ARM IHI 0051B 2.8.2: TVALID must be LOW during reset.
    task drive_idle();
        vif.TVALID  <= 1'b0;
        vif.TDATA   <= '0;
        vif.TSTRB   <= '0;
        vif.TKEEP   <= '0;
        vif.TLAST   <= 1'b0;
        vif.TID     <= '0;
        vif.TDEST   <= '0;
        vif.TUSER   <= '0;
        vif.TWAKEUP <= 1'b0;
    endtask

    task drive_transfer(axis_seq_item tr);
        if (cfg.use_wakeup) vif.mst_cb.TWAKEUP <= 1'b1;

        // Optional idle gap before presenting the transfer.
        repeat (tr.valid_delay) begin
            vif.mst_cb.TVALID <= 1'b0;
            @(vif.mst_cb);
        end

        // Present payload + assert TVALID.
        vif.mst_cb.TVALID <= 1'b1;
        vif.mst_cb.TLAST  <= tr.last;
        vif.mst_cb.TID    <= tr.id;
        vif.mst_cb.TDEST  <= tr.dest;
        vif.mst_cb.TUSER  <= tr.user;
        foreach (tr.data[i]) begin
            vif.mst_cb.TDATA[8*i +: 8] <= tr.data[i];
            vif.mst_cb.TSTRB[i]        <= tr.strb[i];
            vif.mst_cb.TKEEP[i]        <= tr.keep[i];
        end

        // Hold until the Receiver accepts (TREADY sampled high on a rising edge).
        do @(vif.mst_cb); while (!vif.mst_cb.TREADY);

        // Handshake done.
        vif.mst_cb.TVALID <= 1'b0;
    endtask

endclass : axis_master_driver

`endif // AXIS_MASTER_DRIVER_SV
