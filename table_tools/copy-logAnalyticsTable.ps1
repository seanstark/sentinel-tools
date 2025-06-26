<#
 .DESCRIPTION
    This script will create a new table from existing table with the same properties and schema.

 .PARAMETER sourceTableName
    Specify the exisiting table name

 .PARAMETER newTableName
    Specify the name of the new table

 .PARAMETER sourceSubscriptionID
    Specify the subscriptionID of your log analytics workspace 

 .PARAMETER sourceResourceGroupName
    Specify the Resource Group Name of your log analytics workspace

 .PARAMETER sourceWorkspaceName
    Specify the log analytics workspace name where the source table resides

  .PARAMETER destSubscriptionID
    Specify the subscriptionID of the destination log analytics workspace 

 .PARAMETER destResourceGroupName
    Specify the Resource Group Name of the destination log analytics workspace

 .PARAMETER destWorkspaceName
    Specify the log analytics workspace name where the destination source table resides
    
 .PARAMETER apiVersion
    Specify the apiVersion to use, not required

 .EXAMPLE
    Create a new log analytics table from an existing one in the same workspace
    .\copy-logAnalyticsTable.ps1 -sourceTableName 'Okta_CL' -newTableName 'Okta_AppTeam_CL' -subscriptionID 'ada06dd8-375e-4210-be3a-c6cdde3341c5' -resourceGroupName 'sentinel' -workspaceName 'sentinel-prd'

    Create a new log analytics table from an existing one in the same workspace
    ./copy-logAnalyticsTable.ps1 -sourceTableName "CommonSecurityLog" -newTableName "CustomCEF_CL" -sourceSubscriptionID "9ebcb583-7adb-888a-b688-06f1de624cc1" -sourceResourceGroupName "sentinel-prd" -sourceWorkspaceName "sentinel-prd" -destSubscriptionID "9ebcb583-7adb-888a-b688-06f1de624cc1" -destResourceGroupName "app-team-rg" -destWorkspaceName "app-team"

#>

param(
    [Parameter(Mandatory=$true)]
    [string]$sourceTableName,

    [Parameter(Mandatory=$true)]
    [string]$newTableName,

    [Parameter(Mandatory=$true)]
    [string]$sourceSubscriptionID,

    [Parameter(Mandatory=$true)]
    [string]$sourceResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$sourceWorkspaceName,

    [Parameter(ParameterSetName='DifferentLAW',Mandatory=$false)]
    [string]$destSubscriptionID,

    [Parameter(ParameterSetName='DifferentLAW',Mandatory=$false)]
    [string]$destResourceGroupName,

    [Parameter(ParameterSetName='DifferentLAW',Mandatory=$false)]
    [string]$destWorkspaceName,

    [Parameter(Mandatory=$false)]
    [string]$apiVersion = '2023-09-01'

)

#Get source table
$sourceTable = Invoke-AzRestMethod -Path ('/subscriptions/{0}/resourcegroups/{1}/providers/microsoft.operationalinsights/workspaces/{2}/tables/{3}?api-version=2021-12-01-preview' -f $sourceSubscriptionID, $sourceResourceGroupName, $sourceWorkspaceName, $sourceTableName, $apiVersion) -Method GET

# Convert From Json
$sourceTable = $sourceTable.Content | ConvertFrom-Json

# Check that new table name ends in CL
If (!($newTableName.EndsWith('_CL'))){
    $newTableName = $newTableName + "_CL"
}

# Udpate Schema with new table name and look for default workspace retention properties
$customColumns = $sourceTable.properties.schema.standardColumns | Where name -notin ('TenantId')
Add-Member -InputObject $sourceTable.properties.schema -Type NoteProperty -Name 'columns' -Value @($customColumns)
$sourceTable.name = $newTableName
$sourceTable.properties.schema.name = $newTableName
$sourceTable.properties.schema.displayName = $newTableName
$sourceTable.properties.schema.tableType = 'CustomLog'
$sourceTable.properties.schema.tableSubType = 'DataCollectionRuleBased'
If ($sourceTable.properties.retentionInDaysAsDefault){
    $sourceTable.properties.totalRetentionInDays = $null
    $sourceTable.properties.retentionInDays = -1
}
#$sourceTable.properties.schema.standardColumns = $standardColumns
$sourceTable.properties.schema.PSObject.Properties.Remove('standardColumns')
$sourceTable.properties.schema.PSObject.Properties.Remove('solutions')
$sourceTable.PSObject.Properties.Remove('id')

#Create the new table
If ($destSubscriptionID) {
   Write-Host "Creating new table $newTableName in workspace $destWorkspaceName in resource group $destResourceGroupName in subscription $destSubscriptionID"
   Invoke-AzRestMethod -Path ('/subscriptions/{0}/resourcegroups/{1}/providers/microsoft.operationalinsights/workspaces/{2}/tables/{3}?api-version=2021-12-01-preview' -f $destSubscriptionID, $destResourceGroupName, $destWorkspaceName, $newTableName, $apiVersion) -Method PUT -Payload $($sourceTable | ConvertTo-Json -Depth 6)
}else {
   Write-Host "Creating new table $newTableName in workspace $sourceWorkspaceName in resource group $sourceResourceGroupName in subscription $sourceSubscriptionID"
   Invoke-AzRestMethod -Path ('/subscriptions/{0}/resourcegroups/{1}/providers/microsoft.operationalinsights/workspaces/{2}/tables/{3}?api-version=2021-12-01-preview' -f $sourceSubscriptionID, $sourceResourceGroupName, $sourceWorkspaceName, $newTableName, $apiVersion) -Method PUT -Payload $($sourceTable | ConvertTo-Json -Depth 6)
}
