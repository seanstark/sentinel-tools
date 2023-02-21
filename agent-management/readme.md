
# Update Azure Monitor Agent

- [Overview](#overview)
- [Usage](#usage)
- [Examples](#examples)
  * [Azure Virtual Machines](#azure-virtual-machines)
    * [Update Azure Virtual Machines to a specific version](#update-azure-virtual-machines-to-a-specific-version)
    * [Update Azure Virtual Machines to the latest version of Windows and Linux](#update-azure-virtual-machines-to-the-latest-version-of-windows-and-linux)
    * [Generate a report of Azure Virtual Machines with current versions](#generate-a-report-of-azure-virtual-machines-with-current-versions)
  * [Azure Arc Machines](#azure-arc-machines)
    * [Update Azure Arc Machines to a specific version](#update-azure-arc-machines-to-a-specific-version)
    * [Update Azure Arc Machines to the latest version of Windows and Linux](#update-azure-arc-machines-to-the-latest-version-of-windows-and-linux)
    * [Generate a report of Azure Arc Machines with current versions](#generate-a-report-of-azure-arc-machines-with-current-versions)
   
# Overview

[**update-ama.ps1**](https://github.com/seanstark/sentinel-tools/blob/main/ama-management/update-ama.ps1) is a powershell script you can use to update the Azure Monitor Agent on Azure Virtual Machines and Azure Arc Machines. The script will handle both linux and windows servers with the below features.

- Update the Azure Monitor Agent to a specific version
- Update the Azure Monitor Agent to the latest version
- Report on current versions without updating

# Usage

 > Azure Arc does not return a detailed status of the udpate request

- The script takes input from an object of machines from either [**Get-AzVM**](https://learn.microsoft.com/powershell/module/az.compute/get-azvm?view) or [**Get-AzConnectedMachine**](https://learn.microsoft.com/powershell/module/az.connectedmachine/get-azconnectedmachine). This will give you the flexibility to scope updates to specific machines. 

- You can specify the versions you want to update to using the **linuxTargetVersion** and **windowsTargetVersion** parameters.
  - > To get a list of versions see [Azure Monitor agent extension versions](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-extension-versions)
  
- If you specify the **latestVersion** parameter the script will automatically use the latest version available in the region where the machine resides. 

- If you specify the **report** parameter the script will only report on versions installed and will not update

# Examples

## Azure Virtual Machines

### Update Azure Virtual Machines to a specific version
```
.\update-ama.ps1 -machines $(Get-AzVM) -linuxTargetVersion 1.22.2 -windowsTargetVersion 1.10.0.0
```

### Update Azure Virtual Machines to the latest version of Windows and Linux
```
.\update-ama.ps1 -machines $(Get-AzVM) -latestVersion
```

### Generate a report of Azure Virtual Machines with current versions
```
.\update-ama.ps1 -machines $(Get-AzVM) -latestVersion -report
```

## Azure Arc Machines

### Update Azure Arc Machines to a specific version
```
.\update-ama.ps1 -machines $(Get-AzConnectedMachine) -linuxTargetVersion 1.22.2 -windowsTargetVersion 1.10.0.0
```

### Update Azure Arc Machines to the latest version of Windows and Linux
```
.\update-ama.ps1 -machines $(Get-AzConnectedMachine) -latestVersion
```

### Generate a report of Azure Arc Machines with current versions
```
.\update-ama.ps1 -machines $(Get-AzConnectedMachine) -latestVersion -report
```
