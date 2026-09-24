# Vivado non-project synthesis and post-route STA.
read_verilog -sv ../rtl/mem_ctrl_pkg.sv
read_verilog -sv ../rtl/bank_fsm.sv
read_verilog -sv ../rtl/mem_ctrl.sv
read_xdc constraints.xdc
synth_design -top mem_ctrl -part xc7a100tcsg324-1
opt_design
place_design
route_design
report_timing_summary -file timing_summary.rpt
report_utilization -file util.rpt
write_checkpoint -force mem_ctrl_routed.dcp
