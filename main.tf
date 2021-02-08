module "tomcat_container" {
  source = "./musicstore"
  password=var.pass
}

 module "testing_containers" {
  source = "./seleniumtest"
} 
  
variable "pass" {
  type = string
}
