class mem_ctrl_seq_item extends uvm_sequence_item;
  rand cmd_e op; rand logic [BANK_BITS-1:0] bank; rand logic [ADDR_WIDTH-1:0] addr; rand logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH-1:0] rdata; logic rdata_valid;
  constraint c_op { op inside {CMD_ACTIVATE,CMD_READ,CMD_WRITE,CMD_PRECHARGE}; }
  `uvm_object_utils_begin(mem_ctrl_seq_item)
    `uvm_field_enum(cmd_e, op, UVM_ALL_ON) `uvm_field_int(bank,UVM_ALL_ON) `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(wdata,UVM_ALL_ON) `uvm_field_int(rdata,UVM_ALL_ON) `uvm_field_int(rdata_valid,UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="mem_ctrl_seq_item"); super.new(name); endfunction
endclass
