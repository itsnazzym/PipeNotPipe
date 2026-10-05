$ErrorActionPreference = 'Stop'
$script:WorkspaceRoot = Split-Path $PSScriptRoot -Parent

function Initialize-BuildEnvironment {
    $taskCandidates = @($env:JAVA_HOME)
    if ($env:USERPROFILE) {
        $taskTools = Join-Path $env:USERPROFILE '.codex\tools\jdk-25'
        if (Test-Path -LiteralPath $taskTools) {
            $taskCandidates += @(Get-ChildItem -LiteralPath $taskTools -Directory | ForEach-Object FullName)
        }
    }
    foreach ($taskCandidate in $taskCandidates) {
        if (!$taskCandidate) { continue }
        $taskRelease = Join-Path $taskCandidate 'release'
        if ((Test-Path -LiteralPath $taskRelease) -and
            ((Get-Content -LiteralPath $taskRelease -Raw) -match 'JAVA_VERSION="25[."]')) {
            $env:JAVA_HOME = $taskCandidate
            break
        }
    }
    if (!$env:JAVA_HOME -or !(Test-Path -LiteralPath (Join-Path $env:JAVA_HOME 'release')) -or
        !((Get-Content -LiteralPath (Join-Path $env:JAVA_HOME 'release') -Raw) -match 'JAVA_VERSION="25[."]')) {
        throw 'Java 25 requis. Installe un JDK 25 et renseigne JAVA_HOME, ou lance scripts/setup.ps1 -InstallToolchain sous Windows.'
    }
    if (!$env:ANDROID_HOME) { $env:ANDROID_HOME = $env:ANDROID_SDK_ROOT }
    if (!$env:ANDROID_HOME -and $env:LOCALAPPDATA) {
        $env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    }
    if (!$env:ANDROID_HOME -or !(Test-Path -LiteralPath $env:ANDROID_HOME)) {
        throw 'SDK Android introuvable. Installe-le avec Android Studio et renseigne ANDROID_HOME.'
    }
}

function Invoke-CheckedGit {
    param([string[]] $GitArguments)
    & git @GitArguments
    if ($LASTEXITCODE -ne 0) { throw "Git a échoué : $($GitArguments -join ' ')" }
}
