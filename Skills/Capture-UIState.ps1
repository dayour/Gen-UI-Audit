param(
    [Parameter(Mandatory=$true)]
    [string]$TestName,
    
    [Parameter(Mandatory=$false)]
    [string]$Url = "",
    
    [int]$Fps = 2,
    [int]$Duration = 10,
    [string]$OutDir = "./audit-results/screenshots",
    [switch]$Baseline = $false,
    [switch]$CompareToBaseline = $false
)

<#
.SYNOPSIS
Captures UI state using Yumlog screen capture integrated with Playwright tests.

.DESCRIPTION
This skill module uses Yumlog's screenshot capture capabilities to record UI state
during automated testing. Supports baseline capture and visual regression testing.

.EXAMPLE
.\Capture-UIState.ps1 -TestName "LoginFlow" -Url "https://example.com/login" -Baseline $true

.EXAMPLE
.\Capture-UIState.ps1 -TestName "LoginFlow" -CompareToBaseline $true
#>

$ErrorActionPreference = 'Stop'

# Import Yumlog capture functionality
$yumlogRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. "$yumlogRoot\Skills\Capture-Screens.ps1"

# Create output directory
$testOutDir = Join-Path $OutDir $TestName
if (-not (Test-Path $testOutDir)) {
    New-Item -ItemType Directory -Path $testOutDir -Force | Out-Null
}

# Determine capture mode
if ($Baseline) {
    $baselineDir = Join-Path $testOutDir "baseline"
    if (-not (Test-Path $baselineDir)) {
        New-Item -ItemType Directory -Path $baselineDir -Force | Out-Null
    }
    $captureDir = $baselineDir
    Write-Host "Capturing baseline screenshots for test: $TestName" -ForegroundColor Cyan
} else {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $captureDir = Join-Path $testOutDir $timestamp
    if (-not (Test-Path $captureDir)) {
        New-Item -ItemType Directory -Path $captureDir -Force | Out-Null
    }
    Write-Host "Capturing screenshots for test: $TestName" -ForegroundColor Cyan
}

# Open URL in browser if specified
if ($Url) {
    Write-Host "Opening URL: $Url" -ForegroundColor Yellow
    Start-Process $Url
    Start-Sleep -Seconds 2
}

# Capture screenshots using Yumlog
Write-Host "Capturing at $Fps FPS for $Duration seconds..." -ForegroundColor Green
Capture-Screens -Fps $Fps -DurationSec $Duration -OutDir $captureDir

Write-Host "Screenshots saved to: $captureDir" -ForegroundColor Green

# Compare to baseline if requested
if ($CompareToBaseline) {
    $baselineDir = Join-Path $testOutDir "baseline"
    if (Test-Path $baselineDir) {
        Write-Host "Comparing against baseline..." -ForegroundColor Yellow
        
        $baselineFiles = Get-ChildItem -Path $baselineDir -Filter *.png | Sort-Object Name
        $currentFiles = Get-ChildItem -Path $captureDir -Filter *.png | Sort-Object Name
        
        if ($baselineFiles.Count -ne $currentFiles.Count) {
            Write-Warning "Screenshot count mismatch: Baseline=$($baselineFiles.Count), Current=$($currentFiles.Count)"
        }
        
        $differences = @()
        for ($i = 0; $i -lt [Math]::Min($baselineFiles.Count, $currentFiles.Count); $i++) {
            $baselineFile = $baselineFiles[$i]
            $currentFile = $currentFiles[$i]
            
            # Simple file size comparison (pixel-perfect comparison would require image processing library)
            if ($baselineFile.Length -ne $currentFile.Length) {
                $differences += @{
                    Index = $i + 1
                    BaselineFile = $baselineFile.Name
                    CurrentFile = $currentFile.Name
                    BaselineSize = $baselineFile.Length
                    CurrentSize = $currentFile.Length
                }
            }
        }
        
        if ($differences.Count -eq 0) {
            Write-Host "✓ All screenshots match baseline!" -ForegroundColor Green
        } else {
            Write-Warning "✗ Found $($differences.Count) differences:"
            $differences | ForEach-Object {
                Write-Host "  Screenshot $($_.Index): Size difference (Baseline: $($_.BaselineSize), Current: $($_.CurrentSize))" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Warning "No baseline found. Run with -Baseline switch to create one."
    }
}

# Return capture information
[PSCustomObject]@{
    TestName = $TestName
    CaptureDir = $captureDir
    ScreenshotCount = (Get-ChildItem -Path $captureDir -Filter *.png).Count
    IsBaseline = $Baseline.IsPresent
    ComparedToBaseline = $CompareToBaseline.IsPresent
}
