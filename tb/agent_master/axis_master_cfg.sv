//==============================================================================
// axis_master_cfg.sv  — configuration for the master (Transmitter) VIP.
//==============================================================================
`ifndef AXIS_MASTER_CFG_SV
`define AXIS_MASTER_CFG_SV

class axis_master_cfg extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    // Geometry (must match the interface params in tb_top).
    int unsigned data_width = 32;
    int unsigned id_width   = 8;
    int unsigned dest_width = 8;
    int unsigned user_width = 8;

    // Drive TWAKEUP one cycle ahead of TVALID (AXI5-Stream, recommended).
    bit          use_wakeup = 1;

    virtual axi_stream_if vif;

    `uvm_object_utils_begin(axis_master_cfg)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int(data_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(id_width,   UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(dest_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(user_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(use_wakeup, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axis_master_cfg");
        super.new(name);
    endfunction

    function int unsigned num_bytes();
        return data_width / 8;
    endfunction

endclass : axis_master_cfg

`endif // AXIS_MASTER_CFG_SV
