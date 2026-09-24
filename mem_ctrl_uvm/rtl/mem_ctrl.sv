module mem_ctrl (
  input logic clk, rst_n, cmd_valid,
  input mem_ctrl_pkg::cmd_e cmd_op,
  input logic [mem_ctrl_pkg::BANK_BITS-1:0] cmd_bank,
  input logic [mem_ctrl_pkg::ADDR_WIDTH-1:0] cmd_addr,
  input logic [mem_ctrl_pkg::DATA_WIDTH-1:0] wdata,
  output logic [mem_ctrl_pkg::DATA_WIDTH-1:0] rdata,
  output logic rdata_valid, cmd_ready, busy,
  output mem_ctrl_pkg::bank_state_e bank_state [mem_ctrl_pkg::NUM_BANKS]
);
  import mem_ctrl_pkg::*;
  localparam int DEPTH = (1 << ADDR_WIDTH);
  logic can_activate [NUM_BANKS], can_read [NUM_BANKS], can_write [NUM_BANKS], can_precharge [NUM_BANKS];
  logic activate_s [NUM_BANKS], read_s [NUM_BANKS], write_s [NUM_BANKS], precharge_s [NUM_BANKS];
  logic [DATA_WIDTH-1:0] mem [NUM_BANKS][DEPTH];
  logic [CL-1:0] rd_valid_pipe;
  logic [DATA_WIDTH-1:0] rd_data_pipe [CL];
  integer i;
  always_comb begin
    cmd_ready = 1'b0;
    for (int j=0; j<NUM_BANKS; j++) begin
      activate_s[j]=0; read_s[j]=0; write_s[j]=0; precharge_s[j]=0;
    end
    if (rst_n && cmd_valid) begin
      case (cmd_op)
        CMD_ACTIVATE: cmd_ready = can_activate[cmd_bank];
        CMD_READ: cmd_ready = can_read[cmd_bank];
        CMD_WRITE: cmd_ready = can_write[cmd_bank];
        CMD_PRECHARGE: cmd_ready = can_precharge[cmd_bank];
        CMD_NOP: cmd_ready = 1'b1;
        default: cmd_ready = 1'b0;
      endcase
      if (cmd_ready) begin
        case (cmd_op)
          CMD_ACTIVATE: activate_s[cmd_bank]=1;
          CMD_READ: read_s[cmd_bank]=1;
          CMD_WRITE: write_s[cmd_bank]=1;
          CMD_PRECHARGE: precharge_s[cmd_bank]=1;
          default: ;
        endcase
      end
    end
  end
  always_comb begin
    busy = 1'b0;
    for (int j=0; j<NUM_BANKS; j++) if (bank_state[j] != BANK_IDLE) busy = 1'b1;
  end
  generate for (genvar g=0; g<NUM_BANKS; g++) begin: G_BANK
    bank_fsm u_bank (.clk(clk), .rst_n(rst_n), .activate(activate_s[g]), .read(read_s[g]), .write(write_s[g]), .precharge(precharge_s[g]), .state(bank_state[g]), .can_activate(can_activate[g]), .can_read(can_read[g]), .can_write(can_write[g]), .can_precharge(can_precharge[g]));
  end endgenerate
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata <= '0; rdata_valid <= 0; rd_valid_pipe <= '0;
      for (i=0;i<CL;i++) rd_data_pipe[i] <= '0;
    end else begin
      rdata_valid <= rd_valid_pipe[0]; rdata <= rd_data_pipe[0];
      for (i=0;i<CL-1;i++) begin rd_valid_pipe[i] <= rd_valid_pipe[i+1]; rd_data_pipe[i] <= rd_data_pipe[i+1]; end
      rd_valid_pipe[CL-1] <= 0;
      if (cmd_valid && cmd_ready && cmd_op == CMD_WRITE) mem[cmd_bank][cmd_addr] <= wdata;
      if (cmd_valid && cmd_ready && cmd_op == CMD_READ) begin
        rd_valid_pipe[CL-1] <= 1; rd_data_pipe[CL-1] <= mem[cmd_bank][cmd_addr];
      end
    end
  end
endmodule
