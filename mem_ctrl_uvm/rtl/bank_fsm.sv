module bank_fsm #(
  parameter int T_RCD_P = mem_ctrl_pkg::T_RCD, T_RAS_P = mem_ctrl_pkg::T_RAS,
  parameter int T_RP_P = mem_ctrl_pkg::T_RP, T_WR_P = mem_ctrl_pkg::T_WR
) (
  input logic clk, rst_n, activate, read, write, precharge,
  output mem_ctrl_pkg::bank_state_e state,
  output logic can_activate, can_read, can_write, can_precharge
);
  import mem_ctrl_pkg::*;
  localparam int CW = 16;
  logic [CW-1:0] rcd_count, ras_count, rp_count, wr_count;
  always_comb begin
    can_activate = ((state == BANK_IDLE) || (state == BANK_PRECHARGING)) && (rp_count == 0);
    can_read = (state == BANK_ACTIVE) && (rcd_count == 0) && (wr_count == 0);
    can_write = (state == BANK_ACTIVE) && (rcd_count == 0);
    can_precharge = (state == BANK_ACTIVE) && (ras_count == 0) && (wr_count == 0);
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= BANK_IDLE; rcd_count <= '0; ras_count <= '0; rp_count <= '0; wr_count <= '0;
    end else begin
      if (rcd_count != 0) rcd_count <= rcd_count - 1'b1;
      if (ras_count != 0) ras_count <= ras_count - 1'b1;
      if (rp_count  != 0) rp_count  <= rp_count  - 1'b1;
      if (wr_count  != 0) wr_count  <= wr_count  - 1'b1;
      case (state)
        BANK_IDLE: if (activate && can_activate) begin
          state <= BANK_ACTIVE; rcd_count <= T_RCD_P-1; ras_count <= T_RAS_P-1;
        end
        BANK_ACTIVE: begin
          if (read && can_read) state <= BANK_READING;
          else if (write && can_write) begin state <= BANK_WRITING; wr_count <= T_WR_P-1; end
          else if (precharge && can_precharge) begin state <= BANK_PRECHARGING; rp_count <= T_RP_P-1; end
        end
        BANK_READING: state <= BANK_ACTIVE;
        BANK_WRITING: state <= BANK_ACTIVE;
        BANK_PRECHARGING: if (rp_count == 0) begin
          if (activate) begin state <= BANK_ACTIVE; rcd_count <= T_RCD_P-1; ras_count <= T_RAS_P-1; end
          else state <= BANK_IDLE;
        end
        default: state <= BANK_IDLE;
      endcase
    end
  end
endmodule
