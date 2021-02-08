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
#credentials for docker hub
  registry_auth {
    address = "registry.hub.docker.com"
    username = "vishvajafaldesai"
    password = var.password
  }
}

#creation of image using dockerfile with name dockerisedtomcat and publish to docker hub id vishvajafaldesai
resource "docker_image" "dockerisedtomcat" {
  name = "vishvajafaldesai/dockerisedtomcat:latest"
  build {
      path="."
  }
}

#creation of container dockerisedtomcatcontainer using image dockerisedtomcat and running the container on port 9093
resource "docker_container" "dockerisedtomcatcontainer" {
  name  = "dockerisedtomcatcontainer"
  image = docker_image.dockerisedtomcat.latest
  must_run = true
  ports {
    internal = 8080
    external = 9093
  }
}

variable "password" {
  type = string
}
