//==============================================================================
// axis_cfg_pkg.sv
// Configuration enums for the AXI-Stream VIP. Pure type definitions (no UVM
// classes) so any package can import it cheaply. Naming follows the AMBA
// AXI-Stream Protocol Spec (ARM IHI 0051).
//==============================================================================
`ifndef AXIS_CFG_PKG_SV
`define AXIS_CFG_PKG_SV

package axis_cfg_pkg;

    //--------------------------------------------------------------------------
    // Stream type (IHI 0051 §2.1 "Stream types"). Describes how TDATA/TKEEP/
    // TSTRB are interpreted across a packet.
    //--------------------------------------------------------------------------
    typedef enum bit [2:0] {
        AXIS_BYTE_STREAM          = 3'b000, // bytes only, may span lanes freely
        AXIS_CONTINUOUS_ALIGNED   = 3'b001, // full lanes, packet-aligned
        AXIS_CONTINUOUS_UNALIGNED = 3'b010, // full lanes, leading/trailing nulls
        AXIS_SPARSE_STREAM        = 3'b011,  // position bytes interleaved (TSTRB=0)
        OPTIONAL_STREAM_TYPE      = 3'b100
    } axis_stream_type_e;

    //--------------------------------------------------------------------------
    // Per-byte qualifier, encoded as {TKEEP, TSTRB} (IHI 0051 Table 2-3).
    // {0,1} is reserved/illegal and intentionally omitted.
    //--------------------------------------------------------------------------
    typedef enum bit [1:0] {
        AXIS_BYTE_NULL     = 2'b00, // TKEEP=0, TSTRB=0 : null byte (no content)
        AXIS_BYTE_POSITION = 2'b10, // TKEEP=1, TSTRB=0 : position byte (no data)
        AXIS_BYTE_DATA     = 2'b11  // TKEEP=1, TSTRB=1 : valid data byte
    } axis_byte_qualifier_e;

    //--------------------------------------------------------------------------
    // Supported TDATA widths in bits. Value == width so it can be used directly.
    //--------------------------------------------------------------------------
    typedef enum int unsigned {
        AXIS_DW_8   = 8,
        AXIS_DW_16  = 16,
        AXIS_DW_32  = 32,
        AXIS_DW_64  = 64,
        AXIS_DW_128 = 128,
        AXIS_DW_256 = 256,
        AXIS_DW_512 = 512
    } axis_data_width_e;

    //--------------------------------------------------------------------------
    // Master (Transmitter) pacing of TVALID.
    //--------------------------------------------------------------------------
    typedef enum bit [1:0] {
        AXIS_VALID_BACK_TO_BACK, // assert TVALID every cycle (max throughput)
        AXIS_VALID_FIXED_DELAY,  // fixed idle gap before each transfer
        AXIS_VALID_RANDOM_DELAY  // random idle gap (default stress profile)
    } axis_valid_mode_e;

    //--------------------------------------------------------------------------
    // Slave (Receiver) TREADY backpressure profile.
    //--------------------------------------------------------------------------
    typedef enum bit [1:0] {
        AXIS_READY_ALWAYS,   // TREADY tied HIGH (eager receiver)
        AXIS_READY_RANDOM,   // random HIGH/LOW per ready_low_pct
        AXIS_READY_LAZY,     // mostly LOW (aggressive backpressure)
        AXIS_READY_TOGGLE    // deterministic alternating HIGH/LOW
    } axis_ready_mode_e;

    //--------------------------------------------------------------------------
    // Optional-signal usage. Lets a cfg express which sideband signals are
    // present/driven on the link.
    //--------------------------------------------------------------------------
    typedef enum bit [2:0] {
        AXIS_SIG_NONE   = 3'b000,
        AXIS_SIG_ID     = 3'b001, // TID
        AXIS_SIG_DEST   = 3'b010, // TDEST
        AXIS_SIG_USER   = 3'b100, // TUSER
        AXIS_SIG_ALL    = 3'b111  // TID + TDEST + TUSER
    } axis_optional_sig_e;

    //--------------------------------------------------------------------------
    // TWAKEUP behaviour (AXI5-Stream low-power signalling).
    //--------------------------------------------------------------------------
    typedef enum bit {
        AXIS_WAKEUP_DISABLED = 1'b0, // ignore TWAKEUP
        AXIS_WAKEUP_ENABLED  = 1'b1  // assert TWAKEUP one cycle ahead of TVALID
    } axis_wakeup_mode_e;

endpackage : axis_cfg_pkg

`endif // AXIS_CFG_PKG_SV
