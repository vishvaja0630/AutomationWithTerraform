terraform{
    required_providers {
    # We recommend pinning to the specific version of the Docker Provider you're using
    # since new versions are released frequently
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.8.0"
    }
  }
 }

# Configure the docker provider
provider "docker" {
}


resource "docker_container" "dockerisedtomcat" {
  image = "tomcat:latest"
  name  = "tomcat"
  restart = "always"
  ports {
    internal = 8080
    external = 9090
  }
}
