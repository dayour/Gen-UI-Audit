$ErrorActionPreference = 'Stop'

$packageName = 'gen-ui-audit'
$installDir = "C:\ProgramData\Gen.UI.Audit"

# Remove installation directory
if (Test-Path $installDir) {
    Write-Host "Removing Gen.UI.Audit from: $installDir" -ForegroundColor Yellow
    Remove-Item $installDir -Recurse -Force
    Write-Host "Gen.UI.Audit removed successfully." -ForegroundColor Green
} else {
    Write-Host "Installation directory not found. Nothing to remove." -ForegroundColor Yellow
}

# PATH is automatically cleaned up by Chocolatey

Write-Host "Gen.UI.Audit has been uninstalled." -ForegroundColor Green
