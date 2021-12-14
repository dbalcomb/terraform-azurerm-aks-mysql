variable "name" {
  description = "The service name"
  type        = string
}

variable "region" {
  description = "The target region"
  type        = string
}

variable "size" {
  description = "The storage size in GB"
  type        = number
  default     = 64
}

variable "cluster" {
  description = "The cluster configuration"
  type = object({
    service_principal = object({
      id = string
    })
  })
}
