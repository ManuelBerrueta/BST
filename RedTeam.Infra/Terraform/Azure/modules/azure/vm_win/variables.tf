variable "name" {
  type    = string
}

variable "location" {
  type    = string
  default = "WestUS"
}

variable "instance_count" {
  default = 1
}

variable "users" {
  type = list
}

variable "size" {
  default = "Standard_D4s_v3"
  #default = "Standard_D2s_v3"
}

variable "subnet_id" {
  type = string
}