provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Data source for existing vWAN resources
data "azurerm_virtual_wan" "existing_vwan" {
  name                = var.existing_vwan_name
  resource_group_name = var.existing_vwan_rg
}

data "azurerm_virtual_hub" "existing_vhub_eastus" {
  name                = var.existing_vhub_eastus_name
  resource_group_name = var.existing_vwan_rg
}

data "azurerm_virtual_hub" "existing_vhub_centralus" {
  name                = var.existing_vhub_centralus_name
  resource_group_name = var.existing_vwan_rg
}

# Resource group for new Cloud NGFW resources
resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.region1
}

resource "azurerm_public_ip" "cngfw-pip-eastus" {
  name                = "cngfw-pip-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region1
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "cngfw-pip-westeu" {
  name                = "cngfw-pip-westeu"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region2
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_palo_alto_virtual_network_appliance" "nva-eastus" {
  name           = "terraform-nva-eastus"
  virtual_hub_id = data.azurerm_virtual_hub.existing_vhub_eastus.id
}

resource "azurerm_palo_alto_virtual_network_appliance" "nva-centralus" {
  name           = "terraform-nva-centralus"
  virtual_hub_id = data.azurerm_virtual_hub.existing_vhub_centralus.id
}

resource "azurerm_palo_alto_local_rulestack" "lrs-eastus" {
  name                  = "terraform-lrs-eastus"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.region1
  anti_spyware_profile  = "BestPractice"
  anti_virus_profile    = "BestPractice"
  file_blocking_profile = "BestPractice"
  vulnerability_profile = "BestPractice"
  url_filtering_profile = "BestPractice"
}

resource "azurerm_palo_alto_local_rulestack" "lrs-centralus" {
  name                  = "terraform-lrs-centralus"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.region2
  anti_spyware_profile  = "BestPractice"
  anti_virus_profile    = "BestPractice"
  file_blocking_profile = "BestPractice"
  vulnerability_profile = "BestPractice"
  url_filtering_profile = "BestPractice"
}

resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "cngfw-eastus" {
  name                = "terraform-cngfw-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.lrs-eastus.id
  marketplace_offer_id = "pan_swfw_cloud_ngfw"
  plan_id             = "paloaltonetworks-ngfw-byol"

  network_profile {
    public_ip_address_ids        = [azurerm_public_ip.cngfw-pip-eastus.id]
    virtual_hub_id               = data.azurerm_virtual_hub.existing_vhub_eastus.id
    network_virtual_appliance_id = azurerm_palo_alto_virtual_network_appliance.nva-eastus.id
  }
}

resource "azurerm_virtual_hub_routing_intent" "routing-intent-eastus" {
  name           = "terraform-routing-intent-eastus"
  virtual_hub_id = data.azurerm_virtual_hub.existing_vhub_eastus.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_palo_alto_virtual_network_appliance.nva-eastus.id
  }

  routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_palo_alto_virtual_network_appliance.nva-eastus.id
  }
  depends_on = [azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.cngfw-eastus]
}

resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "cngfw-centralus" {
  name                = "terraform-cngfw-centralus"
  resource_group_name = azurerm_resource_group.rg.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.lrs-centralus.id
  marketplace_offer_id = "pan_swfw_cloud_ngfw"
  plan_id             = "panw-cloud-ngfw-payg"

  network_profile {
    public_ip_address_ids        = [azurerm_public_ip.cngfw-pip-westeu.id]
    virtual_hub_id               = data.azurerm_virtual_hub.existing_vhub_centralus.id
    network_virtual_appliance_id = azurerm_palo_alto_virtual_network_appliance.nva-centralus.id
  }
}

resource "azurerm_virtual_hub_routing_intent" "routing-intent-centralus" {
  name           = "terraform-routing-intent-centralus"
  virtual_hub_id = data.azurerm_virtual_hub.existing_vhub_centralus.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_palo_alto_virtual_network_appliance.nva-centralus.id
  }

  routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_palo_alto_virtual_network_appliance.nva-centralus.id
  }
  depends_on = [azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.cngfw-centralus]
}
