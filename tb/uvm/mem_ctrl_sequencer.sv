class mem_ctrl_sequencer extends uvm_sequencer #(mem_ctrl_seq_item);
  `uvm_component_utils(mem_ctrl_sequencer)
  function new(string name="mem_ctrl_sequencer", uvm_component parent=null); super.new(name,parent); endfunction
endclass
