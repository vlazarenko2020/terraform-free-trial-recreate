
variable "login_name" {
  type        = string
  description = "The login name for the Snowflake user"
}

variable "first_name" {
  type        = string
  description = "The first name of the user"
}

variable "middle_name" {
  type        = string
  default     = "" # Optional field with a default
  description = "The middle name of the user"
}

variable "last_name" {
  type        = string
  description = "The last name of the user"
}

variable "email" {
  type        = string
  description = "The email address for the user"
}

variable "password" {
  type        = string
  description = "Initial password for the user"
  sensitive   = true
}
variable "organization_name" {
  type        = string
  description = "Snowflake organization name"
}

variable "account_name" {
  type        = string
  description = "Snowflake account name"
}

variable "snowflake_user" {
  type        = string
  description = "Service user Terraform authenticates as"
}

variable "private_key_path" {
  type        = string
  description = "Path to the PKCS#8 private key for key-pair auth"
}
