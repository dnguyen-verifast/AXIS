//==============================================================================
// axis_test_pkg.sv
//==============================================================================
`ifndef AXIS_TEST_PKG_SV
`define AXIS_TEST_PKG_SV

package axis_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axis_common_pkg::*;
    import axis_master_pkg::*;
    import axis_slave_pkg::*;
    import axis_env_pkg::*;

    // Tests (base first — derived tests extend it).
    `include "axis_base_test.sv"
    `include "axis_smoke_test.sv"
    `include "axis_packet_test.sv"
    `include "axis_continuous_test.sv"
    `include "axis_unaligned_test.sv"
    `include "axis_byte_stream_test.sv"
    `include "axis_aligned_test.sv"
    `include "axis_sparse_test.sv"
endpackage : axis_test_pkg

`endif // AXIS_TEST_PKG_SV
