# Palo Alto Cloud NGFW on Azure Virtual WAN

This Terraform template deploys Palo Alto Cloud Next Generation Firewall (NGFW) on existing Azure Virtual WAN infrastructure.

## Overview

This template creates:
- Palo Alto Local Rulestacks in two regions (East US and Central US)
- Cloud NGFW instances in both regions
- Virtual Network Appliances for each region
- Routing intents to direct traffic through the firewalls
- Public IP addresses for the firewalls

## Prerequisites

1. **Azure Subscription with Payment Method**: Required for Palo Alto marketplace resources
2. **Existing Virtual WAN Infrastructure**: 
   - Virtual WAN
   - Virtual Hubs in both regions
3. **Registered Resource Providers**:
   - `PaloAltoNetworks.Cloudngfw`
   - `Microsoft.Network`
4. **Marketplace Terms Acceptance**: Accept Palo Alto Cloud NGFW marketplace terms

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/cdanvergara/pangfw.git
cd pangfw
```

### 2. Configure Variables
Copy the example tfvars file and update with your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `subscription_id`: Your Azure subscription ID
- `existing_vwan_rg`: Resource group containing your Virtual WAN
- `existing_vwan_name`: Name of your Virtual WAN
- `existing_vhub_eastus_name`: Name of your East US Virtual Hub
- `existing_vhub_centralus_name`: Name of your Central US Virtual Hub

### 3. Register Resource Providers
```bash
az provider register --namespace PaloAltoNetworks.Cloudngfw
az provider register --namespace Microsoft.Network
```

### 4. Accept Marketplace Terms
```bash
az vm image terms accept --publisher paloaltonetworks --offer pan_swfw_cloud_ngfw --plan panw-cloud-ngfw-payg
```

### 5. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `subscription_id` | Azure subscription ID | `"12345678-1234-1234-1234-123456789abc"` |
| `region1` | Primary region | `"eastus"` |
| `region2` | Secondary region | `"centralus"` |
| `rg` | Resource group for new resources | `"terraform-rg"` |
| `existing_vwan_rg` | Resource group with existing vWAN | `"existing-vwan-rg"` |
| `existing_vwan_name` | Existing Virtual WAN name | `"my-vwan"` |
| `existing_vhub_eastus_name` | Existing East US hub name | `"my-hub-eastus"` |
| `existing_vhub_centralus_name` | Existing Central US hub name | `"my-hub-centralus"` |

## Architecture

```
    Internet
       |
   [Public IPs]
       |
[Cloud NGFW Instances]
       |
  [Virtual Hubs]
       |
   [Virtual WAN]
       |
[Connected Networks]
```

## Important Notes

- **Subscription Requirements**: This template requires a subscription with marketplace spending enabled
- **Costs**: Cloud NGFW incurs charges - review pricing before deployment
- **Security**: Never commit real `terraform.tfvars` files with actual subscription IDs
- **Dependencies**: Virtual WAN and hubs must exist before running this template

## Troubleshooting

### Payment Method Error
```
Error: PaymentRequired: SaaS Purchase Payment Check Failed
```
**Solution**: Ensure your subscription has a valid payment method configured.

### Resource Provider Error
```
Error: MissingSubscriptionRegistration
```
**Solution**: Register the required resource providers as shown in setup instructions.

### Marketplace Terms Error
**Solution**: Accept the marketplace terms using the Azure CLI command provided above.

## Clean Up

To remove all resources:
```bash
terraform destroy
```

## Support

For issues with this template, please create an issue in this repository.
For Palo Alto Cloud NGFW specific issues, consult Palo Alto Networks documentation.
