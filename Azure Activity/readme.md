# Azure Activity RBAC Hunting and Enrichment
This page contains a collection KQL queries and enrichment automation to hunt for Azure RBAC changes. 

## Current Challenges
The Azure Activity logs currently only contain GUIDs of Azure RBAC roles and identities. Furthermore, RBAC changes are represented in two separate events in the logs. This solution provides data enrichment using:
- Logic App to pull in Azure Role Information
- KQL Queries to pull in Identity information from the UEBA tables
- Logic App to pull in Identity information from Entra ID

## Data Enrichment

### update-AzureRBACRolesWatchlist
The update-AzureRBACRolesWatchlist logic gets current role defintions in your tenant and creates/updates a watchlist with role definitions.

### Step 1 - Deploy the Logic App
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2FAzure%2520Activity%2Fazuredeploy-update-AzureRBACRolesWatchlist.json)

### Step 2 - Assign Roles to the system assigned managed identity

## KQL Queries

