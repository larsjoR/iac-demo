variable "clientSecret" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "prefix" {
  type        = string
  description = "The prefix used for all resources in this example. E.g. a customer shortname or project name."
}

variable "location" {
  default     = "westeurope"
  type        = string
  description = "The Azure location where all resources in this example should be created"
}

variable "environment" {
  type        = string
  description = "The environment in which resources should be deployed"
}

variable "suffix" {
  type        = string
  description = "The suffix used for all resources in this example."
}
