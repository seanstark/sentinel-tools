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
    Specify an array of columns to add to the stream. Column names cannot contain spaces. This needs to be in a json formated list, example: '{"name": "Test1", "type": "string"}', '{"name": "Test2", "type": "string"}' 

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
If (!($dcr.properties.streamDeclarations."$streamName")){
    $json = '{"streamDeclarations": {"' + $streamName + '": {"columns": []}}}'
    $dcr.properties = @($dcr.properties) + $($json | ConvertFrom-Json)
}

If ($dcr.properties.streamDeclarations."$streamName"){
    #Columns to Add
    If ($columnsToAdd){
        ForEach ($columnToAdd in $columnsToAdd){
            $dcr.properties.streamDeclarations."$streamName".columns = @($dcr.properties.streamDeclarations."$streamName".columns) + $($columnToAdd | ConvertFrom-Json)
        }
    }
    #Columns to Remove
    If ($columnsToRemove) {
        Write-Host 'Removing'
        $dcr.properties.streamDeclarations."$streamName".columns = @($dcr.properties.streamDeclarations."$streamName".columns | where name -NotIn $columnsToRemove)
    }
}

$newDCR = $dcr | ConvertTo-Json -Depth 20

# Update the DCR
Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $dcr


$dcr = '
{
    "properties": {
        "immutableId": "dcr-b995a3a48f34461b9255238f4b1f628a",
        "dataCollectionEndpointId": "/subscriptions/ada06e68-375e-4210-be3a-c6cacebf41c5/resourceGroups/data-collection-end/providers/Microsoft.Insights/dataCollectionEndpoints/dce-customlog-westus3",
        "streamDeclarations": {
            "Custom-Microsoft-Syslog": {
                "columns": [
                    {
                        "name": "ls_timestamp",
                        "type": "datetime"
                    },
                    {
                        "name": "hostname",
                        "type": "string"
                    },
                    {
                        "name": "facility",
                        "type": "string"
                    },
                    {
                        "name": "severity",
                        "type": "string"
                    },
                    {
                        "name": "message",
                        "type": "string"
                    },
                    {
                        "name": "pid",
                        "type": "int"
                    },
                    {
                        "name": "process_name",
                        "type": "string"
                    },
                    {
                        "name": "ip",
                        "type": "string"
                    },
                    {
                        "name": "timestamp",
                        "type": "datetime"
                    },
                    {
                        "name": "service",
                        "type": "string"
                    }
                ]
            }
        },
        "destinations": {
            "logAnalytics": [
                {
                    "workspaceResourceId": "/subscriptions/ada06e68-375e-4210-be3a-c6cacebf41c5/resourcegroups/sentinel-prd/providers/microsoft.operationalinsights/workspaces/test-new",
                    "workspaceId": "488aedbf-638c-4844-aeaa-888b16f278db",
                    "name": "Custom-Microsoft-Syslog-Workspace"
                }
            ]
        },
        "dataFlows": [
            {
                "streams": [
                    "Custom-Microsoft-Syslog"
                ],
                "destinations": [
                    "Custom-Microsoft-Syslog-Workspace"
                ],
                "transformKql": "source | project TimeGenerated = ls_timestamp, HostName = hostname, Facility = facility, SeverityLevel = severity, SyslogMessage = message, ProcessID = pid, ProcessName = process_name, Computer = hostname, HostIP = ip, EventTime = timestamp, SourceSystem = service",
                "outputStream": "Microsoft-Syslog"
            }
        ],
        "provisioningState": "Succeeded"
    },
    "location": "westus3",
    "id": "/subscriptions/ada06e68-375e-4210-be3a-c6cacebf41c5/resourceGroups/sentinel-dcrs/providers/Microsoft.Insights/dataCollectionRules/logstash-sentinel-redux",
    "name": "logstash-sentinel-redux",
    "type": "Microsoft.Insights/dataCollectionRules",
    "etag": "\"01009632-0000-4d00-0000-64931dfd0000\"",
    "systemData": {
        "createdBy": "sean.stark@msdx250797.onmicrosoft.com",
        "createdByType": "User",
        "createdAt": "2023-06-15T18:56:27.7371654Z",
        "lastModifiedBy": "sean.stark@msdx250797.onmicrosoft.com",
        "lastModifiedByType": "User",
        "lastModifiedAt": "2023-06-21T15:57:48.0839327Z"
    }
}'