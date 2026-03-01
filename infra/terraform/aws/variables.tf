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

variable "public_subnet_ids" {
  type    = list(string)
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

// Image URIs provided by CI (empty by default for PR-safe validation)
variable "python_image" {
  type        = string
  description = "Container image URI for the Python service (passed from CI)."
  default     = ""
}

variable "node_image" {
  type        = string
  description = "Container image URI for the Node service (passed from CI)."
  default     = ""
}

variable "python_container_port" {
  type    = number
  default = 3000
}

variable "node_container_port" {
  type    = number
  default = 3000
}

variable "desired_count" {
  type    = number
  default = 1
}
