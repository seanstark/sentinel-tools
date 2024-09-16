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

> The logic app will run once a day by default

1. [<img src="https://aka.ms/deploytoazurebutton" width=12% height=12%>](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2FAzure%2520Activity%2Fazuredeploy-update-AzureRBACRolesWatchlist.json)

2. Assign the **Microsoft Sentinel Contributor** role to the logic app system assigned managed identity

## KQL Queries

| Query | Description |
|---|---|
| [Azure RBAC Role Assignments](./Azure%20RBAC%20Role%20Assignments.kql)| Gets Azure RBAC role changes |
| [Azure RBAC Role Assignments with IdentityInfo](./Azure%20RBAC%20Role%20Assignments%20with%20IdentityInfo.kql)| Gets Azure RBAC role changes and assigned identity information from the IdentityInfo table. Requires UEBA |
| [Azure RBAC Role Assignments with IdentityInfo and Roles](./Azure%20RBAC%20Role%20Assignments%20with%20IdentityInfo%20and%20Roles.kql)| Gets Azure RBAC role changes, assigned identity information from the IdentityInfo table and role information from the AzureRoles watchlist. Requires UEBA and the logic app |
