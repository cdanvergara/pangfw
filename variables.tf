variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "rg" {
  type        = string
  description = "Resource group name for new resources"
}

variable "existing_vwan_rg" {
  type        = string
  description = "Resource group name where existing vWAN resources are located"
}

variable "existing_vwan_name" {
  type        = string
  description = "Name of the existing Virtual WAN"
}

variable "existing_vhub_eastus_name" {
  type        = string
  description = "Name of the existing Virtual Hub in East US"
}

variable "existing_vhub_centralus_name" {
  type        = string
  description = "Name of the existing Virtual Hub in Central US"
}

variable "region1" {
  type = string
}

variable "region2" {
  type = string
}

variable "panorama-string" {
  type = string
}