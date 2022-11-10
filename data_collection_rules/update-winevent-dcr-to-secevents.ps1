<#
 .EXAMPLE
 .\update-winevent-dcr-to-secevents.ps1 -subscriptionId 'ada06dfd8-375e-df10-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$subscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$ruleName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2021-09-01-preview'
)

$uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Insights/dataCollectionRules/{2}?api-version={3}' -f $subscriptionId, $resourceGroup, $ruleName, $apiVersion)

#Get Data Collection Rule
$dcr = (Invoke-AzRestMethod -Uri $uri).content | ConvertFrom-Json -Depth 20

# Update Data Collection Rule Data Flow Streams from Microsoft-Event to Microsoft-SecurityEvent
($dcr.properties.dataFlows | Where streams -like 'Microsoft-Event').streams = @('Microsoft-SecurityEvent')

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload ($dcr | ConvertTo-Json -Depth 20)
