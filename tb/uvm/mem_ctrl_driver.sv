class mem_ctrl_driver extends uvm_driver #(mem_ctrl_seq_item);
  `uvm_component_utils(mem_ctrl_driver)
  virtual mem_ctrl_if vif;
  function new(string name="mem_ctrl_driver",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual mem_ctrl_if)::get(this,"","vif",vif)) `uvm_fatal("NOVIF","vif not set"); endfunction
  task run_phase(uvm_phase phase);
    vif.cb.cmd_valid <= 0; vif.cb.cmd_op <= CMD_NOP; vif.cb.cmd_bank <= '0; vif.cb.cmd_addr <= '0; vif.cb.wdata <= '0;
    @(posedge vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      vif.cb.cmd_valid <= 1; vif.cb.cmd_op <= req.op; vif.cb.cmd_bank <= req.bank; vif.cb.cmd_addr <= req.addr; vif.cb.wdata <= req.wdata;
      do @(vif.cb); while (!vif.cb.cmd_ready);
      vif.cb.cmd_valid <= 0; vif.cb.cmd_op <= CMD_NOP;
      seq_item_port.item_done();
    end
  endtask
endclass
