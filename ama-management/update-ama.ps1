<#
 .DESCRIPTION
    This script will update Azure Virtual Machines and Azure Arc Machines to the desired or latest version of the Azure Monitor Agent.

 .PARAMETER machines
    Specify an object of machines from Get-AzVM or Get-AzConnectedMachine

 .PARAMETER linuxTargetVersion
    Specify the version of the Azure Monitor Agent to ugprade to for Linux. See https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-extension-versions

 .PARAMETER windowsTargetVersion
    Specify the version of the Azure Monitor Agent to ugprade to for Windows. See https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-extension-versions

 .PARAMETER latestVersion
    Specify the latestVersion switch to use the latest version available for Linux and Windows. This is unique to each region.

 .PARAMETER report
    Specify the report switch to only report on machines with current versions

 .EXAMPLE
    Update Azure Virtual Machines to a specific version
    .\update-ama.ps1 -machines $(Get-AzVM) -linuxTargetVersion 1.22.2 -windowsTargetVersion 1.10.0.0

 .EXAMPLE
    Update Azure Virtual Machines to the latest version of Windows and Linux
    .\update-ama.ps1 -machines $(Get-AzVM) -latestVersion

 .EXAMPLE
    Generate a report of Azure Virtual Machines with current versions
    .\update-ama.ps1 -machines $(Get-AzVM) -latestVersion -report

 .EXAMPLE
    Update Azure Arc Machines to a specific version
    .\update-ama.ps1 -machines $(Get-AzConnectedMachine) -linuxTargetVersion 1.22.2 -windowsTargetVersion 1.10.0.0

 .EXAMPLE
    Update Azure Arc Machines to the latest version of Windows and Linux
    .\update-ama.ps1 -machines $(Get-AzConnectedMachine) -latestVersion

 .EXAMPLE
    Generate a report of Azure Arc Machines with current versions
    .\update-ama.ps1 -machines $(Get-AzConnectedMachine) -latestVersion -report
#>

param(
    [Parameter(Mandatory=$true)]
    [object]$machines,

    [Parameter(Mandatory=$true, ParameterSetName = 'TargetVersion')]
    [string]$linuxTargetVersion,

    [Parameter(Mandatory=$true, ParameterSetName = 'TargetVersion')]
    [string]$windowsTargetVersion,

    [Parameter(Mandatory=$true, ParameterSetName = 'LatestVersion')]
    [switch]$latestVersion,

    [Parameter(Mandatory=$false)]
    [switch]$report,

    [Parameter(Mandatory=$false)]
    [string]$extPublisherName = 'Microsoft.Azure.Monitor',

    [Parameter(Mandatory=$false)]
    [string]$windowsExtType = 'AzureMonitorWindowsAgent',

    [Parameter(Mandatory=$false)]
    [string]$linuxExtType = 'AzureMonitorLinuxAgent'
)

$requiredModules = 'Az.Accounts', 'Az.Compute', 'Az.ConnectedMachine'
$availableModules = Get-Module -ListAvailable -Name $requiredModules
$modulesToInstall = $requiredModules | where-object {$_ -notin $availableModules.Name}
ForEach ($module in $modulesToInstall){
    Write-Host "Installing Missing PowerShell Module: $module" -ForegroundColor Yellow
    Install-Module $module -force
}

# This isn't used for anything other than to query for arc extension versions
$subscriptionId = (Get-AzContext | Select -ExpandProperty Subscription).id

function Get-latestVersion{
    Param($versions)
    $latest = $versions | % {[version]$_} | Sort-Object -Descending | Select -First 1
    $latest.ToString()
}

