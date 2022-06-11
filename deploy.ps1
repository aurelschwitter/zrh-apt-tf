. $PSScriptRoot\secrets.ps1

Set-Location "$PSScriptRoot/terraform"
terraform apply -auto-approve

if ($LASTEXITCODE -ne 0) { return }

Set-Location "$PSScriptRoot/src"
func azure functionapp publish "zrhapttf2-funcapp"
# test
Invoke-RestMethod "https://zrhapttf2-funcapp.azurewebsites.net/api/httptrigger?name=PowerShell"





