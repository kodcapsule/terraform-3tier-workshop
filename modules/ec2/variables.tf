variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
  
}

variable "availability_zone" {
  description = "The availability zone to launch the instance in"
  type        = string
 
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "security_groups" {
  description = "The IDs of the security groups to associate with the instance"
  type        = list(string)
}