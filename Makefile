.PHONY: help install update test test-all test-puzzle format format-check book build-book clean-book clean clean-all sanitizers sanitizer memcheck racecheck synccheck initcheck run-puzzle gpu-info gpu-specs check-prereqs setup verify install-pre-commit

# Default target
.DEFAULT_GOAL := help

# Colors for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[0;32m
COLOR_YELLOW := \033[1;33m
COLOR_BLUE := \033[0;34m
COLOR_CYAN := \033[0;36m

# Variables
PUZZLE ?=
FLAG ?=
TOOL ?=

# Help target
help: ## Show this help message
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Mojo🔥 GPU Puzzles - Makefile$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Usage:$(COLOR_RESET)"
	@echo "  make [target] [PUZZLE=pXX] [FLAG=--flag-name] [TOOL=tool-name]"
	@echo ""
	@echo "$(COLOR_BOLD)Setup & Installation:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)install$(COLOR_RESET)              Install dependencies using pixi"
	@echo "  $(COLOR_GREEN)update$(COLOR_RESET)                Update pixi and dependencies"
	@echo "  $(COLOR_GREEN)check-prereqs$(COLOR_RESET)         Check prerequisites (pixi, GPU, etc.)"
	@echo "  $(COLOR_GREEN)setup$(COLOR_RESET)                 Full setup: check prereqs and install"
	@echo ""
	@echo "$(COLOR_BOLD)Testing:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)test$(COLOR_RESET)                  Run all tests"
	@echo "  $(COLOR_GREEN)test-all$(COLOR_RESET)              Run all tests (same as test)"
	@echo "  $(COLOR_GREEN)test-puzzle$(COLOR_RESET)           Run tests for specific puzzle (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)verify$(COLOR_RESET)                Run tests and format check"
	@echo ""
	@echo "$(COLOR_BOLD)Code Quality:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)format$(COLOR_RESET)                Format code using mojo format"
	@echo "  $(COLOR_GREEN)format-check$(COLOR_RESET)          Check if code is formatted"
	@echo "  $(COLOR_GREEN)install-pre-commit$(COLOR_RESET)     Install pre-commit hooks"
	@echo ""
	@echo "$(COLOR_BOLD)Documentation:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)book$(COLOR_RESET)                  Build and serve the book locally"
	@echo "  $(COLOR_GREEN)build-book$(COLOR_RESET)           Build the book without serving"
	@echo "  $(COLOR_GREEN)clean-book$(COLOR_RESET)           Clean book build artifacts"
	@echo ""
	@echo "$(COLOR_BOLD)Sanitizers (NVIDIA GPU debugging):$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)sanitizers$(COLOR_RESET)            Run all sanitizers on puzzle (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)memcheck$(COLOR_RESET)              Memory error detection (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)racecheck$(COLOR_RESET)             Race condition detection (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)synccheck$(COLOR_RESET)             Synchronization error detection (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)initcheck$(COLOR_RESET)             Uninitialized memory detection (use PUZZLE=pXX)"
	@echo ""
	@echo "$(COLOR_BOLD)Running Puzzles:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)run-puzzle$(COLOR_RESET)            Run a specific puzzle (use PUZZLE=pXX)"
	@echo "  $(COLOR_GREEN)p01$(COLOR_RESET)                  Run puzzle 01"
	@echo "  $(COLOR_GREEN)p02$(COLOR_RESET)                  Run puzzle 02"
	@echo "  $(COLOR_GREEN)p03$(COLOR_RESET)                  Run puzzle 03"
	@echo "  $(COLOR_GREEN)...$(COLOR_RESET)                  (p01-p34 available)"
	@echo ""
	@echo "$(COLOR_BOLD)GPU Information:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)gpu-info$(COLOR_RESET)              Show basic GPU information"
	@echo "  $(COLOR_GREEN)gpu-specs$(COLOR_RESET)             Show complete GPU specifications"
	@echo ""
	@echo "$(COLOR_BOLD)Cleanup:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)clean$(COLOR_RESET)                Clean book build artifacts"
	@echo "  $(COLOR_GREEN)clean-all$(COLOR_RESET)             Clean all generated files (book, animations, profiles)"
	@echo ""
	@echo "$(COLOR_BOLD)Examples:$(COLOR_RESET)"
	@echo "  make test                           # Run all tests"
	@echo "  make test-puzzle PUZZLE=p23         # Test puzzle 23"
	@echo "  make run-puzzle PUZZLE=p01          # Run puzzle 01"
	@echo "  make memcheck PUZZLE=p25            # Run memory check on p25"
	@echo "  make sanitizers PUZZLE=p25          # Run all sanitizers on p25"
	@echo "  make format                         # Format code"
	@echo "  make book                           # Build and serve book"

# Setup & Installation
install: ## Install dependencies using pixi
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Installing dependencies...$(COLOR_RESET)"
	pixi install

update: ## Update pixi and dependencies
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Updating pixi and dependencies...$(COLOR_RESET)"
	pixi self-update
	pixi update

check-prereqs: ## Check prerequisites
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Checking prerequisites...$(COLOR_RESET)"
	@command -v pixi >/dev/null 2>&1 || { echo "$(COLOR_YELLOW)Warning: pixi not found. Install from https://pixi.sh$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)✓ pixi found$(COLOR_RESET)"
	@command -v mojo >/dev/null 2>&1 || { echo "$(COLOR_YELLOW)Warning: mojo not found. Run 'make install' first$(COLOR_RESET)"; }
	@echo "$(COLOR_GREEN)✓ mojo found$(COLOR_RESET)"
	@command -v nvidia-smi >/dev/null 2>&1 || command -v rocm-smi >/dev/null 2>&1 || { echo "$(COLOR_YELLOW)Warning: No GPU detected. Some puzzles require GPU.$(COLOR_RESET)"; }
	@echo "$(COLOR_GREEN)✓ Prerequisites check complete$(COLOR_RESET)"

setup: check-prereqs install ## Full setup: check prereqs and install
	@echo "$(COLOR_GREEN)✓ Setup complete!$(COLOR_RESET)"

# Testing
test: ## Run all tests
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Running all tests...$(COLOR_RESET)"
	pixi run tests

test-all: test ## Run all tests (alias)

test-puzzle: ## Run tests for specific puzzle (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_YELLOW)Error: PUZZLE not specified. Usage: make test-puzzle PUZZLE=p23$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Running tests for $(PUZZLE)...$(COLOR_RESET)"
	pixi run tests $(PUZZLE)

verify: format-check test ## Run tests and format check
	@echo "$(COLOR_GREEN)✓ Verification complete!$(COLOR_RESET)"

# Code Quality
format: ## Format code using mojo format
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Formatting code...$(COLOR_RESET)"
	pixi run format

format-check: ## Check if code is formatted
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Checking code format...$(COLOR_RESET)"
	pixi run format-check

install-pre-commit: ## Install pre-commit hooks
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Installing pre-commit hooks...$(COLOR_RESET)"
	pixi run install-pre-commit

# Documentation
book: ## Build and serve the book locally
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Building and serving book...$(COLOR_RESET)"
	pixi run book

build-book: ## Build the book without serving
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Building book...$(COLOR_RESET)"
	pixi run build-book

clean-book: ## Clean book build artifacts
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Cleaning book build artifacts...$(COLOR_RESET)"
	pixi run clean

# Sanitizers
sanitizers: ## Run all sanitizers on puzzle (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_YELLOW)Error: PUZZLE not specified. Usage: make sanitizers PUZZLE=p25$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Running all sanitizers on $(PUZZLE)...$(COLOR_RESET)"
	pixi run sanitizers $(PUZZLE)

memcheck: ## Memory error detection (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running memcheck on all puzzles...$(COLOR_RESET)"; \
		pixi run memcheck; \
	else \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running memcheck on $(PUZZLE)...$(COLOR_RESET)"; \
		pixi run memcheck $(PUZZLE); \
	fi

racecheck: ## Race condition detection (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running racecheck on all puzzles...$(COLOR_RESET)"; \
		pixi run racecheck; \
	else \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running racecheck on $(PUZZLE)...$(COLOR_RESET)"; \
		pixi run racecheck $(PUZZLE); \
	fi

synccheck: ## Synchronization error detection (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running synccheck on all puzzles...$(COLOR_RESET)"; \
		pixi run synccheck; \
	else \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running synccheck on $(PUZZLE)...$(COLOR_RESET)"; \
		pixi run synccheck $(PUZZLE); \
	fi

initcheck: ## Uninitialized memory detection (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running initcheck on all puzzles...$(COLOR_RESET)"; \
		pixi run initcheck; \
	else \
		echo "$(COLOR_BOLD)$(COLOR_CYAN)Running initcheck on $(PUZZLE)...$(COLOR_RESET)"; \
		pixi run initcheck $(PUZZLE); \
	fi

# Running Puzzles
run-puzzle: ## Run a specific puzzle (use PUZZLE=pXX)
	@if [ -z "$(PUZZLE)" ]; then \
		echo "$(COLOR_YELLOW)Error: PUZZLE not specified. Usage: make run-puzzle PUZZLE=p01$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Running $(PUZZLE)...$(COLOR_RESET)"
	pixi run $(PUZZLE)

# Individual puzzle targets (p01-p34)
p01:
	pixi run p01
p02:
	pixi run p02
p03:
	pixi run p03
p04:
	pixi run p04
p04_layout_tensor:
	pixi run p04_layout_tensor
p05:
	pixi run p05
p05_layout_tensor:
	pixi run p05_layout_tensor
p06:
	pixi run p06
p07:
	pixi run p07
p07_layout_tensor:
	pixi run p07_layout_tensor
p08:
	pixi run p08
p08_layout_tensor:
	pixi run p08_layout_tensor
p09:
	pixi run p09
p10:
	pixi run p10
p11:
	pixi run p11
p11_layout_tensor:
	pixi run p11_layout_tensor
p12:
	pixi run p12
p12_layout_tensor:
	pixi run p12_layout_tensor
p13:
	pixi run p13
p14:
	pixi run p14
p15:
	pixi run p15
p16:
	pixi run p16
p17:
	pixi run p17
p18:
	pixi run p18
p18-package:
	pixi run p18-package
p18-test-kernels:
	pixi run p18-test-kernels
p19:
	pixi run p19
p20:
	pixi run p20
p21:
	pixi run p21
p22:
	pixi run p22
p23:
	pixi run p23
p24:
	pixi run p24
p25:
	pixi run p25
p26:
	pixi run p26
p27:
	pixi run p27
p28:
	pixi run p28
p29:
	pixi run p29
p30:
	pixi run p30
p31:
	pixi run p31
p32:
	pixi run p32
p33:
	pixi run p33
p34:
	pixi run p34

# GPU Information
gpu-info: ## Show basic GPU information
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)GPU Information:$(COLOR_RESET)"
	pixi run gpu-info || echo "$(COLOR_YELLOW)GPU info not available$(COLOR_RESET)"

gpu-specs: ## Show complete GPU specifications
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)GPU Specifications:$(COLOR_RESET)"
	pixi run gpu-specs || echo "$(COLOR_YELLOW)GPU specs not available$(COLOR_RESET)"

# Cleanup
clean: clean-book ## Clean book build artifacts (alias)

clean-all: ## Clean all generated files (book, animations, profiles)
	@echo "$(COLOR_BOLD)$(COLOR_CYAN)Cleaning all generated files...$(COLOR_RESET)"
	pixi run clean-all || echo "$(COLOR_YELLOW)Clean-all not available$(COLOR_RESET)"
