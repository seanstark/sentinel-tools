<#
 .DESCRIPTION
    This script will update data collection rule data streams destinations

 .PARAMETER subscriptionId
    Specify the subscriptionID GUID where your data collection rule resides

 .PARAMETER resourceGroup
    Specify the Resource Group Name where your data collection rule resides

 .PARAMETER ruleName
    Specify the data collection rule name

.PARAMETER apiVersion
    Optionally you can specify the api version to use for Microsoft.Insights/dataCollectionRules

.PARAMETER currentDataStream
    Optionally you can specify the current rule data stream name. This configured to Microsoft-Event by default

.PARAMETER newDataStream
    Optionally you can specify the data stream name to update to. This configured to Microsoft-SecurityEvent by default

 .EXAMPLE
    .\update-dcrdatastream.ps1 -subscriptionId 'ada06e68-375e-4210-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$subscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$ruleName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2021-09-01-preview',

    [Parameter(Mandatory=$false)]
    [string]$currentDataStream = 'Microsoft-Event',

    [Parameter(Mandatory=$false)]
    [string]$newDataStream = 'Microsoft-SecurityEvent'
)

$requiredModules = 'Az.Accounts'
$availableModules = Get-Module -ListAvailable -Name $requiredModules
$modulesToInstall = $requiredModules | where-object {$_ -notin $availableModules.Name}
ForEach ($module in $modulesToInstall){
    Write-Host "Installing Missing PowerShell Module: $module" -ForegroundColor Yellow
    Install-Module $module -force
}

If(!(Get-AzContext)){
    Write-Host ('Connecting to Azure Subscription: {0}' -f $subscriptionId) -ForegroundColor Yellow
    Connect-AzAccount -Subscription $subscriptionId | Out-Null
}

$uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Insights/dataCollectionRules/{2}?api-version={3}' -f $subscriptionId, $resourceGroup, $ruleName, $apiVersion)

#Get Data Collection Rule
$dcr = (Invoke-AzRestMethod -Uri $uri).content

# Update Data Collection Rule Data Flow Streams from Microsoft-Event to Microsoft-SecurityEvent
$newDCR = $dcr.replace(('"streams":["{0}"]' -f $currentDataStream), ('"streams":["{0}"]' -f $newDataStream))

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $newDCR
