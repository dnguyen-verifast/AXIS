//==============================================================================
// axis_seq_item.sv
// Shared AXI-Stream transfer item (one TVALID/TREADY handshake).
// Used by the master VIP for stimulus and by both monitors for capture.
//==============================================================================
`ifndef AXIS_SEQ_ITEM_SV
`define AXIS_SEQ_ITEM_SV

class axis_seq_item extends uvm_sequence_item;

    // Payload — one entry per byte lane (width-agnostic via dynamic arrays).
    rand bit [7:0]  data[];
    rand bit        strb[];     // TSTRB per byte (1 = data byte, 0 = position)
    rand bit        keep[];     // TKEEP per byte (1 = keep, 0 = null byte)
    rand bit        last;       // TLAST
    rand int        id;         // TID
    rand int        dest;       // TDEST
    rand bit [63:0] user;       // TUSER (packed)

    // Master-side timing: idle cycles before asserting TVALID for this transfer.
    rand int unsigned valid_delay;
    rand axis_stream_type_e axis_stream_type;
    // Number of byte lanes — set by the sequence/config before randomize().
    int unsigned num_bytes = 4;

    `uvm_object_utils_begin(axis_seq_item)
        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_array_int(strb, UVM_ALL_ON)
        `uvm_field_array_int(keep, UVM_ALL_ON)
        `uvm_field_int(last, UVM_ALL_ON)
        `uvm_field_int(id,   UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(dest, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(user, UVM_ALL_ON)
        `uvm_field_int(valid_delay, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    constraint c_sizes {
        data.size() == num_bytes;
        strb.size() == num_bytes;
        keep.size() == num_bytes;
    }

    // ARM IHI 0051B Table 2-3: {TKEEP,TSTRB} == {0,1} is reserved/illegal.
    constraint c_legal_qualifiers {
        foreach (keep[i]) !(keep[i] == 0 && strb[i] == 1);
    }

    constraint c_delays { valid_delay inside {[0:5]}; }
    constraint c_ids    { id inside {[0:255]}; dest inside {[0:255]}; }

    constraint axis_stream_type_c1 { axis_stream_type == OPTIONAL_STREAM_TYPE;}
    function new(string name = "axis_seq_item");
        super.new(name);
    endfunction
//    extern virtual function void post_randomize();
endclass : axis_seq_item
// function void axis_seq_item::post_randomize();
//     bit keep_local[num_bytes];
//     bit strb_local[num_bytes];
//     case (axis_stream_type)
//         AXIS_BYTE_STREAM :
//         AXIS_CONTINUOUS_ALIGNED :
//         AXIS_CONTINUOUS_UNALIGNED :

// endfunction : post_randomize

`endif // AXIS_SEQ_ITEM_SV
