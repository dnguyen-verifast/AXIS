//==============================================================================
// axis_master_agent.sv — Transmitter agent: driver + sequencer + monitor.
//==============================================================================
`ifndef AXIS_MASTER_AGENT_SV
`define AXIS_MASTER_AGENT_SV

class axis_master_agent extends uvm_agent;
    `uvm_component_utils(axis_master_agent)

    axis_master_cfg        cfg;

    axis_master_sequencer  sqr;
    axis_master_driver     drv;
    axis_master_monitor    mon;

    uvm_analysis_port #(axis_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(axis_master_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "master cfg not set")

        // Feed children.
        uvm_config_db#(axis_master_cfg)::set(this, "drv", "cfg", cfg);
        uvm_config_db#(virtual axi_stream_if)::set(this, "mon", "vif", cfg.vif);
        uvm_config_db#(int unsigned)::set(this, "mon", "num_bytes", cfg.num_bytes());

        mon = axis_master_monitor::type_id::create("mon", this);

        if (cfg.is_active == UVM_ACTIVE) begin
            sqr = axis_master_sequencer::type_id::create("sqr", this);
            sqr.cfg = cfg;
            drv = axis_master_driver::type_id::create("drv", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
        if (cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass : axis_master_agent

`endif // AXIS_MASTER_AGENT_SV
