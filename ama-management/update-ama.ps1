

$linuxTargetVersion = '1.22.2'
$windowsTargetVersion = '1.9.0.0'
$machines = Get-AzVM 
$report = $true

$requiredModules = 'Az.Accounts', 'Az.Compute', 'Az.ConnectedMachine'
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

#Target Version cannot contain leading zeros
If

$agentsToUpgrade = @()

ForEach ($machine in $machines){
    # Cannot trust the OsType is properly detected, check for AzureMonitorWindowsAgent and AzureMonitorLinuxAgent
    $agent = $null
    If($machine.Type -like 'Microsoft.Compute/virtualMachines'){
        $state = (($machine | Get-AzVM -Status).statuses | Where Code -like 'PowerState*').DisplayStatus
        $windowsAgent = Get-AzVMExtension -VMName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorWindowsAgent' -ErrorAction SilentlyContinue
        $linuxAgent = Get-AzVMExtension -VMName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorLinuxAgent' -ErrorAction SilentlyContinue
    }
    If($machine.Type -like 'Microsoft.HybridCompute/machines'){
        $state = $machine.Status
        $windowsAgent = Get-AzConnectedMachineExtension MachineName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorWindowsAgent' -ErrorAction SilentlyContinue
        $linuxAgent = Get-AzConnectedMachineExtension MachineName $machine.Name -ResourceGroupName $machine.ResourceGroupName -Name 'AzureMonitorLinuxAgent' -ErrorAction SilentlyContinue
    }
    # Build Agent Objects
    If ($windowsAgent){
        $agent = $windowsAgent
        $agent | Add-Member -MemberType NoteProperty -Name TargetVersion -Value $windowsTargetVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name extensionTarget -Value 'Microsoft.Azure.Monitor.AzureMonitorWindowsAgent' -Force
    }
    If ($linuxAgent){
        $agent = $linuxAgent
        $agent | Add-Member -MemberType NoteProperty -Name TargetVersion -Value $linuxTargetVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name extensionTarget -Value 'Microsoft.Azure.Monitor.AzureMonitorLinuxAgent' -Force
    }
    
    # Add Additional Attributes
    If ($agent){   
        #Fix Target Version, cannot contain leading zeros
        $temp =  $agent.TargetVersion.ToString("0.00")

        $temp.ToString().ToString("0.00")
        [System.Version]('1.9.0')

        $agent | Add-Member -MemberType NoteProperty -Name CurrentVersion -Value $agent.TypeHandlerVersion -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineType -Value $machine.Type -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineState -Value $state -Force
        $agent | Add-Member -MemberType NoteProperty -Name MachineName -Value $machine.Name -Force
        $agent | Add-Member -MemberType NoteProperty -Name SubscriptionId -Value $machine.id.split('/')[2] -Force
        $agentsToUpgrade += $agent
    }
}

If ($report){
    $agentsToUpgrade | Select VMName, SubscriptionId, ResourceGroupName, MachineState, MachineType, Name, CurrentVersion, TargetVersion, extensionTarget, EnableAutomaticUpgrade, ProvisioningState | ft
}else {
    #Get only running or connected machines
    $agentsToUpgrade = $agentsToUpgrade | Where-Object {$_.MachineState -like 'VM running' -or $_.MachineState -like 'Connected'}
    #Get only machines that do not match the target version
    $agentsToUpgrade = $agentsToUpgrade | Where-Object {$_.CurrentVersion -lt $_.TargetVersion} 

    ForEach ($agent in $agentsToUpgrade){
        If($agent.MachineType -like 'Microsoft.Compute/virtualMachines'){
            $uri = ('https://management.azure.com{0}?api-version=2022-11-01' -f $agent.Id)
            $method = 'PATCH'
            $body = @{
                properties = @{
                    publisher = $agent.Publisher
                    type = $agent.ExtensionType
                    typeHandlerVersion = '1.9'#$agent.TargetVersion.split('.')[0..2] -join '.' 
                }
            }
        }
        If($agent.MachineType -like 'Microsoft.HybridCompute/machines'){
            $uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.HybridCompute/machines/{2}/upgradeExtensions?api-version=2022-12-27-preview' -f $agent.SubscriptionId, $agent.ResourceGroupName, $agent.MachineName)
            $method = 'POST'
            $body = @{
                extensionTargets = @{
                    "$($agent.extensionTarget)"= @{
                        targetVersion = $agent.TargetVersion.split('.')[0..2] -join '.'
                    }
                }
            }
        }

        $uri
        Invoke-AzRestMethod -Uri $uri -Method $method -Payload $($body | ConvertTo-Json)
    }
}