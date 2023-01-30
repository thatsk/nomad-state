job "traefik" {

  region      = "global"
  datacenters = [
  "farm"
]
  type        = "system"
  
  constraint {
    attribute = "${meta.type}"
    value     = "server"
  }
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "traefik" {

    network {
      mode = "bridge"
      port "api" {
        static = 8081
        to     = 8081
      }
      port "http" {
        static = 80
        to     = 80
      }
      port "https" {
        static = 443
        to     = 443
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:2.6"
        ports = [
  "https",
  "api",
  "http"
]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }
      template {
        data = <<EOF
[log]
  level = "DEBUG"
[serversTransport]
  insecureSkipVerify = true
[entryPoints]
  [entryPoints.http]
  address = ":80"
  [entryPoints.https]
  address = ":443"
  [entryPoints.traefik]
  address = ":8081"
[api]
  dashboard = true
  insecure = true
[providers.consulCatalog]
  prefix           = "traefik"
  exposedByDefault = false
  connectAware = true
[providers.consulCatalog.endpoint]
  address = "http://172.17.0.1:8500"
  scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 200
        memory = 256
      }
      
      service {
        name = "traefik-http"
        port = "http"
        check {
          type     = "tcp"
          path     = ""
          interval = "3s"
          timeout  = "1s"
        }
      }
      service {
        name = "traefik-api"
        port = "api"
        check {
          type     = "tcp"
          path     = ""
          interval = "3s"
          timeout  = "1s"
        }
      }
    }
  }
}
