class mem_ctrl_ref_model extends uvm_component;
  `uvm_component_utils(mem_ctrl_ref_model)
  uvm_analysis_imp #(mem_ctrl_seq_item,mem_ctrl_ref_model) imp; uvm_analysis_port #(mem_ctrl_seq_item) expected_ap;
  logic [DATA_WIDTH-1:0] mem [logic [BANK_BITS-1:0]][logic [ADDR_WIDTH-1:0]];
  function new(string name="mem_ctrl_ref_model",uvm_component parent=null); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); imp=new("imp",this); expected_ap=new("expected_ap",this); endfunction
  function void write(mem_ctrl_seq_item t); mem_ctrl_seq_item e;
    if(t.op==CMD_WRITE) mem[t.bank][t.addr]=t.wdata;
    if(t.op==CMD_READ) begin e=mem_ctrl_seq_item::type_id::create("expected"); e.copy(t); e.rdata=mem[t.bank][t.addr]; e.rdata_valid=1; expected_ap.write(e); end
  endfunction
endclass
