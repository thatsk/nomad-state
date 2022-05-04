job "whoami" {
  
  datacenters = [
  "DC1"
]
  type = "service"

    group "backend" {
        network {
            mode = "bridge"
        }

        service {
            name = "whoami"
            port = 80
            tags = [
            "traefik.enable=true",
            "traefik.http.routers.whoami01.rule=Host(`hello-world.crunk.dk`)",
            "traefik.consulcatalog.connect=true"
            ]

            connect {
                sidecar_service {}
            }
        }

        task "whoami" {
            driver = "docker"
            config {
            image = "containous/whoami"
            }
        }
    }
}



