//==============================================================================
// tb_top.sv
// Top-level testbench: clock/reset generation, interface instance, VIP-to-VIP.
// No DUT — the master VIP drives the same interface the slave VIP responds on.
//==============================================================================
`include "uvm_macros.svh"

module tb_top;
    import uvm_pkg::*;
    import axis_test_pkg::*;

    // Interface geometry — must match the test's data_width.
    localparam int DATA_WIDTH = 32;
    localparam int ID_WIDTH   = 8;
    localparam int DEST_WIDTH = 8;
    localparam int USER_WIDTH = 8;

    logic ACLK;
    logic ARESETn;

    // Clock: 100 MHz.
    initial ACLK = 1'b0;
    always #5ns ACLK = ~ACLK;

    // Reset: active-LOW, asserted asynchronously, deasserted synchronously.
    initial begin
        ARESETn = 1'b0;
        repeat (5) @(posedge ACLK);
        ARESETn <= 1'b1;
    end

    axi_stream_if #(
        .DATA_WIDTH (DATA_WIDTH),
        .ID_WIDTH   (ID_WIDTH),
        .DEST_WIDTH (DEST_WIDTH),
        .USER_WIDTH (USER_WIDTH)
    ) axis_if (
        .ACLK    (ACLK),
        .ARESETn (ARESETn)
    );

    initial begin
        uvm_config_db#(virtual axi_stream_if)::set(null, "uvm_test_top", "vif", axis_if);
        run_test();
    end

    // Optional waveform dump.
    initial begin
        if ($test$plusargs("DUMP")) begin
            $dumpfile("axi_stream.vcd");
            $dumpvars(0, tb_top);
        end
    end

    // Global watchdog.
    initial begin
        #1ms;
        `uvm_error("TB_TOP", "global timeout reached")
        $finish;
    end

endmodule : tb_top
