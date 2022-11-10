
# Sentinel Defender for Cloud Data Connector At Scale

## Requirements

- The custom role described in [Create a Custom Role](##create-a-custom-role)
- Rights to assign the role and scope to either subscriptions or management groups

## Create a Custom Role
I highly reccomend creating the custom role to follow the principle of least privilege. 
There is no need to assing the built-in roles that provide more permissions than required. 

1. Follow the steps outline in [Create or update Azure custom roles using the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal#start-from-scratch)

2. For the role definition use the [custom role defintion](https://github.com/seanstark/sentinel-tools/blob/main/enable-sentinel-mdfc-sub-con/custom-role.json)

## Deploy the Logic App


## Assign the Role to the Logic App System Managed Identity
If you can't use the custom role you will need to assign the System Managed Identity the Security Admin and Microsoft Sentinel Contributor. 

