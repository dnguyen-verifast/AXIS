# AXI-Stream VIP-to-VIP UVM Testbench

UVM environment for the **AMBA AXI-Stream protocol** (ARM IHI 0051B), built as
**two independent VIPs** — a master (Transmitter) VIP and a slave (Receiver) VIP,
each with its own config — wired together in a top env with a **scoreboard** and
driven through a **virtual sequencer / virtual sequence**.

```
                         axis_test
                             │ starts vseq on
                             ▼
                    ┌──────────────────┐
                    │ virtual sequencer │
                    └───┬───────────┬───┘
            mst_sqr ◄───┘           └───► slv_sqr
                             axis_env
   ┌──────────────────┐                 ┌──────────────────┐
   │  master VIP       │  AXI-Stream     │  slave VIP        │
   │  (Transmitter)    │ ───────────────▶│  (Receiver)       │
   │  cfg/drv/sqr/mon  │  TVALID/TDATA…  │  cfg/drv/sqr/mon  │
   │                   │ ◀────TREADY──── │                   │
   └────────┬──────────┘                 └─────────┬─────────┘
       mon  │ ap                               mon │ ap
            ▼                                      ▼
        ┌────────────────────────────────────────────┐
        │              scoreboard (in-order)            │
        └────────────────────────────────────────────┘
```

## Layout

```
tb/
├── axi_stream_if.sv              interface + clocking blocks + SVA assertions
├── common/                       shared between both VIPs
│   ├── axis_seq_item.sv          one transfer (data/strb/keep/last/id/dest/user)
│   └── axis_common_pkg.sv
├── agent_master/                 MASTER (Transmitter) VIP
│   ├── axis_master_cfg.sv        ← its own config
│   ├── axis_master_sequencer.sv
│   ├── axis_master_driver.sv     drives TVALID + payload, honours TREADY
│   ├── axis_master_monitor.sv    passive monitor (TX side)
│   ├── axis_master_agent.sv
│   ├── seq/                      sequences (one per file)
│   │   ├── axis_master_base_seq.sv
│   │   ├── axis_master_single_seq.sv
│   │   ├── axis_master_packet_seq.sv
│   │   └── axis_master_continuous_seq.sv
│   └── axis_master_pkg.sv
├── agent_slave/                  SLAVE (Receiver) VIP
│   ├── axis_slave_ready_item.sv  TREADY control item
│   ├── axis_slave_cfg.sv         ← its own config
│   ├── axis_slave_sequencer.sv
│   ├── axis_slave_driver.sv      drives TREADY from ready items
│   ├── axis_slave_monitor.sv     passive monitor (RX side)
│   ├── axis_slave_agent.sv
│   ├── seq/                      sequences (one per file)
│   │   ├── axis_slave_base_seq.sv
│   │   ├── axis_slave_random_ready_seq.sv
│   │   └── axis_slave_always_ready_seq.sv
│   └── axis_slave_pkg.sv
├── env/                          TOP environment
│   ├── axis_virtual_sequencer.sv handles to mst_sqr + slv_sqr
│   ├── axis_scoreboard.sv        TX vs RX, in-order
│   ├── axis_env_cfg.sv           holds mst_cfg + slv_cfg
│   ├── axis_env.sv               master agent + slave agent + scbd + vseqr
│   ├── vseq/                      virtual sequences (one per file)
│   │   ├── axis_base_vseq.sv
│   │   ├── axis_smoke_vseq.sv
│   │   ├── axis_packet_vseq.sv
│   │   └── axis_continuous_vseq.sv
│   └── axis_env_pkg.sv
├── test/
│   ├── tests/                    tests (one per file)
│   │   ├── axis_base_test.sv
│   │   ├── axis_smoke_test.sv
│   │   ├── axis_packet_test.sv
│   │   └── axis_continuous_test.sv
│   └── axis_test_pkg.sv
└── tb_top.sv                     clock/reset + interface (no DUT)
```

## How control flows (virtual sequencer / virtual sequence)

1. The **test** builds `axis_env` with two separate cfg objects (`mst_cfg`, `slv_cfg`).
2. `axis_env` connects `vseqr.mst_sqr`/`vseqr.slv_sqr` to the real sequencers.
3. The test starts a **virtual sequence** (`axis_*_vseq`) on `env.vseqr`.
4. The virtual sequence **forks the slave backpressure responder** on `slv_sqr`
   (runs forever), drives master traffic on `mst_sqr`, then kills the responder.

This keeps master stimulus and slave backpressure coordinated from one place.

## Running

```bash
cd sim
./run.sh xrun   axis_smoke_test         # Cadence Xcelium
./run.sh vcs    axis_packet_test         # Synopsys VCS
./run.sh questa axis_continuous_test     # Siemens Questa
SEED=42 ./run.sh xrun axis_packet_test   # override seed
```

Add `+DUMP` to the sim args for a VCD waveform.

## Tests

| Test | Virtual sequence | Backpressure |
|------|------------------|--------------|
| `axis_smoke_test`      | 5–15 random single transfers | random (`ready_low_pct=30`) |
| `axis_packet_test`     | 15 multi-transfer packets     | random |
| `axis_continuous_test` | back-to-back continuous packets | eager (`ready_low_pct=5`) |

## Protocol coverage

- Handshake stability, payload stability while stalled, `TVALID` low in reset (SVA).
- `TKEEP`/`TSTRB` qualifiers with reserved `{0,1}` excluded (Table 2-3).
- `TLAST` packet boundaries, `TID`/`TDEST` streams.
- In-order delivery (§4.2).
- Programmable `TREADY` backpressure via the slave ready sequences.

> `DATA_WIDTH` in `tb_top.sv` must match `data_width` in `axis_base_test` (default 32).

## Note on VIP-to-VIP topology

Both VIPs share **one physical interface** (direct link, no DUT), so both monitors
observe the same bus and the scoreboard mainly acts as a protocol-consistency /
self-check. For an end-to-end check *through* a DUT, place a DUT between two
separate interface instances and point each agent at its own vif.
