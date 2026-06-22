//==============================================================================
// axis_base_test.sv
// Base test — constructs and configures the env (separate master/slave cfgs).
//==============================================================================
`ifndef AXIS_BASE_TEST_SV
`define AXIS_BASE_TEST_SV

class axis_base_test extends uvm_test;
    `uvm_component_utils(axis_base_test)

    axis_env     env;
    axis_env_cfg env_cfg;

    // Geometry — keep aligned with the interface params in tb_top.
    int unsigned data_width = 32;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        virtual axi_stream_if vif;
        super.build_phase(phase);

        if (!uvm_config_db#(virtual axi_stream_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "vif not set in config_db")

        env_cfg = axis_env_cfg::type_id::create("env_cfg");

        // ---- Master VIP config ----
        env_cfg.mst_cfg = axis_master_cfg::type_id::create("mst_cfg");
        env_cfg.mst_cfg.is_active  = UVM_ACTIVE;
        env_cfg.mst_cfg.data_width = data_width;
        env_cfg.mst_cfg.vif        = vif;

        // ---- Slave VIP config ----
        env_cfg.slv_cfg = axis_slave_cfg::type_id::create("slv_cfg");
        env_cfg.slv_cfg.is_active     = UVM_ACTIVE;
        env_cfg.slv_cfg.data_width    = data_width;
        env_cfg.slv_cfg.ready_low_pct = 30;
        env_cfg.slv_cfg.vif           = vif;

        configure(); // hook for derived tests to tweak cfg before build

        uvm_config_db#(axis_env_cfg)::set(this, "env", "cfg", env_cfg);
        env = axis_env::type_id::create("env", this);
    endfunction

    // Override in derived tests to adjust env_cfg before the env is built.
    virtual function void configure();
    endfunction

    task run_phase(uvm_phase phase);
        phase.phase_done.set_drain_time(this, 200ns);
    endtask
endclass

`endif // AXIS_BASE_TEST_SV
