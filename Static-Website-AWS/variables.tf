variable "region" {
  description = "Specified region name for resource creation in it."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "my bucket name"
  type        = string
  default     = "ckterraform"
}

variable "bucket_owner" {
  description = "Specify bucket ownership controls"
  type        = string
  default     = "BucketOwnerPreferred"
}