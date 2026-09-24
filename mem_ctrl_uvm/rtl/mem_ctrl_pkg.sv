package mem_ctrl_pkg;
  parameter int ADDR_WIDTH = 16;
  parameter int DATA_WIDTH = 32;
  parameter int NUM_BANKS  = 4;
  parameter int BANK_BITS  = $clog2(NUM_BANKS);
  parameter int T_RCD = 2, T_RAS = 5, T_RP = 2, CL = 2, T_WR = 2, T_RRD = 1;
  typedef enum logic [2:0] {BANK_IDLE, BANK_ACTIVATING, BANK_ACTIVE,
                            BANK_READING, BANK_WRITING, BANK_PRECHARGING} bank_state_e;
  typedef enum logic [2:0] {CMD_NOP, CMD_ACTIVATE, CMD_READ, CMD_WRITE,
                            CMD_PRECHARGE} cmd_e;
endpackage
