variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "stage_name" {
  default     = "dev"
  description = "Current stage name of infra."
  validation {
    condition     = contains(["dev", "stg", "prod"], var.stage_name)
    error_message = "Variable 'stage_name' should be either 'dev', 'stg', 'prod'"
  }
}