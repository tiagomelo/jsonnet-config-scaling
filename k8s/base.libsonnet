{
  // deployment generates a Kubernetes Deployment manifest
  // Parameters:
  //   name: Name of the deployment
  //   image: Container image to use
  //   replicas: Number of replicas
  //   envVars: (optional) Environment variables for the container
  deployment(name, image, replicas, envVars={}):: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
      labels: {
        app: name,
      },
    },
    spec: {
      replicas: replicas,
      selector: {
        matchLabels: {
          app: name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: name,
          },
        },
        spec: {
          containers: [{
            name: name,
            image: image,
            env: std.map(
              function(k) { name: k, value: envVars[k] },
              std.objectFields(envVars),
            ),
          }],
        },
      },
    },
  },
}
