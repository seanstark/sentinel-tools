# GitHub Enterprise Audit Logs Sentinel CCP

- [Solution Overview](#solution-overview)
  * [Step 1 - Deploy the Data Connector](#step-1---deploy-the-data-connector)
  * [Step 2 - Configure GitHub Enterprise](#step-2---configure-github-enterprise)
  * [Step 3 - Create a GitHub Personal Access Token](#step-3---create-a-github-personal-access-token)
  * [Step 4 - Configure the Sentinel Data Connector](#step-4---configure-the-sentinel-data-connector)

# Solution Overview
This solution will ingest audit logs from GitHub Enterprise for all organizations to Microsoft Sentinel using the Codeless Connector Platform data connector. The data will end up in the **GitHubEntAuditLogPolling_CL** table.
> ⚠️ If you are using IP Restrictions in GitHub you will need to whitelist the CIDR ranges for CCP under the **SCUBA** tag here - [Home Page - Azure IP Ranges](https://azureipranges.azurewebsites.net/)

## Step 1 - Deploy the Data Connector
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2FGitHubAuditLogs%2FCCP%2FGitHubAuditLogs_CCP.json)

## Step 2 - Configure GitHub Enterprise
> This step is optional but recommend

1. From the [GitHub Enterprise](https://github.com/enterprises) navigate to **Settings** > **Audit Log**
2. Navigate to the **Settings** tab, turn on **Enable source IP disclosure** and **Enable API Request Events**
   
   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/a5c4d65a-67a6-4c69-9f61-1ae04b2f3a1b)

## Step 3 - Create a GitHub Personal Access Token
You will need a GitHub personal access token to enable polling for the Enterprise audit log. You need to use a **classic token**; you must be an enterprise admin and you must use an access token with the **read:audit_log** scope

1. In the upper-right corner of any page, click your profile photo, then click **Settings**
2. In the left sidebar, click **Developer settings**
3. In the left sidebar, click **Personal access tokens** > **Tokens (classic)**
4. Click **Generate new token (classic)**
5. Give the token a name and add the **read:audit_log** scope
6. Copy the access token to a safe location

## Step 4 - Configure the Sentinel Data Connector
1. From Microsoft Sentinel navigate to **Data Connectors**
2. You should see a **GitHub Enterprise Audit Log (Preview)** data connector, click ***Open connector page**
3. Enter your **enterprise name** and **GitHub personal access token** in the **API Key** field. Click **Connect**
4. Generally the intial data will show up in the **GitHubEntAuditLogPolling_CL** table around 20 minutes after the data connector is configured
