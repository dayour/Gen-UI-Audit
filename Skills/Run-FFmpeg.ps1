function Run-FFmpeg {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Arguments
    )
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $localFfmpeg = Join-Path $repoRoot ".tools\ffmpeg\bin\ffmpeg.exe"

    $ffmpegPath = if ($env:FFMPEG_PATH) {
        $env:FFMPEG_PATH
    } elseif (Test-Path -LiteralPath $localFfmpeg) {
        $localFfmpeg
    } else {
        $command = Get-Command ffmpeg -ErrorAction SilentlyContinue
        if ($command) {
            $command.Source
        }
    }

    if (-not $ffmpegPath) {
        throw "FFmpeg was not found. Run .\launchers\install-yumlog.ps1 or set FFMPEG_PATH."
    }
    Write-Verbose "Invoking: $ffmpegPath $($Arguments -join ' ')" -Verbose:$($VerbosePreference -eq 'Continue')
    $process = Start-Process -FilePath $ffmpegPath -ArgumentList $Arguments -NoNewWindow -Wait -PassThru -RedirectStandardError ffmpeg_error.log -RedirectStandardOutput ffmpeg_output.log
    if ($process.ExitCode -ne 0) {
        $err = Get-Content ffmpeg_error.log
        throw "FFmpeg failed with exit code $($process.ExitCode): $err"
    }
}

# Only export if we're being imported as a module
if ($MyInvocation.Line -match 'Import-Module') {
    Export-ModuleMember -Function Run-FFmpeg
}
