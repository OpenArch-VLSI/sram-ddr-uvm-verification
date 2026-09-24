class mem_ctrl_base_seq extends uvm_sequence #(mem_ctrl_seq_item);
  `uvm_object_utils(mem_ctrl_base_seq)
  virtual mem_ctrl_if vif;
  function new(string name="mem_ctrl_base_seq"); super.new(name); endfunction
  task pre_body();
    if (!uvm_config_db#(virtual mem_ctrl_if)::get(null, "", "vif", vif))
      `uvm_fatal("NOVIF", "vif not set for sequence")
  endtask
  task send(cmd_e op, logic [BANK_BITS-1:0] bank, logic [ADDR_WIDTH-1:0] addr, logic [DATA_WIDTH-1:0] data=0);
    mem_ctrl_seq_item t=mem_ctrl_seq_item::type_id::create("t"); start_item(t); t.op=op; t.bank=bank; t.addr=addr; t.wdata=data; finish_item(t);
  endtask
  // Returns the number of rising clock edges from submission through handshake.
  // A command that is immediately admissible returns one; a deliberately early
  // request accumulates each cmd_ready-low cycle before the accepting edge.
  task send_and_measure_stall(cmd_e op, logic [BANK_BITS-1:0] bank,
                              logic [ADDR_WIDTH-1:0] addr,
                              logic [DATA_WIDTH-1:0] data,
                              output int wait_cycles,
                              output bit saw_cmd_not_ready);
    mem_ctrl_seq_item t;
    bit done;
    t = mem_ctrl_seq_item::type_id::create("timed_t");
    start_item(t);
    t.op = op; t.bank = bank; t.addr = addr; t.wdata = data;
    wait_cycles = 0; saw_cmd_not_ready = 0; done = 0;
    fork
      begin
        while (!done) begin
          @(vif.cb);
          if (!done) begin
            wait_cycles++;
            if (!vif.cb.cmd_ready) saw_cmd_not_ready = 1;
          end
        end
      end
      begin
        finish_item(t);
        done = 1;
      end
    join_any
    disable fork;
  endtask
endclass
