job "http-echo" {
  datacenters = ["dc1"]
  type        = "system" # runs on all nodes

  group "http-echo-group" {
    network {
      port "http" {
        static = 8080
      }
    }

    task "http-echo-task" {
      driver = "docker"

      config {
        image = "ealen/echo-server:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
        network {
          mbits = 10
          port "http" {}
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }

      # Optional: restart config
      restart {
        attempts = 3
        interval = "5m"
        delay    = "10s"
        mode     = "delay"
      }
    }
  }
}
