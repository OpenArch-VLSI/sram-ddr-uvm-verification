class mem_ctrl_env extends uvm_env;
  `uvm_component_utils(mem_ctrl_env)
  mem_ctrl_agent agent; mem_ctrl_scoreboard sb; mem_ctrl_ref_model rm; mem_ctrl_coverage cov;
  function new(string name="mem_ctrl_env",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); agent=mem_ctrl_agent::type_id::create("agent",this); sb=mem_ctrl_scoreboard::type_id::create("sb",this); rm=mem_ctrl_ref_model::type_id::create("rm",this); cov=mem_ctrl_coverage::type_id::create("cov",this); endfunction
  function void connect_phase(uvm_phase phase); agent.mon.cmd_ap.connect(rm.imp); agent.mon.cmd_ap.connect(cov.analysis_export); agent.mon.read_ap.connect(sb.actual_fifo.analysis_export); rm.expected_ap.connect(sb.expected_fifo.analysis_export); endfunction
endclass
