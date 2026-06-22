//==============================================================================
// axis_env.sv
// Top environment: master VIP agent + slave VIP agent + scoreboard +
// virtual sequencer. Each agent is configured from its own cfg object carried
// inside the env cfg.
//==============================================================================
`ifndef AXIS_ENV_SV
`define AXIS_ENV_SV

class axis_env extends uvm_env;
    `uvm_component_utils(axis_env)

    axis_env_cfg            cfg;

    axis_master_agent       mst_agent;
    axis_slave_agent        slv_agent;
    axis_scoreboard         scbd;
    axis_virtual_sequencer  vseqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(axis_env_cfg)::get(this, "", "cfg", cfg))
            `uvm_fatal(get_type_name(), "env cfg not set")

        // Hand each agent its own config.
        uvm_config_db#(axis_master_cfg)::set(this, "mst_agent", "cfg", cfg.mst_cfg);
        uvm_config_db#(axis_slave_cfg)::set(this, "slv_agent", "cfg", cfg.slv_cfg);

        mst_agent = axis_master_agent::type_id::create("mst_agent", this);
        slv_agent = axis_slave_agent::type_id::create("slv_agent", this);

        vseqr = axis_virtual_sequencer::type_id::create("vseqr", this);

        if (cfg.enable_scoreboard)
            scbd = axis_scoreboard::type_id::create("scbd", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Virtual sequencer -> the two real sequencers.
        if (cfg.mst_cfg.is_active == UVM_ACTIVE)
            vseqr.mst_sqr = mst_agent.sqr;
        if (cfg.slv_cfg.is_active == UVM_ACTIVE)
            vseqr.slv_sqr = slv_agent.sqr;

        if (cfg.enable_scoreboard) begin
            mst_agent.ap.connect(scbd.mst_imp);
            slv_agent.ap.connect(scbd.slv_imp);
        end
    endfunction

endclass : axis_env

`endif // AXIS_ENV_SV
