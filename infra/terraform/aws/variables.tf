variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  type = list(string)
  default = []
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "exampledb"
}

variable "db_identifier" {
  type    = string
  default = "example-db-instance"
}

variable "db_username" {
  type    = string
  default = "exampleuser"
}

variable "db_password" {
  type      = string
  default   = "changeme"
  sensitive = true
}
