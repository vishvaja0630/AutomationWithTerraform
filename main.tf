module "tomcat_container" {
  source = "./musicstore"
  password=var.pass
}

 module "testing_containers" {
  source = "./seleniumtesting"
} 
  
variable "pass" {
  type = string
}
