local base = import '../base.libsonnet';
local mixins = import '../mixins/resources.libsonnet';

base.deployment(
  name='myapp-staging',
  image='myorg/myapp:1.1.0',
  replicas=2,
  envVars={ ENV: 'staging' },
) + mixins.withResources('200m', '512Mi')
