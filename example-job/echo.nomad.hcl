job "echo" {
  datacenters = ["dc1"]
  type        = "system" # <== This runs the job on ALL clients

  group "echo" {
    task "server" {
      driver = "raw_exec" # or "exec" if not using raw_exec

      config {
        command = "/bin/echo"
        args    = ["Hello from Nomad system job!"]
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}