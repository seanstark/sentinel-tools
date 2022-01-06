# Creating Scheduled Analytics Rules From Templates


## Overview
**create-scheduledRuleFromTemplate.ps1** is a powershell script you can leverage to import (create) multiple scheduled analytics rules from the [Sentinel Github rule template repository](https://github.com/Azure/Azure-Sentinel/tree/master/Detections)

This script was written to account for current limitations when leveraging the **Az.Sentinel** or **Az.SecurityInsights** powershell modules. Most of which are related to an incomplete set of properties being resturned such as tactics and techniques from the API endpoints. 

## Features

- Create multiple scheduled analytics rules from rule templates
- Filter rule templates on severity, tactics, techniques, and data connectors
- Run in report only mode to output templates based on the filters you defined
- Create rules from templates in a enabled or disabled state

## Known Limitations

- Associated tables in the rule query need to exist first for the rule to be created. Tables are generally created when you start ingesting data. If the table does not exist the rule creation will fail during the script run
- YAML files in the github repo may have incorrect query column to entity mappings defined. The rule creation will fail during the script run. If you run across either sumbit an issue via github on the YAML file or fork the github repo and submit a pull request - https://github.com/Azure/Azure-Sentinel#contributing
- A fair number of rule templates do not have values for required data connectors. Be aware when using the dataconnector filter parameter you may not get a complete list of rules that leverage associated tables



## Configuration Requirements




## Running the Script

> Note: `-githubToken` example is not a valid token

Create rules from all templates
```powershell
$rules = .\create-scheduledRuleFromTemplate.ps1 -subscriptionId 'ada06e68-375e-4564-be3a-c6cacebf41c5' -resourceGroupName 'sentinel-prd' -workspaceName 'sentinel-prd' -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd'
```

