# Solution Overview
This solution will ingest audit logs from GitHub Enterprise for all organizations to Microsoft Sentinel using the Codeless Connector Platform data connector. The data will end up in the GitHubEntAuditLogPolling_CL table.

## Step 1 - Deploy the Data Connector
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2FGitHubAuditLogs%2FCCP%2FGitHubAuditLogs_CCP.json)

## Step 2 - Create a GitHub Personal Access Token
You will need a GitHub personal access token to enable polling for the Enterprise audit log. You need to use a classic token; you must be an enterprise admin and you must use an access token with the **read:audit_log** scope

1. In the upper-right corner of any page, click your profile photo, then click **Settings**
2. In the left sidebar, click **Developer settings**
3. In the left sidebar, click **Personal access tokens** > **Tokens (classic)**
4. Click **Generate new token (classic)**
5. Give the token a name and add the **read:audit_log** scope
6. Copy the access token to safe location

## Step 3 - Configure the Sentinel Data Connector
1. From Microsoft Sentinel navigate to **Data Connectors**
2. You should see a **GitHub Enterprise Audit Log (Preview)** data connector, click ***Open connector page**
3. Enter your **enterprise name** and **GitHub personal access token** in the **API Key** field. Click **Connect**
4. Generally the intial data will show up in the **GitHubEntAuditLogPolling_CL** table around 20 minutes after the data connector is configured
