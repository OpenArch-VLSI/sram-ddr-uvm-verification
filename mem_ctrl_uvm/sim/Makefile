TEST ?= mem_ctrl_directed_test

# Questa flow.  VCS equivalent: vcs -sverilog -ntb_opts uvm -f filelist.f -top tb_top.
# Xsim equivalent: xvlog -sv -f filelist.f; xelab tb_top -debug typical; xsim tb_top -runall.
compile:
	vlib work
	vlog -sv +incdir+../tb/uvm -f filelist.f
	vopt tb_top -o tb_top_opt +acc

run: compile
	vsim -c tb_top_opt +UVM_TESTNAME=$(TEST) -do "run -all; quit -f"

cov: run
	vcover report -details coverage.ucdb

clean:
	@if exist work rmdir /s /q work
	@if exist transcript del /q transcript
	@if exist vsim.wlf del /q vsim.wlf
