# Variables 
SRC_FILE := src/packet_generator.sv src/noc_router.sv src/top_module.sv src/small_fifo.sv 
TB_FILE := test/tb_top_module.sv

MODULE := tb_top_module

# Define Iverilog and VSIM variables
IVERILOG = iverilog
VVP = vvp
VSIM = vsim
VSIM_FLAGS = -c -do "run -all; quit"

IVERILOG_OUT = iverilog_sim.vvp
VSIM_OUT = modelsim_sim.out
GTKWAVE = packet_noc.vcd

# Default target
all: help

# Icarus Verilog compile and run
iverilog: $(SRC_FILE) $(TB_FILE)
	@echo "Compiling with Icarus Verilog..."
	$(IVERILOG) -g2012 -o $(IVERILOG_OUT) $(TB_FILE) $(SRC_FILE)
	@echo "Running simulation with Icarus Verilog..."
	$(VVP) $(IVERILOG_OUT)

# ModelSim compile and run
vsim: $(SRC_FILE) $(TB_FILE)
	@echo "Compiling with ModelSim..."
	vlog $(SRC_FILE) $(TB_FILE)
	@echo "Running simulation with ModelSim..."
	$(VSIM) $(VSIM_FLAGS) $(MODULE)

# View waveform using GTKWave
view: 
	@echo "Opening waveform with GTKWave..."
	gtkwave $(GTKWAVE)

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f $(IVERILOG_OUT) $(VSIM_OUT) $(VCD_FILE) $(GTKWAVE)
	rm -rf work 
	@echo "Clean complete."

# Help target
help:
	@echo "Makefile for compiling and running simulations with Icarus Verilog and ModelSim"
	@echo
	@echo "Usage:"
	@echo "  make iverilog       Compile and run simulation with Icarus Verilog"
	@echo "  make vsim           Compile and run simulation with ModelSim"
	@echo "  make view           View waveform using GTKWave"
	@echo "  make clean          Clean up generated files"
	@echo "  make help           Display this help message"

# Phony targets
.PHONY: all iverilog vsim view clean help verilator
