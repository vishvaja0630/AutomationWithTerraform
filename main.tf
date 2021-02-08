module "tomcat_container" {
  source = "./musicstore"
  password=var.pass
}

 module "testing_containers" {
  source = "./testing"
} 
  
variable "pass" {
  type = string
}
