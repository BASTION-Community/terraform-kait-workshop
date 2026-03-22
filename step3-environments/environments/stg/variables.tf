# =============================================================================
# Variables - Stg Environment
# =============================================================================

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "stg"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "ap-northeast-2a"
}
