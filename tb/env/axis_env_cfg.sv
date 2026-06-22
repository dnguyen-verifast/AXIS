//==============================================================================
// axis_env_cfg.sv — top-level env configuration (holds the two VIP cfgs).
//==============================================================================
`ifndef AXIS_ENV_CFG_SV
`define AXIS_ENV_CFG_SV

class axis_env_cfg extends uvm_object;
    `uvm_object_utils(axis_env_cfg)

    axis_master_cfg mst_cfg;
    axis_slave_cfg  slv_cfg;
    bit             enable_scoreboard = 1;

    function new(string name = "axis_env_cfg");
        super.new(name);
    endfunction
endclass : axis_env_cfg

`endif // AXIS_ENV_CFG_SV
