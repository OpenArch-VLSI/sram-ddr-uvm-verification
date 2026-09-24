interface mem_ctrl_if (input logic clk, input logic rst_n);
  import mem_ctrl_pkg::*;
  logic cmd_valid; cmd_e cmd_op; logic [BANK_BITS-1:0] cmd_bank; logic [ADDR_WIDTH-1:0] cmd_addr;
  logic [DATA_WIDTH-1:0] wdata, rdata; logic rdata_valid, cmd_ready, busy;
  bank_state_e bank_state [NUM_BANKS];
  clocking cb @(posedge clk);
    default input #1step output #0;
    output cmd_valid, cmd_op, cmd_bank, cmd_addr, wdata;
    input rdata, rdata_valid, cmd_ready, busy;
  endclocking
  modport DRIVER (clocking cb, input clk, rst_n);
  modport MONITOR (input clk, rst_n, cmd_valid, cmd_op, cmd_bank, cmd_addr, wdata, rdata, rdata_valid, cmd_ready, busy, bank_state);
endinterface
