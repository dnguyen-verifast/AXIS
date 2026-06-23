//==============================================================================
// axis_master_pkg.sv — Master (Transmitter) VIP package.
//==============================================================================
`ifndef AXIS_MASTER_PKG_SV
`define AXIS_MASTER_PKG_SV

package axis_master_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axis_common_pkg::*;

    `include "axis_master_cfg.sv"
    `include "axis_master_sequencer.sv"
    `include "axis_master_driver.sv"
    `include "axis_master_monitor.sv"
    `include "axis_master_agent.sv"

    // Sequences (base first — derived sequences extend it).
    `include "axis_master_base_seq.sv"
    `include "axis_master_single_seq.sv"
    `include "axis_master_packet_seq.sv"
    `include "axis_master_continuous_seq.sv"
    `include "axis_master_unaligned_seq.sv"
    `include "axis_master_byte_stream_seq.sv"
    `include "axis_master_aligned_seq.sv"
    `include "axis_master_sparse_seq.sv"

endpackage : axis_master_pkg

`endif // AXIS_MASTER_PKG_SV
