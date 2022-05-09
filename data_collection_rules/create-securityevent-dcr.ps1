



$basejson = Invoke-RestMethod -Method Get -Uri 


Connect-AzAccount -Subscription 

$securityEvents = @()

If ($includeAppLocker){
    $securityEvents += '"Microsoft-Windows-AppLocker/EXE and DLL!*[System[(EventID=8001) or (EventID=8002) or (EventID=8003) or (EventID=8004)]]"'
    $securityEvents += '"Microsoft-Windows-AppLocker/MSI and Script!*[System[(EventID=8005) or (EventID=8006) or (EventID=8007)]]"'
}

https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Insights/dataCollectionRules/{dataCollectionRuleName}?api-version=2021-04-01

$apiVersion = 'api-version=2021-04-01'
$uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Insights/dataCollectionRules/{2}?{3}' -f $subscriptionId, $resourceGroup, $ruleName, $apiVersion)

Invoke-AzRestMethod -Uri 