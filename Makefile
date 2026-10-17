ur = uv run

.DEFAULT_GOAL := help

##@ Setup project
init: ## Initialize the project
	uv sync
	$(ur) pre-commit install --install-hooks
	$(ur) pre-commit autoupdate

##@ Local development
run: ## Run the application
	$(ur) __main__.py

test: ## Run the tests when test files exist
	@if find tests -type f -name 'test_*.py' -print -quit | grep -q .; then \
		$(ur) pytest -v; \
	else \
		echo "No tests found; add tests under tests/ when ready."; \
	fi

lint: ## Run the linter
	$(ur) ruff check --config=pyproject.toml --fix ./src/

format: ## Format the code
	$(ur) ruff format --config=pyproject.toml ./src/

typecheck: ## Run the type checker
	$(ur) mypy --config-file=pyproject.toml ./src/

clean: ## Clean up the project (cache)
	find . -type d -name '__pycache__' -exec rm -rf {} +
	rm -rf .mypy_cache .ruff_cache .pytest_cache

##@ Git
commit: ## Do commit with conventional commit message
	$(ur) cz commit

bump: ## Bump the version and update CHANGELOG.md
	$(ur) cz bump

##@ Documentation
serve: ## Serve the documentation locally
	$(ur) mkdocs serve

##@ Help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: commit bump help init run test lint format typecheck clean serve
