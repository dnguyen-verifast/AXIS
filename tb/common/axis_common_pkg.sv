//==============================================================================
// axis_common_pkg.sv
// Shared types used by both the master and slave VIPs.
//==============================================================================
`ifndef AXIS_COMMON_PKG_SV
`define AXIS_COMMON_PKG_SV

package axis_common_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axis_seq_item.sv"

endpackage : axis_common_pkg

`endif // AXIS_COMMON_PKG_SV
