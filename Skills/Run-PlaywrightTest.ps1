param(
    [Parameter(Mandatory=$false)]
    [string]$TestFile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Target = "",
    
    [ValidateSet('chromium', 'firefox', 'webkit', 'all')]
    [string]$Browser = 'chromium',
    
    [switch]$Headed = $false,
    [switch]$Debug = $false,
    [switch]$UI = $false,
    [string]$Reporter = 'html'
)

<#
.SYNOPSIS
Runs Playwright tests for UI automation and validation.

.DESCRIPTION
This skill module executes Playwright tests with various configurations.
Supports multiple browsers, headed/headless modes, and different reporters.

.EXAMPLE
.\Run-PlaywrightTest.ps1 -TestFile "tests/smoke-test.spec.ts" -Browser chromium -Headed

.EXAMPLE
.\Run-PlaywrightTest.ps1 -Browser all -Reporter list
#>

$ErrorActionPreference = 'Stop'

# Change to Gen.UI.Audit directory
$genUIAuditRoot = Split-Path -Parent $PSScriptRoot
Push-Location $genUIAuditRoot

try {
    Write-Host "Gen.UI.Audit - Playwright Test Runner" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if node_modules exists
    if (-not (Test-Path "./node_modules")) {
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        npm install
        Write-Host ""
    }
    
    # Build command
    $cmd = "npx playwright test"
    
    # Add test file if specified
    if ($TestFile) {
        $cmd += " `"$TestFile`""
    }
    
    # Add browser project
    if ($Browser -eq 'all') {
        # Run all browsers
        $cmd += " --project=chromium --project=firefox --project=webkit"
    } else {
        $cmd += " --project=$Browser"
    }
    
    # Add headed mode
    if ($Headed) {
        $cmd += " --headed"
    }
    
    # Add debug mode
    if ($Debug) {
        $cmd += " --debug"
    }
    
    # Add UI mode
    if ($UI) {
        $cmd += " --ui"
    }
    
    # Add reporter
    $cmd += " --reporter=$Reporter"
    
    Write-Host "Running command: $cmd" -ForegroundColor Green
    Write-Host ""
    
    # Execute Playwright
    Invoke-Expression $cmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Tests completed successfully!" -ForegroundColor Green
        
        if ($Reporter -eq 'html') {
            Write-Host ""
            Write-Host "To view the HTML report, run:" -ForegroundColor Cyan
            Write-Host "  npx playwright show-report" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "✗ Tests failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    
} finally {
    Pop-Location
}
