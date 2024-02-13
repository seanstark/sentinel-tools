# Solution Overview
This solution will ingest audit logs from GitHub Enterprise for all organizations to Microsoft Sentinel using the Codeless Connector Platform data connector.

## Step 1 - Deploy the Data Connector
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2FGitHubAuditLogs%2FCCP%2FGitHubAuditLogs_CCP_beta.json)

## Step 2 - Create a GitHub Personal Access Token
1. In the upper-right corner of any page, click your profile photo, then click **Settings**
2. In the left sidebar, click **Developer settings**
3. In the left sidebar, click **Personal access tokens** > **Tokens (classic)**
4. Click **Generate new token (classic)**
5. Give the token a name and add the **read:audit_log** scope
