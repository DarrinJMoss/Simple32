

tb_adder_build:
	@echo "Compiling the testbench for full_adder.sv"
	rm -rf sim/full_adder/*
	verilator --cc --exe --build --trace -j 0 -GBIT_N=4 --Mdir sim/full_adder --top-module FullAdder_Nbit \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/full_adder.sv \
								$(CURDIR)/testbench/full_adder_tb.cpp
tb_adder_run:
	sim/full_adder/VFullAdder_Nbit
tb_adder:
	make tb_adder_build
	make tb_adder_run



lt_adder:
	@echo "Running a full lint on full_adder.sv"
	verilator --lint-only -Wall --top-module FullAdder_Nbit \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/full_adder.sv
lt_alu:
	@echo "Running a full lint on alu.sv"
	verilator --lint-only -Wall --top-module ALU \
								s32_src/sysverilog/types.sv \
								s32_src/sysverilog/enums.sv \
								s32_src/sysverilog/full_adder.sv \
								s32_src/sysverilog/alu.sv