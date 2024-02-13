
## Solution Overview
This solution will stream [audit logs](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/about-the-audit-log-for-your-enterprise) from GitHub Enterprise for all organizations to an Azure Event Hub. Events that are sent to the Event Hub will then be ingested to the Microsoft Sentinel workspace via the method documented here - [Ingest events from Azure Event Hubs into Azure Monitor Logs](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub)

> This solution also avoids any of the rate limits imposed with directly pulling audit logs from the rest api and exposing any PAT tokens from GitHub

## Requirements
To send events from Azure Event Hubs to Sentinel you wil require the below

- Log Analytics workspace where you have at least contributor rights.
- Your Log Analytics workspace needs to be linked to a **dedicated cluster** or to have a **commitment tier**.
- Event Hubs namespace that permits public network access. Private Link and Network Security Perimeters (NSP) are currently not supported.
- ❗The Event Hub must be in a **supported region** documented here [Supported Regions](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub#supported-regions). 

## Step 1 - Deploy the Event Hub
> ❗The Event Hub must be in a supported region documented here [Supported Regions](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub#supported-regions). West US 2 is not supported.

1. [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2FGitHubAuditLogs%2Feventhub.json)

2. Collect the following information from the Event Hub
3. Navigate to the Event Hub Namespace **Event Hubs** > Select the **Event Hub** (githubauditlogs)
4. Copy down the Event Hub instance name, which should be githubauditlogs by default
   
   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/316fe9bd-605c-4c87-a62c-9021996587b6)

6. Select **Shared access policies** and select the **githubauditlogsSend** policy
   
   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/b283f50f-c2e2-44d9-b26c-58c606791579)

8. Copy down the Connection string–primary key in a safe location

## Step 2 - Create the Data Collection Endpoint and Data Collection Rule


## Step 3 - Configure GitHub Enterprise
> Steps 2 is optional but recommend

1. From the [GitHub Enterprise](https://github.com/enterprises) navigate to **Settings** > **Audit Log**
2. Navigate to the **Settings** tab, turn on **Enable source IP disclosure** and **Enable API Request Events**
   
   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/a5c4d65a-67a6-4c69-9f61-1ae04b2f3a1b)

4. Navigate to the **Log Streaming** tab
5. Enter your **Azure Event Hubs Instance** name and **Connection String** collected from **Step 1**
   
   ![image](https://github.com/seanstark/sentinel-tools/assets/84108246/6d2a63d3-bfa1-4824-826d-7053648ff9bc)

## Step 4 - Verify Logs
1. After Step 1 - 3 are completed you should see events hitting your Event Hub Namespace and logs in your log analytics workspace
