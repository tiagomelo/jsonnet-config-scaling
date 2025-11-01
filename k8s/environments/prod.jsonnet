local base = import '../base.libsonnet';
local mixins = import '../mixins/resources.libsonnet';

base.deployment(
  name='myapp-prod',
  image='myorg/myapp:1.1.0',
  replicas=3,
  envVars={ ENV: 'prod' },
) + mixins.withResources('500m', '1Gi')
