param(
    [Parameter(Mandatory=$true)]
    [string]$Target,
    
    [string]$TestFile = "",
    
    [ValidateSet('chromium', 'firefox', 'webkit', 'all')]
    [string]$Browser = 'chromium',
    
    [switch]$Headed = $false,
    [switch]$CaptureScreenshots = $true,
    [switch]$RecordVideo = $false,
    [string]$Reporter = 'html'
)

<#
.SYNOPSIS
Main UI audit command for Gen.UI.Audit framework.

.DESCRIPTION
Runs comprehensive UI audit combining Playwright automation and optional Yumlog capture.

.EXAMPLE
.\audit-ui.ps1 -Target "https://example.com" -Browser chromium -Headed

.EXAMPLE
.\audit-ui.ps1 -Target "file:///C:/app/index.html" -RecordVideo -CaptureScreenshots
#>

$ErrorActionPreference = 'Stop'

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Gen.UI.Audit - UI Validator        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Validate target
Write-Host "[1/5] Validating target..." -ForegroundColor Yellow
if ($Target -match '^https?://') {
    Write-Host "  Target: $Target (Remote URL)" -ForegroundColor Green
} elseif ($Target -match '^file://') {
    Write-Host "  Target: $Target (Local File)" -ForegroundColor Green
} else {
    Write-Error "Invalid target. Must be http://, https://, or file:// URL"
}

# Prepare test file
Write-Host "[2/5] Preparing test suite..." -ForegroundColor Yellow
if (-not $TestFile) {
    # Use default template
    $TestFile = Join-Path $PSScriptRoot "../tests/ui-audit.template.spec.ts"
    if (Test-Path $TestFile) {
        Write-Host "  Using template: ui-audit.template.spec.ts" -ForegroundColor Green
    } else {
        Write-Warning "  Template not found, will use all tests in tests/ directory"
        $TestFile = ""
    }
} else {
    Write-Host "  Using custom test: $TestFile" -ForegroundColor Green
}

# Start Yumlog capture if requested
$captureJob = $null
if ($RecordVideo) {
    Write-Host "[3/5] Starting Yumlog video recording..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $videoFile = Join-Path $PSScriptRoot "../audit-results/videos/audit-$timestamp.mp4"
    $videoDir = Split-Path -Parent $videoFile
    if (-not (Test-Path $videoDir)) {
        New-Item -ItemType Directory -Path $videoDir -Force | Out-Null
    }
    
    $yumlogRoot = Split-Path -Parent $PSScriptRoot
    $recordScript = Join-Path $yumlogRoot "Skills\Record-Screen.ps1"
    
    $captureJob = Start-Job -ScriptBlock {
        param($script, $fps, $duration, $out)
        . $script
        Record-Screen -Fps $fps -DurationSec $duration -OutFile $out
    } -ArgumentList $recordScript, 15, 300, $videoFile
    
    Write-Host "  Recording started: $videoFile" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "[3/5] Skipping video recording" -ForegroundColor Gray
}

# Run Playwright tests
Write-Host "[4/5] Running Playwright tests..." -ForegroundColor Yellow
. "$PSScriptRoot\..\Skills\Run-PlaywrightTest.ps1" `
    -TestFile $TestFile `
    -Target $Target `
    -Browser $Browser `
    -Headed:$Headed `
    -Reporter $Reporter

# Stop Yumlog capture
if ($captureJob) {
    Write-Host "[5/5] Stopping video recording..." -ForegroundColor Yellow
    Stop-Job $captureJob
    Remove-Job $captureJob
    Write-Host "  Recording saved" -ForegroundColor Green
} else {
    Write-Host "[5/5] Finalizing..." -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         Audit Complete!                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  - Test Report: playwright-report/index.html" -ForegroundColor White
if ($RecordVideo) {
    Write-Host "  - Video Recording: $videoFile" -ForegroundColor White
}
Write-Host ""
Write-Host "To view HTML report:" -ForegroundColor Cyan
Write-Host "  npx playwright show-report" -ForegroundColor White
