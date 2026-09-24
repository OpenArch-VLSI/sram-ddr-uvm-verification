class mem_ctrl_directed_seq extends mem_ctrl_base_seq;
  `uvm_object_utils(mem_ctrl_directed_seq)
  function new(string name="mem_ctrl_directed_seq"); super.new(name); endfunction
  task body();
    int read_wait_cycles;
    bit saw_read_backpressure;
    // READ is submitted immediately after ACTIVATE, one cycle too early for
    // T_RCD=2. The helper measures the cmd_ready stall and requires acceptance
    // on the T_RCD boundary, making this an explicit timing-boundary test.
    send(CMD_ACTIVATE,0,16'h0010);
    send_and_measure_stall(CMD_READ,0,16'h0010,'0,read_wait_cycles,saw_read_backpressure);
    if (!saw_read_backpressure || read_wait_cycles != T_RCD)
      `uvm_error("TRCD_BOUNDARY", $sformatf("READ backpressure=%0b; accepted after %0d cycles; expected %0d", saw_read_backpressure, read_wait_cycles, T_RCD))
    else
      `uvm_info("TRCD_BOUNDARY", $sformatf("READ correctly stalled until T_RCD=%0d", T_RCD), UVM_MEDIUM)
    send(CMD_WRITE,0,16'h0010,32'hA5A55A5A);
    send(CMD_READ,0,16'h0010);
    send(CMD_PRECHARGE,0,'0);
    send(CMD_ACTIVATE,1,16'h0030);
    send(CMD_READ,1,16'h0030);
  endtask
endclass
