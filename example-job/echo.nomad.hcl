job "echo-docker" {
  datacenters = ["dc1"]
  type        = "system" # Run on all nodes

  group "echo-group" {
    task "echo-task" {
      driver = "docker"

      config {
        image = "alpine:latest"
        command = "echo"
        args = ["Hello from Nomad Docker job!"]
      }

      resources {
        cpu    = 100
        memory = 64
      }

      # Optional: If you want to see output via nomad logs
      logs {
        max_files     = 1
        max_file_size = 2
      }
    }
  }
}
