//==============================================================================
// axis_env_pkg.sv — top env: virtual sequencer, scoreboard, env, virtual seqs.
//==============================================================================
`ifndef AXIS_ENV_PKG_SV
`define AXIS_ENV_PKG_SV

package axis_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axis_common_pkg::*;
    import axis_master_pkg::*;
    import axis_slave_pkg::*;

    `include "axis_virtual_sequencer.sv"
    `include "axis_scoreboard.sv"
    `include "axis_env_cfg.sv"
    `include "axis_env.sv"

    // Virtual sequences (base first — derived classes extend it).
    `include "axis_base_vseq.sv"
    `include "axis_smoke_vseq.sv"
    `include "axis_packet_vseq.sv"
    `include "axis_continuous_vseq.sv"
    `include "axis_unaligned_vseq.sv"
    `include "axis_byte_stream_vseq.sv"
    `include "axis_aligned_vseq.sv"
    `include "axis_sparse_vseq.sv"

endpackage : axis_env_pkg

`endif // AXIS_ENV_PKG_SV
