$ErrorActionPreference = 'Stop'

$packageName = 'gen-ui-audit'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
$installDir = "C:\ProgramData\Gen.UI.Audit"
$zipUrl = 'https://github.com/dayour/Gen-UI-Audit/archive/refs/heads/main.zip'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  url           = $zipUrl
  checksum      = '848BFDD68B4EADCD8ECE6B5DCFA3B408615A884D0E0EBDD97B7EA675DF6A679D'
  checksumType  = 'sha256'
}

# Download and extract
Install-ChocolateyZipPackage @packageArgs

# Move extracted files to proper location
$extractedFolder = Join-Path $toolsDir "Gen-UI-Audit-main"
if (Test-Path $extractedFolder) {
    if (Test-Path $installDir) {
        Remove-Item $installDir -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Copy-Item -Path "$extractedFolder\*" -Destination $installDir -Recurse -Force
    
    # Clean up temp files
    Remove-Item $extractedFolder -Recurse -Force
}

Write-Host "Gen.UI.Audit installed to: $installDir" -ForegroundColor Green

# Install npm dependencies
Write-Host "Installing Node.js dependencies..." -ForegroundColor Cyan
Push-Location $installDir
try {
    & npm install --production
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "npm install completed with warnings. You may need to run 'npm install' manually."
    } else {
        Write-Host "Node.js dependencies installed successfully." -ForegroundColor Green
    }
} catch {
    Write-Warning "Failed to install npm dependencies. Please run 'npm install' in $installDir manually."
} finally {
    Pop-Location
}

# Add to PATH for easy access
Install-ChocolateyPath -PathToInstall "$installDir\launchers" -PathType 'Machine'

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Gen.UI.Audit Installation Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Location: $installDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Install Playwright browsers:" -ForegroundColor White
Write-Host "     cd $installDir" -ForegroundColor Gray
Write-Host "     npx playwright install chromium" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Run your first audit:" -ForegroundColor White
Write-Host "     audit-ui.ps1 -Target "".\your-app.html""" -ForegroundColor Gray
Write-Host ""
Write-Host "Documentation: https://github.com/dayour/Gen-UI-Audit" -ForegroundColor Yellow
Write-Host ""
