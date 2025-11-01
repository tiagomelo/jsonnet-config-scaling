JSONNET ?= jsonnet
FMT ?= jsonnetfmt
OUTPUT_DIR = output

.PHONY: help
## help: shows this help message
help:
	@ echo "Usage: make [target]\n"
	@ sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## fmt: formats all Jsonnet files
.PHONY: fmt
fmt:
	@find k8s -name '*.jsonnet' -o -name '*.libsonnet' | xargs $(FMT) -i

## build: generates all environments into output dir
.PHONY: build
build: fmt
	@mkdir -p $(OUTPUT_DIR)
	@for env in dev staging prod; do \
		$(JSONNET) k8s/environments/$$env.jsonnet -o $(OUTPUT_DIR)/$$env.json; \
		echo "Generated: $(OUTPUT_DIR)/$$env.json"; \
	done

## validate: validates generated k8s manifests (requires kubeconform)
.PHONY: validate
validate:
	@for file in $(OUTPUT_DIR)/*.json; do \
		kubeconform -strict -summary $$file || exit 1; \
		echo "Validated $$file"; \
	done

## clean: cleans output directory
.PHONY: clean
clean:
	@rm -rf $(OUTPUT_DIR)