
# Update Extensions

- [Overview](#overview)
- [Usage](#usage)
- [Examples](#examples)
  * [Azure Virtual Machines](#azure-virtual-machines)
    * [Update Azure Virtual Machines to a specific version of the Azure Monitor Agent](#update-azure-virtual-machines-to-a-specific-version-of-the-azure-monitor-agent)
   
# Overview

[**update-extension.ps1**](https://github.com/seanstark/sentinel-tools/blob/main/agent-management/update-extension.ps1) is a powershell script you can use to update extensions on Azure Virtual Machines and Azure Arc Machines. The script will handle both linux and windows servers with the below features.

- Update the extension to a specific version
- Update the extension to the latest version
- Report on current versions without updating

# Usage

 > Azure Arc does not return a detailed status of the udpate request
 > The rest API only allows upgrading to Major+Minor versions. Therefore you can't upgrade from 1.2 to 1.2.2. 

- The script takes input from an object of machines from either [**Get-AzVM**](https://learn.microsoft.com/powershell/module/az.compute/get-azvm?view) or [**Get-AzConnectedMachine**](https://learn.microsoft.com/powershell/module/az.connectedmachine/get-azconnectedmachine). This will give you the flexibility to scope updates to specific machines. 

- You can specify the versions you want to update to using the **linuxTargetVersion** and **windowsTargetVersion** parameters.
  
- If you specify the **latestVersion** parameter the script will automatically use the latest version available in the region where the machine resides. 

- If you specify the **report** parameter the script will only report on versions installed and will not update

# Examples

## Azure Virtual Machines

### Update Azure Virtual Machines to a specific version of the Azure Monitor Agent
```
.\update-ama.ps1 -machines $(Get-AzVM) -linuxTargetVersion 1.22.2 -windowsTargetVersion 1.10.0.0 -extPublisherName 'Microsoft.Azure.Monitor' -windowsExtType 'AzureMonitorWindowsAgent' -linuxExtType 'AzureMonitorLinuxAgent'
```
