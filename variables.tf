variable "private_subnet_name" {
  type        = string
  description = "Private Subnet Name"
}

variable "vpc_name" {
  type        = string
  description = "Related VPC name"
}

variable "confluence_url" {
  type        = string
  description = "Value of the confluence full URL. Per example: https://mydomain.atlassian.net/wiki"
}

variable "confluence_space" {
  type        = string
  description = "Value of the Confluence space to be downloaded"
}

variable "access_token" {
  type        = string
  description = "Username Token in order to access the confluence space"
  sensitive   = true
}

variable "secret_token" {
  type        = string
  description = "Secret Token in order to access the confluence space"
  sensitive   = true
}
