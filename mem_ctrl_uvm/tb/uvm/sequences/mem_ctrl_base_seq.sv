class mem_ctrl_base_seq extends uvm_sequence #(mem_ctrl_seq_item);
  `uvm_object_utils(mem_ctrl_base_seq)
  function new(string name="mem_ctrl_base_seq"); super.new(name); endfunction
  task send(cmd_e op, logic [BANK_BITS-1:0] bank, logic [ADDR_WIDTH-1:0] addr, logic [DATA_WIDTH-1:0] data=0);
    mem_ctrl_seq_item t=mem_ctrl_seq_item::type_id::create("t"); start_item(t); t.op=op; t.bank=bank; t.addr=addr; t.wdata=data; finish_item(t);
  endtask
endclass
