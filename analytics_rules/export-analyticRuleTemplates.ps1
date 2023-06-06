<#
    .DESCRIPTION
        You can leverage this script to create export scheduled analytics rules from the analytics rules templates on github https://github.com/Azure/Azure-Sentinel
  
    .PARAMETER githubToken
        Specify the GitHub Access Personal Access Token you created. public_repo access required
 
    .EXAMPLE
        Create rules from all templates
        $rules = .\export-analyticRuleTemplates.ps1 -githubToken 'ghp_ECgzFoyPsbSKrFB2pTrEEOUmy4P0Rb3yd'

    .NOTES
        Author: seanstark-ms
        Link to GitHub Source: https://github.com/seanstark/sentinel-tools/tree/main/analytics_rules
        Requires PowerShell Version 7.0 and above
        Requires PowerShell Modules: 'PowerShellForGitHub', 'powershell-yaml'
#>

param(
    [Parameter(Mandatory=$true,
    HelpMessage='Specifiy your GitHub personal access token that has public_repo to the Microsoft Azure Organization')]
    [string]$githubToken
)

#Requires -Version 7.0

# Check for required modules
$requiredModules = 'PowerShellForGitHub', 'powershell-yaml'
$availableModules = Get-Module -ListAvailable -Name $requiredModules
$modulesToInstall = $requiredModules | where-object {$_ -notin $availableModules.Name}
ForEach ($module in $modulesToInstall){
    Write-Host "Installing Missing PowerShell Module: $module" -ForegroundColor Yellow
    Install-Module $module -force
}

# Sentinel GitHub Repo URI and Analytic Rule Root Path
$sentinelGitHuburi = 'https://github.com/Azure/Azure-Sentinel'
$sentinelGitHubPaths = 'Detections','Solutions'

#Setup GitHubAuthentication
[pscredential]$gitHubCred = New-Object System.Management.Automation.PSCredential ('dummy', $(ConvertTo-SecureString $githubToken -AsPlainText -Force))
Set-GitHubConfiguration -DisableLogging -DisableTelemetry
Set-GitHubAuthentication -Credential $gitHubCred

# Get all anlaytics rules from github
Write-Host 'Iterating through each detection folders to build directory structure. This will take a few minutes..' -ForegroundColor Yellow
$detectionFolders = @()
ForEach ($sentinelGitHubPath in $sentinelGitHubPaths){
    If ($sentinelGitHubPath -like 'Solutions'){
        $solutions = Get-GitHubContent -Uri $sentinelGitHuburi -Path 'Solutions' -MediaType Object | Select -ExpandProperty entries | Where type -like 'dir' | Select name
        ForEach ($solution in $solutions.name){
            $detectionFolders += Get-GitHubContent -Uri $sentinelGitHuburi -Path "Solutions/$solution" -MediaType Object | Select -ExpandProperty entries | Where-Object {$_.type -like 'dir' -and $_.name -like 'Analytic Rules'} | Select @{Name = 'name'; Expression = {$solution}}, path
        }
    }else{
        $detectionFolders += Get-GitHubContent -Uri $sentinelGitHuburi -Path $sentinelGitHubPath -MediaType Object | Select -ExpandProperty entries | Where type -like 'dir' | Select name, path
    }
}

# Filter on specific detection folders if detectionFolderName parameter is defined
If($detectionFolderName){
    $detectionFolders = $detectionFolders | where name -in $detectionFolderName
}

# Iterate through each detection folder in github and build an array of psobjects of the yaml files
Write-Host 'Iterating through each detection folder to build an index of each analytic rule template. This will take a few minutes..' -ForegroundColor Yellow
$alertRuleTemplates = @()
ForEach ($detectionFolder in $($detectionFolders | Select -ExpandProperty path)){

    $yamlFiles = Get-GitHubContent -Uri $sentinelGitHuburi -Path $detectionFolder -MediaType Object | Select -ExpandProperty entries | Where name -Like '*.yaml'

    ForEach ($yamlFile in $yamlFiles){

        $alertRuleTemplate = ConvertFrom-Yaml (Invoke-RestMethod -uri $yamlFile.download_url)
        
        If ($alertRuleTemplate.kind -like 'Scheduled'){

            Write-Verbose ('Found Scheduled Rule Template: {0}, adding to index' -f $alertRuleTemplate.name)

            $alertRuleTemplates += ([PSCustomObject]@{
                id = $alertRuleTemplate.id
                name = $alertRuleTemplate.name
                description = $alertRuleTemplate.description
                kind = 'Scheduled'
                templateURL = $yamlFile.download_url
                templateFolder = $detectionFolder
                severity = $alertRuleTemplate.severity
                requiredDataConnectors = $alertRuleTemplate.requiredDataConnectors.connectorId -join ',' | out-string
                techniques = $alertRuleTemplate.relevantTechniques -join ',' | out-string
                tactics = $alertRuleTemplate.tactics -join ',' | out-string
                query = $alertRuleTemplate.query
                entityMappings = $alertRuleTemplate.entityMappings | ConvertTo-Json -Depth 4 | out-string
            })
        }
    }
}
Write-Host "Found $($alertRuleTemplates.count) analytic rules" -ForegroundColor Yellow
$alertRuleTemplates
