
# Overview
A breif intro to the various tools that reside here. 

> Are you looking for simplier Azure Policies for assigning data collection rules without all the image, region, and publisher policy rules? 
Check out [my policy repo](https://github.com/seanstark/Azure-Policy/tree/main/policyDefinitions/monitoring)

- [update-dcrdatastream](#update-dcrdatastream)

## update-dcrdatastream
This script will update a data collection rule to send events to the SecurityEvents Table. 
This was created since the Azure Monitor UI in the Azure Portal currently does not support this for windows based event collection.
> Technically this can be used for any use case in updating the data flows (destination tables) with a DCR. 
You just need to specify the -currentDataStream and -newDataStream parameters. (These are not table names, but refer to data streams names)

### Usage
1. Create a data collection rule via Azure Monitor for Windows Events
    * https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=portal

2. Run the script against the the applicable rule like below

``` 
.\update-dcrdatastream.ps1 -subscriptionId ada06e68-375e-4210-be3a-c6cacebf41c5 `
-resourceGroup sentinel-dcrs -ruleName windows-security-events
```
   ![dcr-view](/images/dcr.gif)

3. You can verify the DCR was modified by checking the output of the script. You should see a StatusCode of 200 and the streams updated like below.

   ![dcr-view](/images/dcr-verify.png)

4. You can also verify the DCR was updated by checking the data collection rule stream via the Azure Portal
  1. Navigate to [Data Collection Rules](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/dataCollectionRules) in the Azure       Portal under Azure Monitor
  2. Select the Data Collection Rule you just updated

      ![dcr-view](/images/dcr-view.png)

  3. Select JSON View and verify the stream(s) have been udpated

      ![dcr-json](/images/dcr-json.png)