#Get Latest Versions for each machine region
If($latestVersion){
    
    $regionLatestVersions = @()
    $regions = $machines.location | Get-Unique
    ForEach ($region in $regions){
        Write-Verbose ('Getting Region Latest Extension Versions for {0}' -f $region )
        # Azure Native Virtual Machines
        $windowsVersions = Get-AzVMExtensionImage -PublisherName $extPublisherName -Type $windowsExtType -Location $region 
        $linuxVersions = Get-AzVMExtensionImage -PublisherName $extPublisherName -Type $linuxExtType -Location $region

        # Azure Arc Machines
        If($machines[0].Type -like 'Microsoft.HybridCompute/machines'){
            Write-Verbose ('Getting Azure Arc Region Latest Extension Versions for {0}' -f $region )
            $uri = ('https://management.azure.com/subscriptions/{0}/providers/Microsoft.HybridCompute/locations/{1}/publishers/{2}/extensionTypes/{3}/versions?api-version=2022-12-27-preview' -f $subscriptionId, $region, $extPublisherName, $windowsExtType)
            $windowsVersions = (Invoke-AzRestMethod -Uri $uri -Method GET).Content | ConvertFrom-Json | Select -ExpandProperty properties

            $uri = ('https://management.azure.com/subscriptions/{0}/providers/Microsoft.HybridCompute/locations/{1}/publishers/{2}/extensionTypes/{3}/versions?api-version=2022-12-27-preview' -f $subscriptionId, $region, $extPublisherName, $linuxExtType)
            $linuxVersions = (Invoke-AzRestMethod -Uri $uri -Method GET).Content | ConvertFrom-Json | Select -ExpandProperty properties
        }

        #Update Object
        $regionLatestVersions += [PSCustomObject]@{
            location = $region
            linuxLatestVersion = Get-latestVersion $linuxVersions.Version
            windowsLatestVersion = Get-latestVersion $windowsVersions.Version
        }
    }
}

$agentsToUpgrade = @()

Write-Host ('Evaluating {0} machines' -f $machines.Count)

ForEach ($machine in $machines){
    # Cannot trust the OsType is properly detected, check for AzureMonitorWindowsAgent and AzureMonitorLinuxAgent
    $agent = $null

    Write-Verbose ('Evaluating {0}' -f $machine.Name)

    If($machine.Type -like 'Microsoft.Compute/virtualMachines'){
        $state = (($machine | Get-AzVM -Status).statuses | Where Code -like 'PowerState*').DisplayStatus
        $windowsAgent = Get-AzVMExtension -VMName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorWindowsAgent' -ErrorAction SilentlyContinue
        $linuxAgent = Get-AzVMExtension -VMName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorLinuxAgent' -ErrorAction SilentlyContinue
    }
    If($machine.Type -like 'Microsoft.HybridCompute/machines'){
        $state = $machine.Status
        $windowsAgent = Get-AzConnectedMachineExtension -MachineName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorWindowsAgent' -ErrorAction SilentlyContinue
        $linuxAgent = Get-AzConnectedMachineExtension -MachineName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorLinuxAgent' -ErrorAction SilentlyContinue
    }

    # If latestVersion is flagged, get the latest published version for the region where the machine resides
    If($latestVersion){
        Write-Verbose ('Latest Version Parameter Specified. Getting Latest Version for Region: {0}' -f $machine.Location)
        $linuxTargetVersion = $regionLatestVersions | Where-Object {$_.location -like $machine.Location} | Select -ExpandProperty linuxLatestVersion
        $windowsTargetVersion = $regionLatestVersions | Where-Object {$_.location -like $machine.Location} | Select -ExpandProperty windowsLatestVersion
    }

    # Build Agent Objects
    If ($windowsAgent){
        $agent = $windowsAgent
        $agent | Add-Member -MemberType NoteProperty -Name TargetVersion -Value $windowsTargetVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name extensionTarget -Value $windowsAgent.extensionTarget -Force
    }
    If ($linuxAgent){
        $agent = $linuxAgent
        $agent | Add-Member -MemberType NoteProperty -Name TargetVersion -Value $linuxTargetVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name extensionTarget -Value $linuxAgent.extensionTarget -Force
    }
    
    # Add Additional Attributes
    If ($agent){   
        #Fix Target Version, can only be major and minor version
        $agent | Add-Member -MemberType NoteProperty -Name TargetMajorMinorVersion -Value ('{0}.{1}'-f ([Version]($agent.TargetVersion)).Major, ([Version]($agent.TargetVersion)).Minor) -Force
        $agent | Add-Member -MemberType NoteProperty -Name CurrentVersion -Value $agent.TypeHandlerVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineType -Value $machine.Type -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineState -Value $state -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineName -Value $machine.Name -Force
        $agent | Add-Member -MemberType NoteProperty -Name SubscriptionId -Value $machine.id.split('/')[2] -Force
        $agentsToUpgrade += $agent

        Write-Verbose ($agent | Select MachineName, SubscriptionId, ResourceGroupName, MachineState, MachineType, Name, CurrentVersion, TargetVersion, extensionTarget, EnableAutomaticUpgrade, ProvisioningState)
    }
}

