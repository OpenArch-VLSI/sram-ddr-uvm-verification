class mem_ctrl_random_test extends mem_ctrl_base_test;
  `uvm_component_utils(mem_ctrl_random_test)
  function new(string name="mem_ctrl_random_test",uvm_component parent=null); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase); mem_ctrl_random_seq s=mem_ctrl_random_seq::type_id::create("s"); phase.raise_objection(this); s.start(env.agent.seqr); #100ns; phase.drop_objection(this); endtask
endclass
