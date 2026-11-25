.PHONY: help bootstrap tag-check

help: ## Show this help
	   @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %$$1, $$2}'

bootstrap: ## Create Terraform remote state bucket
		./scripts/bootstrap.sh

tag-check: ## Print resource counts per type for ENV (make tag-check ENV=dev)
		./scripts/tag-check.sh $(ENV)