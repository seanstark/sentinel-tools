Configure cross-tenant logging of Azure Activity Logs to centralized log analytics workspace using Azure Lighthouse

# Step 1 - Deploy the Logic App
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2Fcross-tenant-logging%2Fazure-activity-logs%2Fazuredeploy.json)

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

# Step 2 - Configure Azure Lighthouse
