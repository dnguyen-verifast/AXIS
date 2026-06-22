//==============================================================================
// axis_slave_pkg.sv — Slave (Receiver) VIP package.
//==============================================================================
`ifndef AXIS_SLAVE_PKG_SV
`define AXIS_SLAVE_PKG_SV

package axis_slave_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axis_common_pkg::*;

    `include "axis_slave_ready_item.sv"
    `include "axis_slave_cfg.sv"
    `include "axis_slave_sequencer.sv"
    `include "axis_slave_driver.sv"
    `include "axis_slave_monitor.sv"
    `include "axis_slave_agent.sv"

    // Sequences (base first — derived sequences extend it).
    `include "axis_slave_base_seq.sv"
    `include "axis_slave_random_ready_seq.sv"
    `include "axis_slave_always_ready_seq.sv"

endpackage : axis_slave_pkg

`endif // AXIS_SLAVE_PKG_SV
