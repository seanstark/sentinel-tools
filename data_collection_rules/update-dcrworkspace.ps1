<#
 .DESCRIPTION
    This script will update data collection rule destination workspace 

 .PARAMETER subscriptionId
    Specify the subscriptionID GUID where your data collection rule resides

 .PARAMETER resourceGroup
    Specify the Resource Group Name where your data collection rule resides

 .PARAMETER ruleName
    Specify the data collection rule name

.PARAMETER apiVersion
    Optionally you can specify the api version to use for Microsoft.Insights/dataCollectionRules

.PARAMETER currentWorkspaceId
    The currently configured log analytics workspace Id

.PARAMETER newWorkspaceResourceId
    The full Resource Id of the new log analytics workspace change to

 .EXAMPLE
    .\update-dcrworkspace.ps1 -subscriptionId 'ada078449-375e-4210-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events' -currentWorkspaceId 'b6222115-73bc-4c99-b795-4560c061aced' -newWorkspaceResourceId '/subscriptions/166c8347-0480-4aa7-b984-75f0fda42c69/resourceGroups/sentinel/providers/Microsoft.OperationalInsights/workspaces/sentinel'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$subscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$ruleName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2021-04-01',

    [Parameter(Mandatory=$true)]
    [string]$currentWorkspaceId,

    [Parameter(Mandatory=$true)]
    [string]$newWorkspaceResourceId
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

#Get the new workspace Id
$uri = ('https://management.azure.com{0}?api-version=2021-12-01-preview' -f $newWorkspaceResourceId)

$newWorkspaceId = ((Invoke-AzRestMethod -Uri $uri).content | ConvertFrom-Json).properties.customerId

$uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Insights/dataCollectionRules/{2}?api-version={3}' -f $subscriptionId, $resourceGroup, $ruleName, $apiVersion)

#Get Data Collection Rule
$dcr = (Invoke-AzRestMethod -Uri $uri).content | ConvertFrom-Json -Depth 20

#Update to the new workspace
$destName = ($dcr.properties.destinations.logAnalytics | where workspaceId -Like $currentWorkspaceId).name
$newDestName = 'la--{0}' -f $(get-random)
($dcr.properties.destinations.logAnalytics | where workspaceId -Like $currentWorkspaceId).workspaceResourceId = $newWorkspaceResourceId
($dcr.properties.destinations.logAnalytics | where workspaceId -Like $currentWorkspaceId).name = $newDestName
($dcr.properties.destinations.logAnalytics | where workspaceId -Like $currentWorkspaceId).workspaceId = $newWorkspaceId 
$newDCR = $dcr | ConvertTo-Json -Depth 20
$newDCR = $newDCR.Replace($destName, $newDestName)

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $newDCR

