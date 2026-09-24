# SRAM/DDR-Style Memory Controller Verification with UVM

This self-contained example implements a four-bank, synthesizable, DDR-lite command
controller and a UVM 1.2 environment. Commands are `ACTIVATE`, `READ`, `WRITE`, and
`PRECHARGE`; accepted commands are backpressured until their target bank's timing
guard permits them.

## Layout

`rtl/` contains the shared package, top controller, and one FSM per bank. `tb/`
contains the interface, bound SVA checker, and UVM environment. `sim/` contains a
Questa-oriented filelist and Makefile. `syn/` is a ready-to-run Vivado non-project
flow; `docs/timing_correlation.md` describes cycle/STA correlation.

## Run simulation

From `sim`, run `make run TEST=mem_ctrl_directed_test` or
`make run TEST=mem_ctrl_random_test` in a Questa/UVM 1.2 installation. The Makefile
also documents equivalent VCS and Xsim command outlines. No simulator is bundled;
the source can be inspected or compiled in your local UVM-capable simulator.

## Timing model and checking

Defaults are `T_RCD=2`, `T_RAS=5`, `T_RP=2`, `CL=2`, `T_WR=2`, and `T_RRD=1` cycles.
The bound assertions check activate/read, activate/write, activate/precharge,
precharge/activate, read/write legality, CAS latency, and reset behavior. The
scoreboard compares returned read data with a functional associative-array model.

## Synthesis

From `syn`, invoke `vivado -mode batch -source mem_ctrl_synth.tcl`. The target is
`xc7a100tcsg324-1`; edit it and the clock period in `constraints.xdc` for your board.

## Simplifications

The memory is an inferred per-bank array with no external DDR pins, refresh, bursts,
data masks, arbitration across masters, or physical DDR calibration. The reference
model checks functional read data; the assertions and RTL implement timing behavior.
