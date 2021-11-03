# Common
variable "tags" {
  type = map(string)

  default = {
    source      = "terraform"
    costcenter  = "733120"
    owner       = "daniel.meek.holter@atea.no"
    repo        = "https://github.com/dahol/tba"
    environment = "dev"
  }
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Location in which to create resources"
}

variable "nameprefix" {
  type        = string
  description = "Prefix used for resource naming"
  default     = "oslo"
}


# aks
variable "enable_auto_scaling_lnx" {
  type    = bool
  default = true
}
variable "vmadmin" {
  type    = string
  default = "daniel-prod-admin"
}
variable "prod_vnet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/20"]
}

variable "prod_node_snet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/24"]
}
