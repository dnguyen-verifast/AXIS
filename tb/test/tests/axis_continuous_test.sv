//==============================================================================
// axis_continuous_test.sv — eager Receiver, back-to-back streaming.
//==============================================================================
`ifndef AXIS_CONTINUOUS_TEST_SV
`define AXIS_CONTINUOUS_TEST_SV

class axis_continuous_test extends axis_base_test;
    `uvm_component_utils(axis_continuous_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void configure();
        env_cfg.slv_cfg.ready_low_pct = 5;  // mostly ready
    endfunction

    task run_phase(uvm_phase phase);
        axis_continuous_vseq vseq;
        super.run_phase(phase);
        phase.raise_objection(this);
        vseq = axis_continuous_vseq::type_id::create("vseq");
        if (!vseq.randomize()) `uvm_fatal(get_type_name(), "vseq randomize failed")
        vseq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
endclass

`endif // AXIS_CONTINUOUS_TEST_SV
