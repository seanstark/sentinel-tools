# Azure Activity RBAC Hunting and Enrichment
This page contains a collection KQL queries and enrichment automation to hunt for Azure RBAC changes. 

## Current Challenges
The Azure Activity logs currently only contain GUIDs of Azure RBAC roles and identities. Furthermore, RBAC changes are represented in two separate events in the logs. This solution provides data enrichment using:
- Logic App to pull in Azure Role Information
- KQL Queries to pull in Identity information from the UEBA tables
- Logic App to pull in Identity information from Entra ID

## Data Enrichment

## KQL Queries

