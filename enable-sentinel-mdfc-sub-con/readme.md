
# Microsoft Sentinel Defender for Cloud Data Connector At Scale

> :warning: **Work In Progress**

This workflow will enable the Microsoft Defender for Cloud data connector in Microsoft Sentinel automatically for all subscriptions you have the logic app scoped to. Refer to the Logic App Overview for more details.

- [Requirements](#requirements)
- [Setup and Configuration](#setup-and-configuration)
  - [Create a Custom Role](#create-a-custom-role)
  - [Deploy the Logic App](#deploy-the-logic-app)
  - [Authorize Permissions](#authorize-permissions)
  - [Assign the Role to the Logic App System Managed Identity](#assign-the-role-to-the-logic-app-system-managed-identity)
- [Working with Parameters](#working-with-parameters)
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
Most of the logic leverages the System Managed Identity to perform tasks. However if you plan on sending email notifications you will need to authorize the Office 365 Outlook connector.

### Assign the Role to the Logic App System Managed Identity
If you can't use the custom role you will need to assign the System Managed Identity the Security Admin and Microsoft Sentinel Contributor. In the example below the role is assigned at the root managment group level. 

### Working with Parameters

There are several parameters you can update in the logic app

1. Navigate to the Logic App in the Azure Portal and select Logic App Designer
2. Select Parameters
3. Update the parameter according to the table below
4. Make sure to the Save the Logic App

|  Parameter      |         Use Case             | Type |     Value Example            |
|----------------|-------------------------------|------| -----------------------------|
| emailRecipients | Email Addresses to send notifications to. Semi-colon seperated values | string | ``` user1@domain.com;dl@domain.com ``` |
| excludedSubscriptions | Exclude subscriptions from being enabled | array | ``` ["ada06e68-375e-4210-b43a-c6fgdcebf41c5","ada0dht8-375e-4210-be3a-c6cacebf41c5"] ``` |
| logResults | Log results to your Sentinel Workspace | boolean | ``` true or false ``` |
| sendEmail | Send email notifications on subscriptions that were enabled | boolean | ``` true or false ``` |
| sentinel-resourcegroupname | The reource group name where Sentinel Resides | string | ``` sentinel-prd ``` |
| sentinel-subscriptionid | The subscription ID where Sentinel resides | string | ``` ada06e68-375e-4210-b43a-c6fgdcebf41c5 ``` |
| sentinel-workspacename | The workspace name of Sentinel | string | ``` sentinel-wrk-prd ``` |

## Logic App Overview
The Logic app runs on a re-occuring schedule every 12 hours by default. The overall sequence of events are as follows.

1. Trigger every 12 hours
2. Initialize Variables
3. List all Subscriptions in the Tenant.
4. Optional - Filter out Excluded Subscriptions you have defined
5. Enable Bi-Directional Alert Sync from Defender for Cloud
6. Register the Microsoft.Security resource prodiver on the Subscription
7. Enable the Data Connector for the subscription
8. Optional - Log results to Log Analytics
9. Optional - Send an email notificaiton 



