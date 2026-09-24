# SRAM/DDR-Style Memory Controller Verification with UVM

UVM-based verification environment for a synchronous SRAM memory controller with
DDR-style timing. The design is a four-bank, synthesizable command controller
supporting `ACTIVATE`, `READ`, `WRITE`, and `PRECHARGE`; commands are backpressured
per-bank until each bank's timing guard (tRCD/tRAS/tRP/CAS latency) permits them.

The verification environment includes a UVM 1.2 testbench (driver, monitor,
functional reference model, scoreboard, coverage), bound SystemVerilog Assertions
for protocol timing, constrained-random and directed sequences, and a Vivado
synthesis/STA flow for correlating simulated cycle counts to real timing margins.

## Contents

- [Features](#features)
- [Repository layout](#repository-layout)
- [Timing model](#timing-model)
- [Running simulation](#running-simulation)
- [Assertions and checking](#assertions-and-checking)
- [Synthesis](#synthesis)
- [Simplifications and scope](#simplifications-and-scope)
- [License](#license)

## Features

- **Synthesizable RTL** — a shared parameter/enum package, a top-level controller
  with per-bank arbitration and a CAS-latency response pipeline, and one FSM
  instance per bank.
- **UVM 1.2 environment** — layered driver/monitor/sequencer agent, a functional
  reference model, a scoreboard comparing actual vs. expected read data, and
  functional coverage with op/bank cross coverage.
- **Constrained-random and directed sequences**, including a directed sequence
  that explicitly drives a command one cycle early against the tRCD boundary and
  asserts that backpressure holds it until exactly the correct cycle.
- **Bound SVA checkers** covering ACTIVATE→READ, ACTIVATE→WRITE, ACTIVATE→PRECHARGE,
  and PRECHARGE→ACTIVATE spacing, illegal read/write to an idle or precharging
  bank, CAS latency, and reset behavior (both the reset-asserted output state and
  per-bank idle state on reset release).
- **Vivado non-project synthesis/STA flow** and a doc correlating simulated cycle
  counts to post-route timing slack.

## Repository layout

```
.
├── rtl/                    Synthesizable RTL
│   ├── mem_ctrl_pkg.sv       Shared parameters, timing constants, enums
│   ├── bank_fsm.sv            Per-bank timing FSM
│   └── mem_ctrl.sv            Top-level controller (bank arbitration, CL pipeline)
├── tb/                      Testbench (interface, assertions, UVM environment)
│   ├── mem_ctrl_if.sv          SV interface with clocking block
│   ├── mem_ctrl_assertions.sv  Bound SVA protocol timing checks
│   └── uvm/                    UVM 1.2 environment
│       ├── mem_ctrl_seq_item.sv
│       ├── mem_ctrl_sequencer.sv
│       ├── mem_ctrl_driver.sv
│       ├── mem_ctrl_monitor.sv
│       ├── mem_ctrl_ref_model.sv
│       ├── mem_ctrl_scoreboard.sv
│       ├── mem_ctrl_coverage.sv
│       ├── mem_ctrl_agent.sv
│       ├── mem_ctrl_env.sv
│       ├── mem_ctrl_pkg_tb.sv   Testbench package (dependency-ordered includes)
│       ├── sequences/           Base, random, and directed sequences
│       └── tests/               Base, random, and directed test classes
├── tb_top/
│   └── tb_top.sv              Clock/reset generation and DUT instantiation
├── sim/
│   ├── filelist.f             Compile-order file list
│   └── Makefile                Questa-oriented run targets (VCS/Xsim notes included)
├── syn/
│   ├── mem_ctrl_synth.tcl      Vivado non-project synthesis/STA script
│   └── constraints.xdc         Timing and I/O delay constraints
├── docs/
│   └── timing_correlation.md   Cycle-count ↔ post-route slack correlation notes
└── LICENSE
```

## Timing model

Default timing parameters (in clock cycles):

| Parameter | Cycles | Meaning                                   |
|-----------|--------|--------------------------------------------|
| `T_RCD`   | 2      | ACTIVATE → READ/WRITE                      |
| `T_RAS`   | 5      | ACTIVATE → PRECHARGE                       |
| `T_RP`    | 2      | PRECHARGE → ACTIVATE                       |
| `CL`      | 2      | READ → valid read data                     |
| `T_WR`    | 2      | Write completion → PRECHARGE allowed       |
| `T_RRD`   | 1      | Minimum spacing between ACTIVATEs (banks)  |

All parameters are defined in `rtl/mem_ctrl_pkg.sv` and shared by the RTL and the
bound assertions, so the checkers stay in sync with the design under test.

## Running simulation

From `sim/`, with a UVM 1.2–capable simulator on your `PATH`:

```bash
make run TEST=mem_ctrl_directed_test
make run TEST=mem_ctrl_random_test
```

The Makefile targets Questa by default and documents equivalent VCS and Xsim
command outlines. No simulator is bundled with this repository — compile the
sources listed in `sim/filelist.f` against your own UVM 1.2 installation.

## Assertions and checking

Protocol timing is checked two ways:

1. **SVA**, bound directly to the interface (`tb/mem_ctrl_assertions.sv`), which
   fails on *any* occurrence of a spacing violation within the relevant timing
   window (not just consecutive-cycle violations), and separately verifies output
   state during reset and per-bank idle state on reset release.
2. **The UVM scoreboard**, which compares actual read data (from the monitor)
   against a functional reference model's prediction, on a per-command basis.

The directed sequence additionally measures handshake backpressure directly: it
issues a READ immediately after ACTIVATE (one cycle early relative to `T_RCD`) and
flags an error unless the command is stalled and then accepted at exactly the
`T_RCD` boundary — making the tRCD timing requirement an explicit, actively-checked
part of the test rather than an incidental side effect of driver backpressure.

## Synthesis

From `syn/`:

```bash
vivado -mode batch -source mem_ctrl_synth.tcl
```

The default target part is `xc7a100tcsg324-1`; edit the part and clock period in
`constraints.xdc` to match your board. See `docs/timing_correlation.md` for how
simulated cycle counts map to post-route timing slack (WNS) when sweeping the
clock period.

## Simplifications and scope

This project models cycle-based bank timing and functional read/write correctness.
It intentionally does **not** implement physical DDR features: there are no external
DDR pins, refresh cycles, burst transactions, data masks, multi-master arbitration,
or PHY/calibration logic. Memory is an inferred per-bank array; the reference model
checks functional read data, while timing legality is enforced by the RTL and
independently checked by the bound assertions.

## License

Apache License 2.0 — see [LICENSE](LICENSE).