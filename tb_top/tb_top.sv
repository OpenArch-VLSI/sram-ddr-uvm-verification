module tb_top;
  import uvm_pkg::*; import mem_ctrl_pkg::*; import mem_ctrl_tb_pkg::*;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  initial begin repeat(4) @(posedge clk); rst_n=1; end
  mem_ctrl_if vif(clk,rst_n);
  mem_ctrl dut(.clk(clk),.rst_n(rst_n),.cmd_valid(vif.cmd_valid),.cmd_op(vif.cmd_op),.cmd_bank(vif.cmd_bank),.cmd_addr(vif.cmd_addr),.wdata(vif.wdata),.rdata(vif.rdata),.rdata_valid(vif.rdata_valid),.cmd_ready(vif.cmd_ready),.busy(vif.busy),.bank_state(vif.bank_state));
  mem_ctrl_assertions u_assertions(.clk(clk),.rst_n(rst_n),.cmd_valid(vif.cmd_valid),.rdata_valid(vif.rdata_valid),.cmd_ready(vif.cmd_ready),.busy(vif.busy),.cmd_op(vif.cmd_op),.cmd_bank(vif.cmd_bank),.bank_state(vif.bank_state));
  initial begin uvm_config_db#(virtual mem_ctrl_if)::set(null,"*","vif",vif); run_test(); end
  initial begin if($test$plusargs("DUMP")) begin $dumpfile("mem_ctrl.vcd"); $dumpvars(0,tb_top); end end
  initial #100000 $finish;
endmodule