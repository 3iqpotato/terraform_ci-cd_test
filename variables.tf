# Resource Group
variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "resource_group_location" {
  type        = string
  description = "Location of the Resource Group"
}

# App Service Plan
variable "app_service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "os_type" {
  type        = string
  description = "Operating system type for the App Service Plan"
}
# Web App
variable "web_app_name" {
  type        = string
  description = "Name of the Web App"
}

# SQL Server
variable "sql_server_name" {
  type        = string
  description = "Name of the SQL Server"
}

variable "sql_admin_login" {
  type        = string
  description = "Administrator login for SQL Server"
}

variable "sql_admin_password" {
  type        = string
  description = "Administrator password for SQL Server"
  sensitive   = true
}

# SQL Database
variable "sql_database_name" {
  type        = string
  description = "Name of the SQL Database"
}

# Firewall Rule
variable "firewall_rule_name" {
  type        = string
  description = "Name of the Firewall Rule"
}

# GitHub Deployment Repo
variable "github_repo_url" {
  type        = string
  description = "GitHub repository URL for source control deployment"
}
