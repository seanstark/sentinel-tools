
# Microsoft Sentinel Defender for Cloud Data Connector At Scale

> :warning: **Work In Progress**

This workflow will enable the Microsoft Defender for Cloud data connector in Microsoft Sentinel automatically for all subscriptions you have the logic app scoped to. Refer to the Logic App Overview for more details.

- [Requirements](#requirements)
- [Setup and Configuration](#setup-and-configuration)
  - [Create a Custom Role](#create-a-custom-role)
  - [Deploy the Logic App](#deploy-the-logic-app)
  - [Authorize Permissions](#authorize-permissions)
  - [Assign the Role to the Logic App System Managed Identity](#assign-the-role-to-the-logic-app-system-managed-identity)
- [Logic App Overview](#logic-app-overview)


## Requirements

- The custom role described in [Create a Custom Role](##create-a-custom-role)
- Rights to assign the role and scope to either subscriptions or management groups

## Setup and Configuration

### Create a Custom Role
I highly reccomend creating the custom role to follow the principle of least privilege. 
There is no need to assign the built-in roles that provide more permissions than required. 

1. Follow the steps outline in [Create or update Azure custom roles using the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal#start-from-scratch)

2. For the role definition use the [custom role defintion](https://github.com/seanstark/sentinel-tools/blob/main/enable-sentinel-mdfc-sub-con/custom-role.json)

### Deploy the Logic App

### Authorize Permissions


### Assign the Role to the Logic App System Managed Identity
If you can't use the custom role you will need to assign the System Managed Identity the Security Admin and Microsoft Sentinel Contributor. 

## Logic App Overview
