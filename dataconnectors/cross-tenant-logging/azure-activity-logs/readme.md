# Azure Activity Logs Cross Tenant Logging

- [Solution Overview](#solution-overview)
- [Step 1 - Deploy the Logic App](#step-1-deploy-the-logic-app)
- [Step 2 - Configure the Logic App](#step-2-configure-the-logic-app)
- [Step 3 - Configure Azure Lighthouse](#step-3-configure-azure-lighthouse)
- [Step 4 - Test The Logic App](#step-4-test-the-logic-app)

# Solution Overview
This solution will configure cross-tenant logging of Azure Activity Logs to a centralized log analytics workspace in a primary tenant's workspace using Azure Lighthouse delegated roles. The overall steps are to deploy the logic app in the tenant hosting the log analytics workspace and then deploy an Azure Lighthouse delegation to all other tenants to allow the logic app to create the logging profile. 

- The logic app runs once a day by default
- The logic app will configure Azure Activity logs on any subscription where the system assigned managed identity has been delegated rights to

# Step 1 - Deploy the Logic App

1. Deploy this in the tenant hosting the log analytics workspace
   
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2Fcross-tenant-logging%2Fazure-activity-logs%2Fazuredeploy.json)

> ⚠️ Make you specify the full log analytics workspace resource id. Example: /subscriptions/\<subscriptionId\>/resourcegroups/\<resourceGroupName\>/providers/microsoft.operationalinsights/workspaces/\<workspaceName\>

# Step 2 - Configure the Logic App
1. Navigate to **Logic App** > **Identity** Section
2. Confirm a system assigned managed identity was created and **copy** the **Object (principal) ID**
3. Click **Azure role assignments**
4. Click **Add role assignment**
5. For the Scope select **Resource Group**
6. Select the **Subscription** and **Resource Group** where your **Sentinel Workspace** Resides
7. Select the **Log Analytics Contributor Role**

  > ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/cbdd69b1-518d-46f6-a80b-6b4cfb68b2c8)

8. Select **Save**
> ℹ️ If you would like the logic app to also configure logging in the current tenant add the **Monitoring Contributor** role to applicable subscriptions or managment groups in the current tenant

# Step 3 - Configure Azure Lighthouse
1. From the Azure Portal navigate to **Azure Lighthouse**
2. Select **Manage your customers**
3. Select **Create ARM Template**
4. Enter a **name** for the Azure Lighthouse offer (Sentinel Cross Tenant Logging)
5. Enter a **description** (Configures Cross Tenant Logging of Azure resource provider logs to Sentinel)
6. For the **Delegate scope** select **Subscription**
7. Click Add Authorization
8. Select **Service principal** and select the **system assigned managed identity of the logic app**

>![image](https://github.com/seanstark/sentinel-tools/assets/84108246/4e47777a-13d7-4d06-a7ff-97775ff13fa6)

9. Select the **Monitoring Contributor** role
10. Select **Permanent** for the Access Type

>![image](https://github.com/seanstark/sentinel-tools/assets/84108246/ea5b5988-6272-4bdf-9192-dab9cf64a067)

11. Click **Add**
12. Click **View Template**
13. Next deploy the ARM template to your other Tenant Subscriptions

# Step 4 - Test The Logic App
1. Navigate to **Logic App** > Select Run
2. Wait for the Logic App run to complete and verify the diagnostics settings were configured
