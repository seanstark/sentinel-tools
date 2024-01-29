<#
 .DESCRIPTION
    This script will create a new table from existing table with the same properties and schema.

 .PARAMETER sourceTableName
    Specify the exisiting table name

 .PARAMETER newTableName
    Specify the name of the new table

 .PARAMETER subscriptionID
    Specify the subscriptionID of your log analytics workspace 

 .PARAMETER resourceGroupName
    Specify the Resource Group Name of your log analytics workspace

 .PARAMETER workspaceName
    Specify the log analytics workspace name where the source table resides
    
 .PARAMETER apiVersion
    Specify the apiVersion to use, not required

 .EXAMPLE
    Create a new log analytics table from an existing one
    .\copy-logAnalyticsTable.ps1 -sourceTableName 'Okta_CL' -newTableName 'Okta_AppTeam_CL' -subscriptionID 'ada06dd8-375e-4210-be3a-c6cdde3341c5' -resourceGroupName 'sentinel' -workspaceName 'sentinel-prd'
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$sourceTableName,

    [Parameter(Mandatory=$true)]
    [string]$newTableName,

    [Parameter(Mandatory=$true)]
    [string]$subscriptionID,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$workspaceName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2021-12-01-preview'

)

#Get source table
$sourceTable = Invoke-AzRestMethod -Path ('/subscriptions/{0}/resourcegroups/{1}/providers/microsoft.operationalinsights/workspaces/{2}/tables/{3}?api-version=2021-12-01-preview' -f $subscriptionID, $resourceGroupName, $workspaceName, $sourceTableName, $apiVersion) -Method GET

# Convert From Json
$sourceTable = $sourceTable.Content | ConvertFrom-Json

# Check that new table name ends in CL
If (!($newTableName.EndsWith('_CL'))){
    $newTableName = $newTableName + "_CL"
}

# Udpate Schema with new table name and look for default workspace retention properties
$sourceTable.properties.schema.Name = $newTableName
If ($sourceTable.properties.retentionInDaysAsDefault){
    $sourceTable.properties.totalRetentionInDays = $null
    $sourceTable.properties.retentionInDays = -1
}

#Create the new table
Invoke-AzRestMethod -Path ('/subscriptions/{0}/resourcegroups/{1}/providers/microsoft.operationalinsights/workspaces/{2}/tables/{3}?api-version=2021-12-01-preview' -f $subscriptionID, $resourceGroupName, $workspaceName, $newTableName, $apiVersion) -Method PUT -Payload $($sourceTable | ConvertTo-Json -Depth 6)
