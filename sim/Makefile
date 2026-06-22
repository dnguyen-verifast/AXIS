# =============================================================================
# Makefile — AXI-Stream VIP-to-VIP UVM testbench (QuestaSim / ModelSim)
#
# Quick start:
#   make                      # show this help
#   make run                  # compile + run default test (batch)
#   make run TEST=axis_packet_test SEED=7
#   make gui  TEST=axis_smoke_test            # interactive, waves logged
#   make regress              # run every test with coverage, then merge+report
#   make cov_report           # text + HTML coverage report from merged UCDB
#   make clean                # remove generated files
#
# Common overridable variables (make VAR=value):
#   TEST       UVM test name           (default: axis_smoke_test)
#   SEED       random seed             (default: random; use a number to repro)
#   VERB       UVM verbosity           (default: UVM_MEDIUM)
#   COV        coverage on/off         (default: 0; regress forces 1)
#   WAVES      log waves for GUI/debug (default: 1 in gui/debug)
#   PLUSARGS   extra +plusargs passed verbatim to vsim
#   VOPT_ACC   visibility for debug    (default: +acc in gui/debug)
# =============================================================================

# ---- Project knobs ----------------------------------------------------------
TOP        := tb_top
WORK       := work
FLIST      := axi_stream.f
UVM_LIB    := mtiUvm
TIMESCALE  := 1ns/1ps

# All tests known to the regression. Add new tests here.
TESTS      := axis_smoke_test axis_packet_test axis_continuous_test

# ---- User-overridable defaults ----------------------------------------------
TEST       ?= axis_smoke_test
SEED       ?= random
VERB       ?= UVM_MEDIUM
COV        ?= 0
WAVES      ?= 0
PLUSARGS   ?=

# ---- Tools ------------------------------------------------------------------
VLIB       := vlib
VMAP       := vmap
VLOG       := vlog
VSIM       := vsim
VCOVER     := vcover

# ---- Derived paths ----------------------------------------------------------
LOG_DIR    := logs
COV_DIR    := cov
COV_HTML   := $(COV_DIR)/html
MERGED     := $(COV_DIR)/merged.ucdb
UCDB       := $(COV_DIR)/$(TEST).ucdb
COMP_LOG   := $(LOG_DIR)/comp.log
SIM_LOG    := $(LOG_DIR)/sim_$(TEST).log
# Stamp encodes the coverage mode so toggling COV recompiles, but repeated
# runs in the same mode (e.g. the regression loop) compile only once.
COMP_DONE  := $(WORK)/.compiled.cov$(COV)

# ---- Compile flags ----------------------------------------------------------
VLOG_FLAGS := -sv -timescale $(TIMESCALE) -L $(UVM_LIB) +incdir+../tb
ifeq ($(COV),1)
  VLOG_FLAGS += +cover=bcefst
endif

# ---- Coverage flags ---------------------------------------------------------
ifeq ($(COV),1)
  VSIM_COV   := -coverage
  COV_SAVE   := coverage save -onexit $(UCDB);
else
  VSIM_COV   :=
  COV_SAVE   :=
endif

