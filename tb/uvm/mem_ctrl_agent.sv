class mem_ctrl_agent extends uvm_agent;
  `uvm_component_utils(mem_ctrl_agent)
  mem_ctrl_sequencer seqr; mem_ctrl_driver drv; mem_ctrl_monitor mon;
  function new(string name="mem_ctrl_agent",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); mon=mem_ctrl_monitor::type_id::create("mon",this); if(is_active==UVM_ACTIVE) begin seqr=mem_ctrl_sequencer::type_id::create("seqr",this); drv=mem_ctrl_driver::type_id::create("drv",this); end endfunction
  function void connect_phase(uvm_phase phase); if(is_active==UVM_ACTIVE) drv.seq_item_port.connect(seqr.seq_item_export); endfunction
endclass
