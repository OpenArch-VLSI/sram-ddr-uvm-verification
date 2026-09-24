class mem_ctrl_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(mem_ctrl_scoreboard)
  uvm_tlm_analysis_fifo #(mem_ctrl_seq_item) actual_fifo, expected_fifo; int pass_count, fail_count;
  function new(string name="mem_ctrl_scoreboard",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); actual_fifo=new("actual_fifo",this); expected_fifo=new("expected_fifo",this); endfunction
  task run_phase(uvm_phase phase); mem_ctrl_seq_item a,e; forever begin expected_fifo.get(e); actual_fifo.get(a); if(e.rdata!==a.rdata) begin fail_count++; `uvm_error("SB",$sformatf("bank %0d addr %h expected %h actual %h",a.bank,a.addr,e.rdata,a.rdata)); end else pass_count++; end endtask
  function void report_phase(uvm_phase phase); `uvm_info("SB",$sformatf("reads passed=%0d failed=%0d",pass_count,fail_count),UVM_NONE) endfunction
endclass
