<#
 .DESCRIPTION
    This script will update a data collection rule with an associated data collection endpoint 

 .PARAMETER subscriptionId
    Specify the subscriptionID GUID where your data collection rule resides

 .PARAMETER resourceGroup
    Specify the Resource Group Name where your data collection rule resides

 .PARAMETER ruleName
    Specify the data collection rule name

.PARAMETER apiVersion
    Optionally you can specify the api version to use for Microsoft.Insights/dataCollectionRules

.PARAMETER dataCollectionEndpointId
    The full Resource ID of the data collection endpoint

 .EXAMPLE
    .\update-dcrDataCollectionEndpoint.ps1 -subscriptionId 'ada078449-375e-4210-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events' -dataCollectionEndpointId '/subscriptions/ada111e68-375e-4330-be3a-c6caddbf41c5/resourceGroups/data-collection-end/providers/Microsoft.Insights/dataCollectionEndpoints/dce-customlog-westus2'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$subscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$ruleName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2022-06-01',

    [Parameter(Mandatory=$true)]
    [string]$dataCollectionEndpointId
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

#Get Data Collection Rule
$uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Insights/dataCollectionRules/{2}?api-version={3}' -f $subscriptionId, $resourceGroup, $ruleName, $apiVersion)
$dcr = (Invoke-AzRestMethod -Uri $uri).content | ConvertFrom-Json -Depth 20

#Update the data collection endpoint
If ($dcr.properties.dataCollectionEndpointId){
    $dcr.properties.dataCollectionEndpointId = $dataCollectionEndpointId
}else{
    $dcr.properties | Add-Member -MemberType NoteProperty -Name 'dataCollectionEndpointId' -Value $dataCollectionEndpointId -Force
}

$newDCR = $dcr | ConvertTo-Json -Depth 20

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $newDCR
