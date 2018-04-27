Write-Host -ForegroundColor Green "Installing NavContainerHelper"
$localrepo = "${env:USERPROFILE}\Documents\GitHub\microsoft\navcontainerhelper\NavContainerHelper.ps1"
if (Test-Path -Path $localrepo) {
    . $localrepo
} else {
    Install-Module NavContainerHelper -force
}

$appProjectFolder = Join-Path $PSScriptRoot "app"
$testProjectFolder = Join-Path $PSScriptRoot "test"
$agentFolder = $appProjectFolder.Substring(0,$appProjectFolder.IndexOf('\',3))

$imageName = "microsoft/bcsandbox"
$containerName = "compiler"
$credential = [PSCredential]::new("admin", (ConvertTo-SecureString -String "P@ssword1" -AsPlainText -Force))
New-NavContainer -accept_eula `
                 -accept_outdated `
                 -alwaysPull `
                 -containerName $containerName `
                 -imageName $imageName `
                 -auth NAVUserPassword `
                 -Credential $credential `
                 -updateHosts `
                 -shortcuts None `
                 -additionalParameters @("--volume ""${agentFolder}:c:\source""", "--env httpSite=N", "--env WebClient=N") `
                 -myScripts @(@{'MainLoop.ps1' = 'while ($true) { start-sleep -seconds 10 }'})

Write-Host -ForegroundColor Green "Build started"
Compile-AppInNavContainer -containerName $containerName -credential $credential -appProjectFolder $appProjectFolder -UpdateSymbols

Write-Host "Remove Container"
#Remove-NavContainer -containerName $containerName

Write-Host "Remove unused images"
#docker system prune -f