# ---- Waveform / visibility --------------------------------------------------
VOPT_ACC   ?= +acc
ifeq ($(WAVES),1)
  WAVE_CMDS  := log -r /*;
else
  WAVE_CMDS  :=
endif

# ---- Common vsim arguments --------------------------------------------------
VSIM_ARGS  := $(VSIM_COV) $(WORK).$(TOP) \
              -sv_seed $(SEED) \
              +UVM_TESTNAME=$(TEST) \
              +UVM_VERBOSITY=$(VERB) \
              -L $(UVM_LIB) \
              $(PLUSARGS)

# =============================================================================
# Targets
# =============================================================================
.PHONY: help comp run gui debug regress cov_merge cov_report \
        $(TESTS) dirs clean cleanall

help:
	@echo "AXI-Stream UVM testbench — QuestaSim Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  comp                 compile the testbench (vlib + vlog)"
	@echo "  run                  compile + run TEST in batch (-c)"
	@echo "  gui                  compile + run TEST in the GUI (waves logged)"
	@echo "  debug                gui + full signal visibility (+acc)"
	@echo "  regress              run all tests with coverage, then merge+report"
	@echo "  cov_merge            merge all $(COV_DIR)/*.ucdb into $(MERGED)"
	@echo "  cov_report           text + HTML coverage report"
	@echo "  <test_name>          run a single named test (e.g. make axis_packet_test)"
	@echo "  clean                remove logs, coverage, transcripts"
	@echo "  cleanall             clean + remove the compiled work library"
	@echo ""
	@echo "Tests: $(TESTS)"
	@echo ""
	@echo "Examples:"
	@echo "  make run TEST=axis_packet_test SEED=7 VERB=UVM_HIGH"
	@echo "  make gui TEST=axis_smoke_test"
	@echo "  make regress COV=1"

# ---- Directories ------------------------------------------------------------
dirs:
	@mkdir -p $(LOG_DIR) $(COV_DIR)

# ---- Compile ----------------------------------------------------------------
comp: $(COMP_DONE)

$(COMP_DONE): | dirs
	@echo ">> Compiling ($(FLIST), cov=$(COV))"
	@test -d $(WORK) || $(VLIB) $(WORK)
	$(VLOG) $(VLOG_FLAGS) -f $(FLIST) -l $(COMP_LOG)
	@rm -f $(WORK)/.compiled.cov*
	@touch $(COMP_DONE)

# ---- Batch run --------------------------------------------------------------
run: comp
	@echo ">> Running $(TEST) (seed=$(SEED), cov=$(COV)) in batch"
	$(VSIM) -c $(VSIM_ARGS) \
	    -do "$(COV_SAVE) run -all; quit -f" \
	    -l $(SIM_LOG)

# ---- GUI run ----------------------------------------------------------------
gui: comp
	@echo ">> Launching $(TEST) in the GUI"
	$(VSIM) -gui $(VSIM_ARGS) \
	    -do "$(WAVE_CMDS) run -all"

# ---- Debug (GUI + full visibility) ------------------------------------------
# +acc visibility is an elaboration (vopt) option, applied at vsim time.
debug: comp
	@echo ">> Launching $(TEST) in the GUI with full visibility"
	$(VSIM) -gui -voptargs="$(VOPT_ACC)" $(VSIM_ARGS) \
	    -do "log -r /*; add wave -r /*; run -all"

# ---- Per-test convenience targets -------------------------------------------
# `make axis_packet_test` == `make run TEST=axis_packet_test`
$(TESTS):
	@$(MAKE) --no-print-directory run TEST=$@ COV=$(COV) SEED=$(SEED) VERB=$(VERB)

# ---- Regression: every test, coverage on, then merge + report ---------------
regress: | dirs
	@echo ">> Regression over: $(TESTS)"
	@rm -f $(COV_DIR)/*.ucdb
	@set -e; for t in $(TESTS); do \
	    echo "==== $$t ===="; \
	    $(MAKE) --no-print-directory run TEST=$$t COV=1 SEED=$(SEED) VERB=$(VERB); \
	done
	@$(MAKE) --no-print-directory cov_merge
	@$(MAKE) --no-print-directory cov_report

# ---- Coverage merge ---------------------------------------------------------
cov_merge:
	@echo ">> Merging coverage databases into $(MERGED)"
	$(VCOVER) merge -out $(MERGED) $(COV_DIR)/*.ucdb

# ---- Coverage report (text summary + HTML) ----------------------------------
cov_report:
	@echo ">> Coverage summary"
	$(VCOVER) report $(MERGED)
	@echo ">> Writing HTML report to $(COV_HTML)"
	$(VCOVER) report -details -html -htmldir $(COV_HTML) $(MERGED)
	@echo ">> Open $(COV_HTML)/index.html"

# ---- Cleanup ----------------------------------------------------------------
clean:
	@echo ">> Removing generated outputs"
	-rm -rf $(LOG_DIR) $(COV_DIR)
	-rm -f transcript vsim.wlf vsim_stacktrace.vstf *.vcd *.log
	-rm -f $(COMP_DONE)

cleanall: clean
	@echo ">> Removing work library"
	-rm -rf $(WORK)
