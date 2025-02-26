##=============================================================================
## [Filename]       Makefile.vcs
## [Project]        spi_ip
## [Author]         Julisa Verdejo - julisa.verdejopalacios@ba.infn.it
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    
## [Notes]          Command-line usage:
## [Status]         stable
## [Revisions]      -
##=============================================================================

# ===============================  VARIABLES  =================================

# Miscellaneous variables
CUR_DATE   := $(shell date +%Y-%m-%d_%H-%M-%S)

# Directories
GIT_DIR     := $(shell git rev-parse --show-toplevel)
ROOT_DIR    := $(GIT_DIR)
RUN_DIR     := $(ROOT_DIR)/work
SCRIPTS_DIR := $(ROOT_DIR)/scripts

# Configurations
SEED ?= 1
VCS_DEFINES ?= 
SIMV_ARGS ?=

# Files Simulation Verification Environment
SVE = -F $(ROOT_DIR)/sve.f

# Synopsys VCS/SIMV options
FILES = $(SVE) 

VCS_FLAGS = -full64 -sverilog \
			-lca -debug_access+all -kdb +vcs+vcdpluson \
			-timescale=1ns/100ps $(FILES) -l comp.log \
			-j8 \
			$(VCS_DEFINES) \

SIMV_FLAGS =  -l simv.log \
				$(SIMV_ARGS) \
				-ucli -do $(ROOT_DIR)/run.tcl

# Verdi options (see work/sim/verdi.cmd)
VERDI_FLAGS = -dbdir ./simv.daidir -ssf ./novas.fsdb -nologo -q
VERDI_DIR   = $(SCRIPTS_DIR)/waveforms
VERDI_FILE  = verdi.tcl
VERDI_PLAY  = -play $(VERDI_DIR)/$(VERDI_FILE)

# Colors
C_RED := \033[31m
C_GRE := \033[32m
C_BLU := \033[34m
C_YEL := \033[33m
C_ORA := \033[38;5;214m
NC    := \033[0m 

# Synopsys tools
SYNOPSYS_TOOLS = vcs verdi wv

# ================================  TARGETS  ==================================

.DEFAULT_GOAL := all

.PHONY: all
all: help
#______________________________________________________________________________

.PHONY: tools-check
tools-check: ## Check for missing tools
	@echo -e "$(C_ORA)Synopsys tool checking...$(NC)"
	@for tool in $(SYNOPSYS_TOOLS); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo -e "$(C_RED)Error: $(C_BLU)$$tool$(C_RED) is not installed or not in PATH$(NC)"; \
			exit 1; \
		else \
			echo -e "$(C_BLU)$$tool$(NC)\t is INSTALLED$(NC)"; \
		fi; \
	done
	@echo "All Synopsys tools are available"
#______________________________________________________________________________

.PHONY: version
vcs-version: ## Display Synopsys VCS version
	vcs -ID
#______________________________________________________________________________

.PHONY: vars
vars: ## Print Makefile variables
	@echo ""
	@echo -e "$(C_ORA)Miscellaneous variables...$(NC)"
	@echo "CUR_DATE    = $(CUR_DATE)"
	@echo ""
	@echo -e "$(C_ORA)Directory variables...$(NC)"
	@echo "GIT_DIR     = $(GIT_DIR)"
	@echo "ROOT_DIR    = $(ROOT_DIR)"
	@echo "RUN_DIR     = $(RUN_DIR)"
	@echo "SCRIPTS_DIR = $(SCRIPTS_DIR)"
	@echo "VERDI_DIR   = $(VERDI_DIR)"
	@echo ""
	@echo -e "$(C_ORA)Variables...$(NC)"
	@echo "SEED        = $(SEED)"
	@echo "VCS_DEFINES = $(VCS_DEFINES)"
	@echo "SIMV_ARGS   = $(SIMV_ARGS)"
	@echo ""
#______________________________________________________________________________

.PHONY: compile
compile: ## Runs VCS compilation
	@echo -e "$(C_ORA)Compiling project$(NC)"
	@mkdir -p $(RUN_DIR)/sim 
	cd $(RUN_DIR)/sim && vcs $(VCS_FLAGS)
#______________________________________________________________________________

.PHONY: sim
sim: ## Runs simv simulation using SEED
	@echo -e "$(C_ORA)Running simulation SEED=$(SEED)$(NC)"
	cd $(RUN_DIR)/sim && ./simv +ntb_random_seed=${SEED} $(SIMV_FLAGS)
#______________________________________________________________________________

.PHONY: random
random: ## Runs simv simulation using a random seed
	@echo -e "$(C_ORA)Running simulation with random seed$(NC)"
	cd $(RUN_DIR)/sim && ./simv +ntb_random_seed_automatic $(SIMV_FLAGS)
#______________________________________________________________________________

.PHONY: verdi
verdi: ## Opens Verdi GUI
	@echo -e "$(C_ORA)Openning Verdi$(NC)"
	cd $(RUN_DIR)/sim && verdi $(VERDI_FLAGS) &
#______________________________________________________________________________

.PHONY: verdi-play
verdi-play: ## Opens Verdi GUI running verdi.tcl file
	@echo -e "$(C_ORA)Openning Verdi running verdi.cmd$(NC)"
	cd $(RUN_DIR)/sim && verdi $(VERDI_FLAGS) $(VERDI_PLAY) &
#______________________________________________________________________________

.PHONY: clean
clean: ## Remove all simulation files
	@echo -e "$(C_ORA)Removing all simulation files$(NC)"
	rm -rf $(RUN_DIR) dpi/*.o
#______________________________________________________________________________

.PHONY: help
help: ## Display help message
	@echo ""
	@echo "======================================================================"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "--------------------------- Targets ----------------------------------"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "- make \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "--------------------------- Variables -------------------------------"
	@echo "  SEED                : Random seed used, must be an integer > 0"
	@echo "  VCS_DEFINES         : Add defines to vcs command"
	@echo "  SIMV_ARG            : Add plusargs to simv command"
	@echo ""
	@echo "---------------------------- Defaults --------------------------------"
	@echo "  SEED                : $(SEED)"
	@echo "  VCS_DEFINES         : $(VCS_DEFINES)"
	@echo "  SIMV_ARGS           : $(SIMV_ARGS)"
	@echo ""
	@echo "======================================================================"
	@echo ""
