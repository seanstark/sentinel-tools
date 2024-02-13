
## Solution Overview
This solution will stream [audit logs](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/about-the-audit-log-for-your-enterprise) from GitHub Enterprise for all organizations to an Azure Event Hub. Events that are sent to the Event Hub will then be ingested to the Microsoft Sentinel workspace via the method documented here - [Ingest events from Azure Event Hubs into Azure Monitor Logs](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub)

> This solution also avoids any of the rate limits imposed with directly pulling audit logs from the rest api and exposing any PAT tokens from GitHub

## Requirements
To send events from Azure Event Hubs to Sentinel you wil require the below

- Log Analytics workspace where you have at least contributor rights.
- Your Log Analytics workspace needs to be linked to a dedicated cluster or to have a commitment tier.
- Event Hubs namespace that permits public network access. Private Link and Network Security Perimeters (NSP) are currently not supported.
- The Event Hub must be in a supported region documented here [Supported Regions](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub#supported-regions). 

## Step 1 - Deploy the Event Hub
> ⚠️ The Event Hub must be in a supported region documented here [Supported Regions](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/ingest-logs-event-hub#supported-regions). West US 2 is not supported.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fdataconnectors%2FGitHubAuditLogs%2Feventhub.json)

## Step 2 - Create the Data Collection Endpoint and Data Collection Rule


## Step 3 - Configure GitHub Enterprise
> Steps 2 is optional but reccomend

1. From the [GitHub Enterprise](https://github.com/enterprises) navigate to **Settings** > **Audit Log**
2. Navigate to the **Settings** tab, turn on **Enable source IP disclosure** and **Enable API Request Events**
3. Navigate to the **Log Streaming** tab
4. Enter your **Azure Event Hubs Instance** name and **Connection String** collected from **Step 1**
