class mem_ctrl_directed_seq extends mem_ctrl_base_seq;
  `uvm_object_utils(mem_ctrl_directed_seq)
  function new(string name="mem_ctrl_directed_seq"); super.new(name); endfunction
  task body();
    // Commands are deliberately submitted immediately at each boundary; driver
    // backpressure holds each until the bank timing guard admits it.
    send(CMD_ACTIVATE,0,16'h0010); send(CMD_WRITE,0,16'h0010,32'hA5A55A5A); send(CMD_READ,0,16'h0010); send(CMD_PRECHARGE,0,0); send(CMD_ACTIVATE,0,16'h0020); send(CMD_ACTIVATE,1,16'h0030); send(CMD_READ,1,16'h0030);
  endtask
endclass
