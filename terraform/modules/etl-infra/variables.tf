variable "project_id" {
  description = "The full project name"
  type        = string
  default     = ""
}

variable "service_account" {
  description = "The email address for the service account to grant access to resources"
  type        = string
  default     = ""
}

variable "user_email" {
  description = "The email address for a user to grant access to resources"
  type        = string
  default     = ""
}