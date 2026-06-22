//==============================================================================
// axis_slave_ready_item.sv
// Control item for the slave (Receiver) driver: how to drive TREADY for a span
// of cycles. A stream of these defines the backpressure profile.
//==============================================================================
`ifndef AXIS_SLAVE_READY_ITEM_SV
`define AXIS_SLAVE_READY_ITEM_SV

class axis_slave_ready_item extends uvm_sequence_item;

    rand bit          ready;   // value to drive on TREADY
    rand int unsigned len;     // number of ACLK cycles to hold it

    `uvm_object_utils_begin(axis_slave_ready_item)
        `uvm_field_int(ready, UVM_ALL_ON)
        `uvm_field_int(len,   UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

    constraint c_len { len inside {[1:5]}; }

    function new(string name = "axis_slave_ready_item");
        super.new(name);
    endfunction
endclass : axis_slave_ready_item

`endif // AXIS_SLAVE_READY_ITEM_SV
