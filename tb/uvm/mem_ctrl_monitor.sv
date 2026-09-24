class mem_ctrl_monitor extends uvm_monitor;
  `uvm_component_utils(mem_ctrl_monitor)
  virtual mem_ctrl_if vif; uvm_analysis_port #(mem_ctrl_seq_item) cmd_ap, read_ap;
  mem_ctrl_seq_item pending_reads[$];
  function new(string name="mem_ctrl_monitor",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual mem_ctrl_if)::get(this,"","vif",vif)) `uvm_fatal("NOVIF","vif not set"); cmd_ap=new("cmd_ap",this); read_ap=new("read_ap",this); endfunction
  task run_phase(uvm_phase phase); mem_ctrl_seq_item t, r;
    forever begin @(posedge vif.clk); if(vif.rst_n) begin
      if(vif.cmd_valid && vif.cmd_ready) begin t=mem_ctrl_seq_item::type_id::create("cmd_t"); t.op=vif.cmd_op; t.bank=vif.cmd_bank; t.addr=vif.cmd_addr; t.wdata=vif.wdata; cmd_ap.write(t); if(t.op==CMD_READ) pending_reads.push_back(t); end
      if(vif.rdata_valid) begin if(pending_reads.size()==0) `uvm_error("MON","read response without request") else begin r=pending_reads.pop_front(); r.rdata=vif.rdata; r.rdata_valid=1; read_ap.write(r); end end
    end end
  endtask
endclass
