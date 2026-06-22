#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Run script for the AXI-Stream VIP-to-VIP UVM testbench.
# Supports three simulators; pick one. Default test = smoke.
#
#   ./run.sh [simulator] [test_name]
#     simulator : vcs | questa | xrun   (default: xrun)
#     test_name : axis_smoke_test | axis_packet_test | axis_continuous_test
#                 (default: axis_smoke_test)
# -----------------------------------------------------------------------------
set -euo pipefail

SIM=${1:-xrun}
TEST=${2:-axis_smoke_test}
SEED=${SEED:-1}

case "$SIM" in
  vcs)
    vcs -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
        -f axi_stream.f -l comp.log
    ./simv +UVM_TESTNAME=$TEST +ntb_random_seed=$SEED +UVM_VERBOSITY=UVM_MEDIUM \
        -l sim_${TEST}.log
    ;;
  questa)
    vlib work
    vlog -sv -L mtiUvm -f axi_stream.f -l comp.log
    vsim -c -do "run -all; quit" work.tb_top \
        +UVM_TESTNAME=$TEST -sv_seed $SEED +UVM_VERBOSITY=UVM_MEDIUM \
        -l sim_${TEST}.log
    ;;
  xrun)
    xrun -64bit -sv -uvm -timescale 1ns/1ps \
        -f axi_stream.f \
        +UVM_TESTNAME=$TEST -svseed $SEED +UVM_VERBOSITY=UVM_MEDIUM \
        -l sim_${TEST}.log
    ;;
  *)
    echo "Unknown simulator: $SIM (use vcs | questa | xrun)" >&2
    exit 1
    ;;
esac
