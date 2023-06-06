# Exporting Scheduled Analytics Rules From Templates
You can export all rules from from the [Sentinel Github rule template repository](https://github.com/Azure/Azure-Sentinel) using the export-analyticRuleTemplates.ps1 script

- [Configuration Requirements](#configuration-requirements)
  * [Github Personal Access Token](#github-personal-access-token)
- [Example](#example)

## Example
```powershell
$rules = .\export-analyticRuleTemplates.ps1 -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd'

$rules | Export-Csv C:\analyticrules.csv

```

# Creating Scheduled Analytics Rules From Templates

- [Overview](#overview)
- [Features](#features)
- [Known Limitations](#known-limitations)
- [Configuration Requirements](#configuration-requirements)
  * [Github Personal Access Token](#github-personal-access-token)
  * [Required PowerShell Modules](#required-powershell-modules)
  * [Required Sentinel Roles](#required-sentinel-roles)
- [Running the Script](#running-the-script)
    + [Create rules from all templates](#create-rules-from-all-templates)
    + [Create rules from all templates in a disabled state](#create-rules-from-all-templates-in-a-disabled-state)
    + [Create rules from all templates with "TI map" in the name](#create-rules-from-all-templates-with-"ti-map"-in-the-name)
    + [Open a UI where you can further select specific rules to import](#open-a-ui-where-you-can-further-select-specific-rules-to-import)
    + [Run in report only mode](#run-in-report-only-mode)
    + [Filter by detection child folder name](#filter-by-detection-child-folder-name)
    + [Filter by severity of alert rule templates](#filter-by-severity-of-alert-rule-templates)
    + [Filter by severity and tactics of alert rule templates](#filter-by-severity-and-tactics-of-alert-rule-templates)
	+ [Filter by tags](#filter-by-tags)
	
## Overview
[**create-scheduledRuleFromTemplate.ps1**](/analytics_rules/create-scheduledRuleFromTemplate.ps1) is a PowerShell script you can leverage to import (create) multiple scheduled analytics rules from the [Sentinel Github rule template repository](https://github.com/Azure/Azure-Sentinel/tree/master/Detections) and from Analytics rules in the [Solutions folder](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions)

This script was written to account for current limitations when leveraging the **AzSentinel** or **Az.SecurityInsights** PowerShell modules. Most of which are related to an incomplete set of properties being returned such as tactics and techniques from the API endpoints. 

## Features

- Create multiple scheduled analytics rules from rule templates
- Filter rule templates on name, severity, tactics, techniques, tags, datatypes, queries, and data connectors
- Run in report only mode to output templates based on the filters you defined
- Create rules from templates in an enabled or disabled state
- Open an out-gridview UI to further select specific rules to import

## Known Limitations

- Associated tables in the rule query need to exist first for the rule to be created. Tables are generally created when you start ingesting data. If the table does not exist the rule creation will fail during the script run
- YAML files in the github repo may have incorrect query column to entity mappings defined. The rule creation will fail during the script run. If you run across either submit an issue via github on the YAML file or fork the github repo and submit a pull request - https://github.com/Azure/Azure-Sentinel#contributing
- A fair number of rule templates do not have values for required data connectors. Be aware when using the dataconnector filter parameter you may not get a complete list of rules that leverage associated tables
- YAML file definitions continue to evolve, new attributes such as tags do not persist across all rule templates. Be aware when using some of these filters you may not get an accurate result

## Configuration Requirements

### Github Personal Access Token
You will need to setup a GitHub **personal access token** in order for the PowerShell script to gather the rule template details. This is required to avoid GitHub API limits. 

1. Navigate to https://github.com/settings/tokens/new
2. Generate a new token with the public_repo scope
3. I would also recommend setting the expiration to 7 days
4. Copy the generated token value for use the **-githubToken** parameter

> ![GitHub PAT](/images/github_pat.png)

### Required PowerShell Modules
The script will check and install any missing modules. For reference the below is required
- PowerShellForGitHub 
- Az.Accounts 
- Az.SecurityInsights 
- powershell-yaml

### Required Sentinel Roles
- Microsoft Sentinel Contributor 

## Running the Script
Below are some examples on running the script. In the examples below the script output is assigned to a variable $rules. 
I would recommend assigning the script output to a variable to easily review the results as some rule creations may fail.

```powershell
$rules | Where created -eq $false | Select ruleName, created, errorCode, errorMessage

$rules | Where created -eq $true

```

> Rules will be created in an **enabled** state by default

> Note: `-githubToken` example is not a valid token

### Create rules from all templates
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd'
```
### Create rules from all templates in a disabled state
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd' -enabled $false
```
### Create rules from all templates with "TI map" in the name
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd' -name '*TI map*
```
### Open a UI where you can further select specific rules to import
The below example will open an out-grid UI where you can further select specific rules to import
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2pOUmy4P0Rb3yd' -selectUI
```
### Run in report only mode
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2pOUmy4P0Rb3yd' -reportOnly

$rules | Select name, severity, tactics, techniques, requiredDataConnectors, templateURL
```
### Filter by detection or solution child folder Name
```powershell
 $rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2EOUmy4P0Rb3yd' -detectionFolderName 'ASimAuthentication','ASimProcess'
```
### Filter by severity of alert rule templates
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2EOUmy4P0Rb3yd' -detectionFolderName 'ASimAuthentication','ASimProcess'
```
### Filter by severity and tactics of alert rule templates
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2pOUmy4P0Rb3yd' -severity 'High','Medium'
```
### Filter by tags
The below example returns all templates tagged with Log4j
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFoK5B2pOUmy4P0Rb3yd' -tag 'Log4j'
```
