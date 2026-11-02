.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "[CMD]_[TARGET]_[SUBCOMMAND]"; 												\
	echo "Available CMD:"; 																\
	echo "    tb - Testbenches"; 														\
	echo "    lt - Lint (Syntax checking)"; 											\
	echo "Available TARGET:"; 															\
	echo "    adder - The full adder"; 													\
	echo "    alu - The ALU"; 															\
	echo "Available SUBCOMMAND"; 														\
	echo "    _ - Run the whole command"; 												\
	echo "    tb_..._build - Compile the testbench without running it."; 				\
	echo "    tb_..._run - Run the testbench without compiling (must be precompiled)"


.PHONY: tb_adder_build
tb_adder_build:
	@echo "Compiling the testbench for full_adder.sv"
	@rm -rf sim/full_adder/*
	@echo "Cleared compile directory"
	verilator --cc --exe --build --trace -j 0 -GBIT_N=4 --Mdir sim/full_adder --top-module FullAdder_Nbit \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/full_adder.sv \
								$(CURDIR)/testbench/full_adder_tb.cpp
.PHONY: tb_adder_run
tb_adder_run:
	sim/full_adder/VFullAdder_Nbit
.PHONY: tb_adder
tb_adder:
	make tb_adder_build
	make tb_adder_run


.PHONY: lt_adder
lt_adder:
	@echo "Running a full lint on full_adder.sv"
	verilator --lint-only -Wall --top-module FullAdder_Nbit \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/full_adder.sv
.PHONY: lt_alu
lt_alu:
	@echo "Running a full lint on alu.sv"
	verilator --lint-only -Wall --top-module ALU \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/enums.sv \
								s32_src/sysverilog/full_adder.sv \
								s32_src/sysverilog/alu.sv