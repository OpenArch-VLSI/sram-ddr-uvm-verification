# Timing correlation

The RTL guards commands in whole clock cycles.  At a simulated period `P`, a timing
parameter of `N` cycles represents a protocol interval of `N*P` ns: for example,
`T_RCD=2` at 5 ns represents 10 ns.  `CL` similarly defines when the registered
read response is expected.

Run synthesis and implementation with the same clock period used by the testbench.
The post-route timing summary reports worst negative slack (WNS). Non-negative WNS
means the implementation can meet that cycle time; a negative value means it cannot.
If the requested protocol interval is fixed in nanoseconds and the implementation
requires a longer clock period, increase the corresponding cycle counts (rounding up)
or improve the implementation. Sweep the XDC period to identify the fastest feasible
clock, then re-evaluate the simulated cycle-to-nanosecond conversion.
