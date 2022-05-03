job "hello_world" {
  
  datacenters = [
  "DC1"
]
  type = "service"

  group "app" {
    count = 3

    network {
      port "http" {
        to = 8000
      }
    }

    
    service {
      name = "webapp"
      tags = [
  "traefik.enable=true",
  "traefik.http.routers.webapp.rule=Host(`impala-lb-tf-1899406609.eu-central-1.elb.amazonaws.com`)"
]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }

      connect {
        native = true
      }
    }


    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"
      shutdown_delay = "2s"

      config {
        image = "mnomitch/hello_world_server"
        ports = ["http"]
      }

      env {
        MESSAGE = "Hello from Nomad!"
      }
    }
  }
}
