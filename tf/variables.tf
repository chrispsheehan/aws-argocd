variable "instance_tenancy" {
  description = "it defines the tenancy of VPC. Whether it's default or dedicated"
  type        = string
  default     = "default"
}
variable "custom_vpc" {
  description = "Argo vpc"
  type        = string
  default     = "10.0.0.0/18"
}
