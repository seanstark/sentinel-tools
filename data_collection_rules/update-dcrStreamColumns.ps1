<#
 .DESCRIPTION
    This script will update a data collection rule stream declaration columns

 .PARAMETER subscriptionId
    Specify the subscriptionID GUID where your data collection rule resides

 .PARAMETER resourceGroup
    Specify the Resource Group Name where your data collection rule resides

 .PARAMETER ruleName
    Specify the data collection rule name

.PARAMETER apiVersion
    Optionally you can specify the api version to use for Microsoft.Insights/dataCollectionRules

.PARAMETER streamName
    The stream declaration name to update.

.PARAMETER columnsToAdd
    Specify an array of columns to add to the stream. This needs to be in a json formated list, example: '{"name": "Test1", "type": "string"}', '{"name": "Test2", "type": "string"}' 

.PARAMETER columnsToRemove
    Specify an array of columns to remove from the stream. This needs to be a list of names, example: 'Message', 'Host'

 .EXAMPLE
    .\update-dcrStreamColumns.ps1 -subscriptionId 'ada078449-375e-4210-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events' -columnsToAdd '{"name": "Test1", "type": "string"}', '{"name": "Test2", "type": "string"}'

 .EXAMPLE
    .\update-dcrStreamColumns.ps1 -subscriptionId 'ada078449-375e-4210-be3a-c6cacebf41c5' -resourceGroup 'sentinel-dcrs' -ruleName 'windows-events' -columnsToRemove 'Message', 'Host'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$subscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,

    [Parameter(Mandatory=$true)]
    [string]$ruleName,

    [Parameter(Mandatory=$true)]
    [string]$streamName,

    [Parameter(Mandatory=$false)]
    [string[]]$columnsToAdd,

    [Parameter(Mandatory=$false)]
    [string[]]$columnsToRemove,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2022-06-01'
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
If ($dcr.properties.streamDeclarations."$streamName"){
    #Columns to Add
    If ($columnsToAdd){
        ForEach ($columnToAdd in $columnsToAdd){
            $dcr.properties.streamDeclarations."$streamName".columns = @($dcr.properties.streamDeclarations."$streamName".columns) + $($columnToAdd | ConvertFrom-Json)
        }
    }
    #Columns to Remove
    If ($columnsToRemove) {
        ForEach ($columnToRemove in $columnsToRemove){
            $dcr.properties.streamDeclarations."$streamName".columns = $dcr.properties.streamDeclarations."$streamName".columns | where name -ne $columnToRemove
        }
    }
}

$newDCR = $dcr | ConvertTo-Json -Depth 20

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $newDCR
