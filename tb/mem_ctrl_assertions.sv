module mem_ctrl_assertions(
  input logic clk, rst_n, cmd_valid, rdata_valid, cmd_ready, busy,
  input mem_ctrl_pkg::cmd_e cmd_op,
  input logic [mem_ctrl_pkg::BANK_BITS-1:0] cmd_bank,
  input mem_ctrl_pkg::bank_state_e bank_state [mem_ctrl_pkg::NUM_BANKS]
);
  import mem_ctrl_pkg::*;
  default clocking cb @(posedge clk); endclocking
  // With T_RCD=2, an ACTIVATE at cycle 0 followed by a same-bank READ at
  // cycle 1 matches the ##[0:1] window below and therefore fails this property.
  property ACT_TO_READ_SPACING;
    logic [BANK_BITS-1:0] b;
    disable iff (!rst_n)
      (cmd_valid && cmd_ready && cmd_op == CMD_ACTIVATE, b = cmd_bank)
      |-> not (##[0:T_RCD-1] (cmd_valid && cmd_ready && cmd_op == CMD_READ && cmd_bank == b));
  endproperty
  property ACT_TO_WRITE_SPACING;
    logic [BANK_BITS-1:0] b;
    disable iff (!rst_n)
      (cmd_valid && cmd_ready && cmd_op == CMD_ACTIVATE, b = cmd_bank)
      |-> not (##[0:T_RCD-1] (cmd_valid && cmd_ready && cmd_op == CMD_WRITE && cmd_bank == b));
  endproperty
  property ACT_TO_PRECHARGE_SPACING;
    logic [BANK_BITS-1:0] b;
    disable iff (!rst_n)
      (cmd_valid && cmd_ready && cmd_op == CMD_ACTIVATE, b = cmd_bank)
      |-> not (##[0:T_RAS-1] (cmd_valid && cmd_ready && cmd_op == CMD_PRECHARGE && cmd_bank == b));
  endproperty
  property PRECHARGE_TO_ACTIVATE_SPACING;
    logic [BANK_BITS-1:0] b;
    disable iff (!rst_n)
      (cmd_valid && cmd_ready && cmd_op == CMD_PRECHARGE, b = cmd_bank)
      |-> not (##[0:T_RP-1] (cmd_valid && cmd_ready && cmd_op == CMD_ACTIVATE && cmd_bank == b));
  endproperty
  property NO_READ_WRITE_TO_IDLE_BANK; disable iff (!rst_n) (cmd_valid && cmd_ready && (cmd_op inside {CMD_READ,CMD_WRITE})) |-> !(bank_state[cmd_bank] inside {BANK_IDLE,BANK_PRECHARGING}); endproperty
  property CL_LATENCY_CHECK; disable iff (!rst_n) (cmd_valid && cmd_ready && cmd_op==CMD_READ) |-> ##CL rdata_valid; endproperty
  // This property is intentionally not disabled during reset: a non-zero reset
  // output on any low-rst_n clock edge must fail rather than be masked.
  property RESET_VALUES_WHILE_ASSERTED;
    !rst_n |-> (!busy && !cmd_ready);
  endproperty
  assert property (ACT_TO_READ_SPACING) else $error("ACT to READ spacing");
  assert property (ACT_TO_WRITE_SPACING) else $error("ACT to WRITE spacing");
  assert property (ACT_TO_PRECHARGE_SPACING) else $error("ACT to PRE spacing");
  assert property (PRECHARGE_TO_ACTIVATE_SPACING) else $error("PRE to ACT spacing");
  assert property (NO_READ_WRITE_TO_IDLE_BANK) else $error("RW idle bank");
  assert property (CL_LATENCY_CHECK) else $error("CAS latency");
  assert property (RESET_VALUES_WHILE_ASSERTED) else $error("reset output state");
  generate
    for (genvar g = 0; g < NUM_BANKS; g++) begin : G_RESET_BANK_CHECK
      // This is not disabled on reset release, so a non-idle state on the first
      // rising reset edge is observable and raises an error.
      property RESET_RELEASE_BANK_IDLE;
        $rose(rst_n) |-> (bank_state[g] == BANK_IDLE);
      endproperty
      assert property (RESET_RELEASE_BANK_IDLE) else $error("reset bank state");
    end
  endgenerate
endmodule

bind mem_ctrl_if mem_ctrl_assertions u_assertions (.*);
