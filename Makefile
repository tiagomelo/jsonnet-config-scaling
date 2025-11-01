JSONNET ?= jsonnet
FMT ?= jsonnetfmt
OUTPUT_DIR = output

.PHONY: help
## help: shows this help message
help:
	@echo "Usage: make [target]\n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## fmt: formats all Jsonnet files
.PHONY: fmt
fmt:
	@find k8s -name '*.jsonnet' -o -name '*.libsonnet' | xargs $(FMT) -i

## build: generates all environments into output dir
.PHONY: build
build: fmt
	@mkdir -p $(OUTPUT_DIR)
	@for env in dev staging prod; do \
		$(JSONNET) k8s/environments/$$env.jsonnet | yq -P > $(OUTPUT_DIR)/$$env.yaml; \
		echo "Generated: $(OUTPUT_DIR)/$$env.yaml"; \
	done

## build-all-to-single-file: generates all environments into a single .yaml
.PHONY: build-all-to-single-file
build-all-to-single-file: fmt
	@mkdir -p $(OUTPUT_DIR)
	@$(JSONNET) k8s/environments/all.jsonnet | \
	yq eval -P '.[]' - | \
	awk 'BEGIN{first=1} /^apiVersion:/ {if (!first) print "---"; first=0} {print}' \
	> $(OUTPUT_DIR)/all.yaml
	@echo "Generated: $(OUTPUT_DIR)/all.yaml"

## validate: validates generated k8s manifests (requires kubeconform)
.PHONY: validate
validate:
	@for file in $(OUTPUT_DIR)/*.yaml; do \
		kubeconform -strict -summary $$file || exit 1; \
		echo "Validated $$file"; \
	done

## clean: cleans output directory
.PHONY: clean
clean:
	@rm -rf $(OUTPUT_DIR)