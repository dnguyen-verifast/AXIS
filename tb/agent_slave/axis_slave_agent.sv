//==============================================================================
// axis_slave_agent.sv — Receiver agent: driver + sequencer + monitor.
//==============================================================================
`ifndef AXIS_SLAVE_AGENT_SV
`define AXIS_SLAVE_AGENT_SV

class axis_slave_agent extends uvm_agent;
    `uvm_component_utils(axis_slave_agent)

    axis_slave_cfg        cfg;

    axis_slave_sequencer  sqr;
    axis_slave_driver     drv;
    axis_slave_monitor    mon;

    uvm_analysis_port #(axis_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(axis_slave_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "slave cfg not set")

        uvm_config_db#(axis_slave_cfg)::set(this, "drv", "cfg", cfg);
        uvm_config_db#(virtual axi_stream_if)::set(this, "mon", "vif", cfg.vif);
        uvm_config_db#(int unsigned)::set(this, "mon", "num_bytes", cfg.num_bytes());

        mon = axis_slave_monitor::type_id::create("mon", this);

        if (cfg.is_active == UVM_ACTIVE) begin
            sqr = axis_slave_sequencer::type_id::create("sqr", this);
            sqr.cfg = cfg;
            drv = axis_slave_driver::type_id::create("drv", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
        if (cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass : axis_slave_agent

`endif // AXIS_SLAVE_AGENT_SV
