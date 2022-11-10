
# Overview
A breif intro to the various tools that reside here. 

> Are you looking for simplier Azure Policies for assigning data collection rules without all the image, region, and publisher policy rules? 
Check out [my policy repo](https://github.com/seanstark/Azure-Policy/tree/main/policyDefinitions/monitoring)

- [update-winevent-dcr-to-secevents](#update-winevent-dcr-to-secevents.ps1)

## update-winevent-dcr-to-secevents.ps1
This script will update a data collection rule to send events to the SecurityEvents Table. 
This was created since the Azure Monitor UI in the Azure Portal currently does not support this for windows based event collection.
To note this script can technically be used for any use case in updating the data flows (destination tables) with a DCR. 
You just need to specify the -currentTable and -newTable parameters. (These are not table names, but refer to data streams)

### Usage
1. Create a data collection rule via the Azure Monitor for Windows Events
    * https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=portal

2. Run the script against the current rule like below

``` 
.\update-winevent-dcr-to-secevents.ps1 -subscriptionId 'ada06dfd8-375e-df10-be3a-c6cacebf41c5' ` 
-resourceGroup 'sentinel-dcrs' -ruleName 'windows-events'
```
3. Verify the DCR
  * If needed you can check the data collection rule stream via the Azure Portal
  1. Navigate to [Data Collection Rules](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/dataCollectionRules) in the Azure Portal under Azure Monitor
  2. Select the Data Collection Rule you just updated

      ![dcr-view](/images/dcr-view.png)

  3. Select JSON View and verify the stream(s) have been udpated

      ![dcr-json](/images/dcr-json.png)
