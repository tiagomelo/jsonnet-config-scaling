local base = import '../base.libsonnet';
local mixins = import '../mixins/resources.libsonnet';

base.deployment(
  name='myapp-dev',
  image='myorg/myapp:1.1.0',
  replicas=1,
  envVars={ ENV: 'dev' },
) + mixins.withResources('100m', '256Mi')
