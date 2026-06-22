//==============================================================================
// axis_slave_cfg.sv  — configuration for the slave (Receiver) VIP.
//==============================================================================
`ifndef AXIS_SLAVE_CFG_SV
`define AXIS_SLAVE_CFG_SV

class axis_slave_cfg extends uvm_object;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    int unsigned data_width = 32;
    int unsigned id_width   = 8;
    int unsigned dest_width = 8;
    int unsigned user_width = 8;

    // Default backpressure profile used by the built-in ready sequence:
    // probability (%) that TREADY is held LOW in a given span.
    int unsigned ready_low_pct = 30;

    virtual axi_stream_if vif;

    `uvm_object_utils_begin(axis_slave_cfg)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int(data_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(id_width,   UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(dest_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(user_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(ready_low_pct, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axis_slave_cfg");
        super.new(name);
    endfunction

    function int unsigned num_bytes();
        return data_width / 8;
    endfunction

endclass : axis_slave_cfg

`endif // AXIS_SLAVE_CFG_SV
