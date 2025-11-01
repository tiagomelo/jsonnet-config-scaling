local base = import '../base.libsonnet';
local mixins = import '../mixins/resources.libsonnet';

// resources for different environments.
local resourceMap = {
  dev: { cpu: '100m', memory: '256Mi' },
  staging: { cpu: '200m', memory: '512Mi' },
  prod: { cpu: '500m', memory: '1Gi' },
};

[
  // Generate deployments for all environments.
  base.deployment(
    name='myapp-' + env,
    image='myorg/myapp:1.2.0',
    replicas=if env == 'prod' then 3 else 1,
    envVars={ ENV: env },
  ) + mixins.withResources(resourceMap[env].cpu, resourceMap[env].memory)
  for env in std.objectFields(resourceMap)
]
