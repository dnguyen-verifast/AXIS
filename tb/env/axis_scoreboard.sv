//==============================================================================
// axis_scoreboard.sv
// Compares transfers seen by the master-side monitor (Transmitter) against the
// slave-side monitor (Receiver), in order (ARM IHI 0051B 4.2 — no reordering).
//==============================================================================
`ifndef AXIS_SCOREBOARD_SV
`define AXIS_SCOREBOARD_SV

`uvm_analysis_imp_decl(_mst)
`uvm_analysis_imp_decl(_slv)

class axis_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axis_scoreboard)

    uvm_analysis_imp_mst #(axis_seq_item, axis_scoreboard) mst_imp;
    uvm_analysis_imp_slv #(axis_seq_item, axis_scoreboard) slv_imp;

    axis_seq_item mst_q[$];
    axis_seq_item slv_q[$];

    int unsigned matched;
    int unsigned mismatched;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mst_imp = new("mst_imp", this);
        slv_imp = new("slv_imp", this);
    endfunction

    function void write_mst(axis_seq_item tr);
        mst_q.push_back(tr);
        try_compare();
    endfunction

    function void write_slv(axis_seq_item tr);
        slv_q.push_back(tr);
        try_compare();
    endfunction

    function void try_compare();
        while (mst_q.size() > 0 && slv_q.size() > 0)
            compare_one(mst_q.pop_front(), slv_q.pop_front());
    endfunction

    function void compare_one(axis_seq_item a, axis_seq_item b);
        bit ok = 1;
        if (a.id   !== b.id)   ok = 0;
        if (a.dest !== b.dest) ok = 0;
        if (a.last !== b.last) ok = 0;
        foreach (a.data[i]) begin
            if (a.keep[i] !== b.keep[i]) ok = 0;
            if (a.strb[i] !== b.strb[i]) ok = 0;
            if (a.keep[i] && a.strb[i] && (a.data[i] !== b.data[i])) ok = 0;
        end

        if (ok) begin
            matched++;
            `uvm_info("SCBD", $sformatf("MATCH #%0d id=%0d dest=%0d last=%0b",
                                        matched, a.id, a.dest, a.last), UVM_HIGH)
        end
        else begin
            mismatched++;
            `uvm_error("SCBD", $sformatf("MISMATCH:\n  TX: %s\n  RX: %s",
                                         a.sprint(), b.sprint()))
        end
    endfunction

    function void check_phase(uvm_phase phase);
        if (mst_q.size() != 0 || slv_q.size() != 0)
            `uvm_error("SCBD", $sformatf("Leftover — TX=%0d RX=%0d",
                                         mst_q.size(), slv_q.size()))
        if (matched == 0)
            `uvm_warning("SCBD", "no transfers compared")
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCBD", $sformatf("matched=%0d mismatched=%0d",
                                    matched, mismatched), UVM_LOW)
    endfunction

endclass : axis_scoreboard

`endif // AXIS_SCOREBOARD_SV
