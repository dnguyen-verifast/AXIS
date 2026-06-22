//==============================================================================
// axis_master_monitor.sv
// Passive monitor for the Master (Transmitter) side. Pulls the virtual
// interface and the byte-lane count from the config_db and samples every
// accepted transfer (TVALID && TREADY) into an analysis port.
//==============================================================================
`ifndef AXIS_MASTER_MONITOR_SV
`define AXIS_MASTER_MONITOR_SV

class axis_master_monitor extends uvm_monitor;
    `uvm_component_utils(axis_master_monitor)

    virtual axi_stream_if vif;
    int unsigned          num_bytes = 4;
    localparam string     SIDE      = "MST";

    uvm_analysis_port #(axis_seq_item) ap;

    int unsigned num_transfers;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_stream_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "vif not set for monitor")
        void'(uvm_config_db#(int unsigned)::get(this, "", "num_bytes", num_bytes));
    endfunction

    task run_phase(uvm_phase phase);
        @(posedge vif.ARESETn);
        forever begin
            @(vif.mon_cb);
            if (vif.ARESETn && vif.mon_cb.TVALID && vif.mon_cb.TREADY)
                sample_transfer();
        end
    endtask

    function void sample_transfer();
        axis_seq_item tr = axis_seq_item::type_id::create("mon_tr");
        tr.num_bytes = num_bytes;
        tr.data = new[num_bytes];
        tr.strb = new[num_bytes];
        tr.keep = new[num_bytes];
        foreach (tr.data[i]) begin
            tr.data[i] = vif.mon_cb.TDATA[8*i +: 8];
            tr.strb[i] = vif.mon_cb.TSTRB[i];
            tr.keep[i] = vif.mon_cb.TKEEP[i];
        end
        tr.last = vif.mon_cb.TLAST;
        tr.id   = vif.mon_cb.TID;
        tr.dest = vif.mon_cb.TDEST;
        tr.user = vif.mon_cb.TUSER;
        num_transfers++;
        `uvm_info(get_type_name(),
            $sformatf("[%s] xfer #%0d id=%0d dest=%0d last=%0b",
                      SIDE, num_transfers, tr.id, tr.dest, tr.last), UVM_HIGH)
        ap.write(tr);
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("[%s] observed %0d transfers", SIDE, num_transfers), UVM_LOW)
    endfunction

endclass : axis_master_monitor

`endif // AXIS_MASTER_MONITOR_SV
