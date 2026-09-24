# Sweep this period (for example 5, 4, then 3 ns) to correlate implementation
# frequency with the cycle values T_RCD/T_RAS/T_RP/CL used by simulation.
create_clock -name clk -period 5.000 [get_ports clk]
set_input_delay -clock clk 1.000 [get_ports {cmd_valid cmd_op[*] cmd_bank[*] cmd_addr[*] wdata[*]}]
set_output_delay -clock clk 1.000 [get_ports {rdata[*] rdata_valid cmd_ready busy}]
