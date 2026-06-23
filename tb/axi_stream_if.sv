//==============================================================================
// axi_stream_if.sv
// AMBA AXI-Stream interface (ARM IHI 0051B). Used by master/slave VIP agents.
//==============================================================================
`ifndef AXI_STREAM_IF_SV
`define AXI_STREAM_IF_SV

interface axi_stream_if #(
    parameter int DATA_WIDTH = 32,            // TDATA width in bits (integer # of bytes)
    parameter int ID_WIDTH   = 8,
    parameter int DEST_WIDTH = 8,
    parameter int USER_WIDTH = 8
) (
    input logic ACLK,
    input logic ARESETn
);

    localparam int STRB_WIDTH = DATA_WIDTH / 8;

    // Handshake
    logic                    TVALID;
    logic                    TREADY;

    // Payload
    logic [DATA_WIDTH-1:0]   TDATA;
    logic [STRB_WIDTH-1:0]   TSTRB;
    logic [STRB_WIDTH-1:0]   TKEEP;
    logic                    TLAST;
    logic [ID_WIDTH-1:0]     TID;
    logic [DEST_WIDTH-1:0]   TDEST;
    logic [USER_WIDTH-1:0]   TUSER;
    logic                    TWAKEUP;

    //--------------------------------------------------------------------------
    // Clocking blocks
    //--------------------------------------------------------------------------
    clocking mst_cb @(posedge ACLK);
        default input #1step output #1;
        output TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
        input  TREADY;
    endclocking

    clocking slv_cb @(posedge ACLK);
        default input #1step output #1;
        input  TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
        output TREADY;
    endclocking

    clocking mon_cb @(posedge ACLK);
        default input #1step;
        input TVALID, TREADY, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER, TWAKEUP;
    endclocking

    modport mst (clocking mst_cb, input ACLK, input ARESETn);
    modport slv (clocking slv_cb, input ACLK, input ARESETn);
    modport mon (clocking mon_cb, input ACLK, input ARESETn);

    //--------------------------------------------------------------------------
    // Protocol assertions (ARM IHI 0051B, section 2.2 / 2.8)
    //--------------------------------------------------------------------------
    // pragma translate_off
    // Once TVALID is asserted it must remain asserted until the handshake.
    property p_tvalid_stable;
        @(posedge ACLK) disable iff (!ARESETn)
            (TVALID && !TREADY) |=> TVALID;
    endproperty
    a_tvalid_stable: assert property (p_tvalid_stable)
        else $error("AXIS: TVALID deasserted before TREADY handshake");

    // Payload must remain stable while TVALID is high and waiting for TREADY.
    property p_payload_stable;
        @(posedge ACLK) disable iff (!ARESETn)
            (TVALID && !TREADY) |=> $stable(TDATA) && $stable(TLAST) &&
                                    $stable(TID)   && $stable(TDEST) &&
                                    $stable(TSTRB) && $stable(TKEEP) &&
                                    $stable(TUSER);
    endproperty
    a_payload_stable: assert property (p_payload_stable)
        else $error("AXIS: payload changed while TVALID high and TREADY low");

    // During reset, TVALID must be LOW.
    property p_reset_tvalid_low;
        @(posedge ACLK) (!ARESETn) |-> (!TVALID);
    endproperty
    a_reset_tvalid_low: assert property (p_reset_tvalid_low)
        else $error("AXIS: TVALID must be LOW during reset");
    // pragma translate_on
    property p_twakeup_valid;
        @(posedge ACLK) disable iff(!ARESETn)
            (TVALID && TWAKEUP && !TREADY) |=> $stable(TWAKEUP);
    endproperty
    a_twakeup_valid : assert property (p_twakeup_valid);

endinterface : axi_stream_if

`endif // AXI_STREAM_IF_SV