If ($report){
    Write-Host 'Report only specified'
    $agentsToUpgrade | Select MachineName, SubscriptionId, ResourceGroupName, MachineState, MachineType, Name, CurrentVersion, TargetVersion, extensionTarget, EnableAutomaticUpgrade, ProvisioningState | ft
}else {
    #Get only running or connected machines
    $agentsToUpgrade = $agentsToUpgrade | Where-Object {$_.MachineState -like 'VM running' -or $_.MachineState -like 'Connected'}
    #Get only machines that do not match the target version
    $agentsToUpgrade = $agentsToUpgrade | Where-Object {[Version]$_.CurrentVersion -lt [Version]$_.TargetVersion} 

    Write-Host ('{0} out of {1} machines to upgrade' -f $agentsToUpgrade.count, $machines.Count)

    ForEach ($agent in $agentsToUpgrade){
        If($agent.MachineType -like 'Microsoft.Compute/virtualMachines'){
            $uri = ('https://management.azure.com{0}?api-version=2022-11-01' -f $agent.Id)
            $method = 'PATCH'
            $body = @{
                properties = @{
                    publisher = $agent.Publisher
                    type = $agent.ExtensionType
                    typeHandlerVersion = $agent.TargetMajorMinorVersion
                }
            }
        }
        If($agent.MachineType -like 'Microsoft.HybridCompute/machines'){
            $uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.HybridCompute/machines/{2}/upgradeExtensions?api-version=2022-12-27-preview' -f $agent.SubscriptionId, $agent.ResourceGroupName, $agent.MachineName)
            $method = 'POST'
            $body = @{
                extensionTargets = @{
                    "$($agent.extensionTarget)"= @{
                        targetVersion = $agent.TargetMajorMinorVersion
                    }
                }
            }
        }
        Write-Host ('Updating {0} from version {1} to latest version: {2} ' -f $agent.MachineName, $agent.CurrentVersion, $agent.TargetVersion)
        Write-Verbose $uri
        $request = Invoke-AzRestMethod -Uri $uri -Method $method -Payload $($body | ConvertTo-Json)
        $reqContent = $request.Content | ConvertFrom-Json
        $request | Add-Member -MemberType NoteProperty -Name provisioningState -Value $reqContent.properties.provisioningState -Force
        $request | Add-Member -MemberType NoteProperty -Name publisher -Value $reqContent.properties.publisher -Force
        $request | Add-Member -MemberType NoteProperty -Name type -Value $reqContent.properties.type -Force
        $request | Add-Member -MemberType NoteProperty -Name typeHandlerVersion -Value $reqContent.properties.typeHandlerVersion -Force
        $request | Add-Member -MemberType NoteProperty -Name machineName -Value $agent.MachineName -Force
        $request | Select machineName, StatusCode, Method, provisioningState, publisher, type, typeHandlerVersion
    }
}