#
# Variables Configuration
#

variable "cluster-name" {
  type = string
}

variable "aws_region" {
  default     = "ap-southeast-2"
  type        = string
  description = "aws region"
}
