
# Deploy the Logic App

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fseanstark%2Fsentinel-tools%2Fmain%2Fplaybooks%2Fget-incidentdetails%2Fazuredeploy.json)

# Grant the System Managed Identity SecurityAlert.Read.All rights

``` Powershell
Install-Module -Name AzureAD

$msgraph = Get-AzureADServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$permission = $msgraph.AppRoles | where Value -Like 'SecurityAlert.Read.All' | Select-Object -First 1

$msi = Get-AzureADServicePrincipal -ObjectId <app object id>
New-AzureADServiceAppRoleAssignment -Id $permission.Id -ObjectId $msi.ObjectId -PrincipalId $msi.ObjectId -ResourceId $defenderApp.ObjectId
```
