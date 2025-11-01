# Jsonnet scalable Kubernetes configuration example

This repository demonstrates how to use [Jsonnet](https://jsonnet.org) to **scale Kubernetes configuration across multiple environments** in a maintainable, DRY, and extensible way.

Instead of writing and maintaining separate YAML files for `dev`, `staging`, and `prod`, we use **modular Jsonnet templates** with mixins and per-environment overrides — and validate the result using Kubernetes schemas.

---

## Why Jsonnet?

When your infrastructure grows, raw YAML or JSON files quickly become:

- repetitive  
- hard to update across environments  
- error-prone to validate  

Jsonnet is a **data templating language** that extends JSON with:

- Variables, functions, and conditionals  
- Object composition and imports  
- Mixins and reusable templates  
- Array comprehensions (e.g. for multiple environments)

Perfect for generating lots of similar config resources with minimal duplication.

---

## Project structure

```

jsonnet-config-scaling/
├── k8s/
│   ├── base.libsonnet           # Base Deployment template
│   ├── mixins/
│   │   └── resources.libsonnet  # Mixin for CPU/memory per env
│   └── environments/
│       ├── dev.jsonnet
│       ├── staging.jsonnet
│       ├── prod.jsonnet
│       └── all.jsonnet          # Generates for all envs with loop
├── output/                      # Generated manifests (ignored in Git)
├── Makefile
├── .gitignore
└── README.md

````

---

## Usage

### 1. Install prerequisites

```bash
brew install jsonnet kubeconform
# or
sudo apt install jsonnet
go install github.com/yannh/kubeconform/cmd/kubeconform@latest
````

### 2. Generate manifests for all environments

```bash
make build
```

Outputs Kubernetes Deployment JSON under `output/`:

```bash
output/dev.json
output/staging.json
output/prod.json
```

### 3. Validate manifests

Uses [`kubeconform`](https://github.com/yannh/kubeconform) to check against the official Kubernetes schema:

```bash
make validate
```

- No cluster required — validation is done locally
- Ensures everything is production-safe

---

## How it works

Each environment `.jsonnet` file imports a shared **base Deployment template** and applies:

* Custom parameters (like app name, image tag, replica count)
* A resource **mixin** based on environment size (small for dev, larger for prod)

Example: `dev.jsonnet`

```jsonnet
local base = import '../base.libsonnet';
local mixins = import '../mixins/resources.libsonnet';

base.deployment(
  name='myapp-dev',
  image='myorg/myapp:1.1.0',
  replicas=1,
  envVars={ ENV: 'dev' },
) + mixins.withResources('100m', '256Mi')
```

---

## Bonus: generate all envs in one shot

`all.jsonnet` uses a `for` loop + conditional logic to generate multiple environments at once:

```jsonnet
local resourceMap = {
  dev: { cpu: '100m', memory: '256Mi' },
  staging: { cpu: '200m', memory: '512Mi' },
  prod: { cpu: '500m', memory: '1Gi' },
};

[
  base.deployment(
    name='myapp-' + env,
    image='myorg/myapp:1.2.0',
    replicas=if env == 'prod' then 3 else 1,
    envVars={ ENV: env },
  ) + mixins.withResources(resourceMap[env].cpu, resourceMap[env].memory)
  for env in std.objectFields(resourceMap)
]
```

---

## Makefile commands

| Command         | Description                                |
| --------------- | ------------------------------------------ |
| `make build`    | Generate manifests under `output/`         |
| `make validate` | Validate manifests against K8s schema      |
| `make fmt`      | Format all `.jsonnet` / `.libsonnet` files |
| `make clean`    | Remove `output/`                           |


