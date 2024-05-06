#========= Basic =========
variable "identifier" {
  type = string
  default = ""
  description = "Unique identifier associated with this module. Default to empty string"
}

variable "region" {
  type = string
  description = "Name of the AWS region where this module is deployed to. Default to us-east-1"
  default = "us-east-1"
}


#========= Networking =========
variable "private_subnet_name" {
  type        = string
  description = "Private Subnet Name"
}

variable "vpc_name" {
  type        = string
  description = "Related VPC name"
}


#========= Atlassian Confluence Related =========
variable "confluence_url" {
  type        = string
  description = "Value of the confluence full URL. Per example: https://mydomain.atlassian.net/wiki"
}

variable "confluence_spaces" {
  type        = list(string)
  description = "List of Confluence spaces name to be downloaded"
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


#========= AWS Bedrock Related =========
variable "knowledge_base_name" {
  type = string
  description = "Name of the AWS Bedrock Knowledge Base containing the knowledge of the related confluence spaces. Default to 'atlassian-confluence-spaces'"
  default = "atlassian-confluence-spaces"
}
