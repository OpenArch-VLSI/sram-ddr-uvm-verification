class mem_ctrl_random_seq extends mem_ctrl_base_seq;
  `uvm_object_utils(mem_ctrl_random_seq)
  function new(string name="mem_ctrl_random_seq"); super.new(name); endfunction
  task body(); logic [BANK_BITS-1:0] b; logic [ADDR_WIDTH-1:0] a; logic [DATA_WIDTH-1:0] d;
    for(int i=0;i<20;i++) begin b=$urandom_range(NUM_BANKS-1,0); a=$urandom; d=$urandom; send(CMD_ACTIVATE,b,a); send(CMD_WRITE,b,a,d); send(CMD_READ,b,a); send(CMD_PRECHARGE,b,a); end
  endtask
endclass
