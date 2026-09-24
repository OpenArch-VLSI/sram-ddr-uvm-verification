module mem_ctrl_assertions(
  input logic clk, rst_n, cmd_valid, rdata_valid, cmd_ready, busy,
  input mem_ctrl_pkg::cmd_e cmd_op,
  input logic [mem_ctrl_pkg::BANK_BITS-1:0] cmd_bank,
  input mem_ctrl_pkg::bank_state_e bank_state [mem_ctrl_pkg::NUM_BANKS]
);
  import mem_ctrl_pkg::*;
  default clocking cb @(posedge clk); endclocking
  property ACT_TO_READ_SPACING; logic [BANK_BITS-1:0] b; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_ACTIVATE, b=cmd_bank) |-> !((cmd_valid && cmd_ready && cmd_op==CMD_READ && cmd_bank==b))[*T_RCD]; endproperty
  property ACT_TO_WRITE_SPACING; logic [BANK_BITS-1:0] b; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_ACTIVATE, b=cmd_bank) |-> !((cmd_valid && cmd_ready && cmd_op==CMD_WRITE && cmd_bank==b))[*T_RCD]; endproperty
  property ACT_TO_PRECHARGE_SPACING; logic [BANK_BITS-1:0] b; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_ACTIVATE, b=cmd_bank) |-> !((cmd_valid && cmd_ready && cmd_op==CMD_PRECHARGE && cmd_bank==b))[*T_RAS]; endproperty
  property PRECHARGE_TO_ACTIVATE_SPACING; logic [BANK_BITS-1:0] b; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_PRECHARGE, b=cmd_bank) |-> !((cmd_valid && cmd_ready && cmd_op==CMD_ACTIVATE && cmd_bank==b))[*T_RP]; endproperty
  property NO_READ_WRITE_TO_IDLE_BANK; disable iff (!rst_n) (cmd_valid && cmd_ready && (cmd_op inside {CMD_READ,CMD_WRITE})) |-> !(bank_state[cmd_bank] inside {BANK_IDLE,BANK_PRECHARGING}); endproperty
  property CL_LATENCY_CHECK; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_READ) |-> ##CL rdata_valid; endproperty
  property RESET_CHECK; disable iff (!rst_n) $fell(rst_n) |=> (!busy && cmd_ready==0); endproperty
  assert property (ACT_TO_READ_SPACING) else $error("ACT to READ spacing");
  assert property (ACT_TO_WRITE_SPACING) else $error("ACT to WRITE spacing");
  assert property (ACT_TO_PRECHARGE_SPACING) else $error("ACT to PRE spacing");
  assert property (PRECHARGE_TO_ACTIVATE_SPACING) else $error("PRE to ACT spacing");
  assert property (NO_READ_WRITE_TO_IDLE_BANK) else $error("RW idle bank");
  assert property (CL_LATENCY_CHECK) else $error("CAS latency");
  assert property (RESET_CHECK) else $error("reset state");
endmodule

bind mem_ctrl_if mem_ctrl_assertions u_assertions (.*);
