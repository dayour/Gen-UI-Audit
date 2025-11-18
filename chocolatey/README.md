# Gen.UI.Audit Chocolatey Package

This directory contains the Chocolatey package definition for Gen.UI.Audit.

## Building the Package

### Prerequisites

1. Install Chocolatey:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

2. Install Chocolatey packaging tools:
```powershell
choco install checksum -y
```

### Build Steps

1. Update version in `gen-ui-audit.nuspec` if needed

2. Calculate checksum for the GitHub release:
```powershell
$url = "https://github.com/dayour/Gen-UI-Audit/archive/refs/heads/main.zip"
$tempFile = "$env:TEMP\gen-ui-audit.zip"
Invoke-WebRequest -Uri $url -OutFile $tempFile
$checksum = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash
Write-Host "Checksum: $checksum"
Remove-Item $tempFile
```

3. Update checksum in `tools\chocolateyinstall.ps1`

4. Build the package:
```powershell
cd chocolatey
choco pack
```

This creates `gen-ui-audit.1.0.0.nupkg`

## Testing Locally

Test the package before publishing:

```powershell
# Install locally
choco install gen-ui-audit -s . -y

# Test the installation
cd C:\ProgramData\Gen.UI.Audit
npx playwright install chromium
.\launchers\audit-ui.ps1 -Target ".\tests\examples\yumlog-manager.spec.ts"

# Uninstall
choco uninstall gen-ui-audit -y
```

## Publishing to Chocolatey Community Repository

1. Create account at https://community.chocolatey.org/

2. Get your API key from https://community.chocolatey.org/account

3. Set API key:
```powershell
choco apikey --key YOUR-API-KEY --source https://push.chocolatey.org/
```

4. Push the package:
```powershell
choco push gen-ui-audit.1.0.0.nupkg --source https://push.chocolatey.org/
```

5. Wait for moderation approval (first package takes 24-48 hours)

## Installation for End Users

Once published and approved:

```powershell
choco install gen-ui-audit -y
```

## Package Structure

```
chocolatey/
├── gen-ui-audit.nuspec          # Package metadata
├── tools/
│   ├── chocolateyinstall.ps1    # Installation script
│   └── chocolateyuninstall.ps1  # Uninstallation script
└── README.md                     # This file
```

## Updating the Package

For new versions:

1. Update version in `gen-ui-audit.nuspec`
2. Update `releaseNotes` section
3. Recalculate checksum if source URL changed
4. Rebuild and test
5. Push new version

## Support

- GitHub Issues: https://github.com/dayour/Gen-UI-Audit/issues
- Chocolatey Package Page: https://community.chocolatey.org/packages/gen-ui-audit
