// -----------------------------------------------------------------------------
// Compile file list for the AXI-Stream VIP-to-VIP UVM testbench.
// Packages compile in dependency order:
//   common -> master, slave -> env -> test -> tb_top
// -----------------------------------------------------------------------------
+incdir+../tb
+incdir+../tb/common
+incdir+../tb/agent_master
+incdir+../tb/agent_slave
+incdir+../tb/env
+incdir+../tb/test
+incdir+../tb/test/seq_m
+incdir+../tb/test/seq_l
+incdir+../tb/test/vseq
+incdir+../tb/test/tests

// Interface (compilation unit scope, used by all packages + top).
../tb/axi_stream_if.sv

// Packages.
../tb/common/axis_cfg_pkg.sv
../tb/common/axis_common_pkg.sv
../tb/agent_master/axis_master_pkg.sv
../tb/agent_slave/axis_slave_pkg.sv
../tb/env/axis_env_pkg.sv
../tb/test/axis_test_pkg.sv

// Top.
../tb/tb_top.sv
