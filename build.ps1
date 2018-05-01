Write-Host -ForegroundColor Green "Installing NavContainerHelper"
$localrepo = "${env:USERPROFILE}\Documents\GitHub\microsoft\navcontainerhelper\NavContainerHelper.ps1"
if (Test-Path -Path $localrepo) {
    . $localrepo
} else {
    Install-Module NavContainerHelper -force
}

$appProjectFolder = Join-Path $PSScriptRoot "app"
$appJsonObject = Get-Content -Raw -Path "$appProjectFolder\app.json" | ConvertFrom-Json
$appName = $appJsonObject.Name
$appFile = "$appProjectFolder\output\$($appJsonObject.Publisher)_$($appJsonObject.Name)_$($appJsonObject.Version).app"

$testAppProjectFolder = Join-Path $PSScriptRoot "test"
$testAppJsonObject = Get-Content -Raw -Path "$testAppProjectFolder\app.json" | ConvertFrom-Json
$testAppName = $testAppJsonObject.Name
$testAppFile = "$testAppProjectFolder\output\$($testAppJsonObject.Publisher)_$($testAppJsonObject.Name)_$($testAppJsonObject.Version).app"

$agentFolder = $appProjectFolder.Substring(0,$appProjectFolder.IndexOf('\',3))

$imageName = "microsoft/bcsandbox:us"
$containerName = $appName
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

Write-Host -ForegroundColor Green "Build app"
Compile-AppInNavContainer -containerName $containerName -credential $credential -appProjectFolder $appProjectFolder -UpdateSymbols

Write-Host -ForegroundColor Green "Publish and install app"
Publish-NavContainerApp -containerName $containerName -appFile $appFile -skipVerification -sync -install

Write-Host -ForegroundColor Green "Build test app"
Compile-AppInNavContainer -containerName $containerName -credential $credential -appProjectFolder $testAppProjectFolder -UpdateSymbols

Write-Host -ForegroundColor Green "Publish and install test app"
Publish-NavContainerApp -containerName $containerName -appFile $testAppFile -skipVerification -sync -install

Write-Host -ForegroundColor Green "UnInstall and UnPublish app"
#UnPublish-NavContainerApp -containerName $containerName -appName $appName -unInstall

Write-Host -ForegroundColor Green "Remove Container"
#Remove-NavContainer -containerName $containerName

Write-Host -ForegroundColor Green "Remove unused images"
#docker system prune -f
