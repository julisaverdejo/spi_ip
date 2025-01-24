##=============================================================================
## [Filename]       Makefile
## [Project]        hello
## [Author]         Julisa Verdejo 
## [Language]       GNU Makefile
## [Created]        Nov 2024
## [Modified]       -
## [Description]    Makefile to manage
## [Notes]          -
## [Status]         devel
## [Revisions]      -
##=============================================================================

# ===============================  VARIABLES  =================================

# Miscellaneous variables
CUR_DATE := $(shell date +%Y-%m-%d_%H-%M-%S)

# Colors
C_RED := \033[31m
C_GRE := \033[32m
C_BLU := \033[34m
C_YEL := \033[33m
C_ORA := \033[38;5;214m
NC    := \033[0m 

# ================================  TARGETS  ==================================

.DEFAULT_GOAL := all

.PHONY: all
all: help
#______________________________________________________________________________

.PHONY: compile
compile: ## Compile design
	@echo -e "$(C_ORA)Compiling design$(NC)"
#______________________________________________________________________________

.PHONY: sim
sim: ## Simulate design
	@echo -e "$(C_ORA)Simulate design$(NC)"
#______________________________________________________________________________

.PHONY: clean
clean: ## Remove simulation files
	@echo -e "$(C_ORA)Removing compilation files$(NC)"
	rm -rf $(OBJ_DIR) $(BIN_DIR)
#______________________________________________________________________________

.PHONY: help
help: ## Display help message
	@echo ""
	@echo "====================================================================="
	@echo "Usage: make <target> "
	@echo ""
	@echo "Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "- make \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "====================================================================="
	@echo ""