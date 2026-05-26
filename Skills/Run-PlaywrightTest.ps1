param(
    [Parameter(Mandatory=$false)]
    [string]$TestFile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Target = "",
    
    [ValidateSet('chromium', 'firefox', 'webkit', 'all')]
    [string]$Browser = 'chromium',
    
    [switch]$Headed = $false,

    [switch]$DebugMode = $false,

    [switch]$UIMode = $false,

    [ValidateSet('html', 'list', 'json', 'junit')]
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
    
    # Build command as an argument array to avoid quoting/injection issues.
    $playwrightArgs = @('playwright', 'test')
    
    # Add test file if specified
    if ($TestFile) {
        if (-not (Test-Path -LiteralPath $TestFile)) {
            throw "Test file not found: $TestFile"
        }

        # Playwright accepts POSIX-style separators consistently across platforms.
        $playwrightTestFile = $TestFile -replace '\\', '/'
        $playwrightArgs += $playwrightTestFile
        Write-Host "Using test file: $playwrightTestFile" -ForegroundColor Green
    }

    # Set environment variable for target URL if provided.
    $previousTarget = $env:PLAYWRIGHT_TARGET_URL
    if ($Target) {
        $env:PLAYWRIGHT_TARGET_URL = $Target
        Write-Host "Target URL set: $Target" -ForegroundColor Green
    }
    
    # Add browser project
    if ($Browser -eq 'all') {
        # Run all browsers
        $playwrightArgs += @('--project=chromium', '--project=firefox', '--project=webkit')
    } else {
        $playwrightArgs += "--project=$Browser"
    }
    
    # Add headed mode
    if ($Headed) {
        $playwrightArgs += '--headed'
    }
    
    # Add debug mode
    if ($DebugMode) {
        $playwrightArgs += '--debug'
    }
    
    # Add UI mode
    if ($UIMode) {
        $playwrightArgs += '--ui'
    }
    
    # Add reporter
    $playwrightArgs += "--reporter=$Reporter"
    
    Write-Host "Running command: npx $($playwrightArgs -join ' ')" -ForegroundColor Green
    Write-Host ""
    
    # Execute Playwright
    & npx @playwrightArgs
    
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
        throw "Playwright tests failed with exit code: $LASTEXITCODE"
    }
    
} finally {
    if ($null -eq $previousTarget) {
        Remove-Item Env:\PLAYWRIGHT_TARGET_URL -ErrorAction SilentlyContinue
    } else {
        $env:PLAYWRIGHT_TARGET_URL = $previousTarget
    }
    Pop-Location
}
