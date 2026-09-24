class mem_ctrl_coverage extends uvm_subscriber #(mem_ctrl_seq_item);
  `uvm_component_utils(mem_ctrl_coverage)
  cmd_e op_s; logic [BANK_BITS-1:0] bank_s, prev_bank; bit same_bank;
  covergroup cg; option.per_instance=1; cp_op: coverpoint op_s; cp_bank: coverpoint bank_s; cp_same: coverpoint same_bank; x_op_bank: cross cp_op,cp_bank; endgroup
  function new(string name="mem_ctrl_coverage",uvm_component parent=null); super.new(name,parent); cg=new; endfunction
  function void write(mem_ctrl_seq_item t); same_bank=(t.bank==prev_bank); op_s=t.op; bank_s=t.bank; cg.sample(); prev_bank=t.bank; endfunction
endclass
