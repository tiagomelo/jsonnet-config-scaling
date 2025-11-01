{
  // Mixin to add resource requests and limits to the first container of a Kubernetes Pod spec
  // Parameters:
  //   cpu: CPU resource (e.g., "500m", "1")
  //   memory: Memory resource (e.g., "256Mi", "1Gi")
  withResources(cpu, memory):: {
    spec+: {
      template+: {
        spec+: {
          containers: [
            super.containers[0] {  // Merge into first container
              resources: {
                limits: { cpu: cpu, memory: memory },
                requests: { cpu: cpu, memory: memory },
              },
            },
          ] + super.containers[1:],  // Keep any remaining containers
        },
      },
    },
  },
}
