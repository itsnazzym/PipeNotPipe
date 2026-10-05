param([switch] $InstallToolchain)
. "$PSScriptRoot/environment.ps1"

if ($InstallToolchain) {
    if (!$env:USERPROFILE) { throw 'Installation automatique du JDK réservée à Windows. Configure JAVA_HOME sur les autres systèmes.' }
    $taskDestination = Join-Path $env:USERPROFILE '.codex\tools\jdk-25'
    New-Item -ItemType Directory -Force -Path $taskDestination | Out-Null
    $taskExisting = @(Get-ChildItem -LiteralPath $taskDestination -Directory)
    if ($taskExisting.Count -eq 0) {
        $taskArchive = Join-Path ([IO.Path]::GetTempPath()) ('pipenotpipe-jdk25-' + [guid]::NewGuid() + '.zip')
        try {
            Write-Host 'Installation du JDK Temurin 25...'
            Invoke-WebRequest 'https://api.adoptium.net/v3/binary/latest/25/ga/windows/x64/jdk/hotspot/normal/eclipse' -OutFile $taskArchive
            Expand-Archive -LiteralPath $taskArchive -DestinationPath $taskDestination
        } finally {
            if (Test-Path -LiteralPath $taskArchive) { Remove-Item -LiteralPath $taskArchive }
        }
    }
}
Initialize-BuildEnvironment
Push-Location $script:WorkspaceRoot
try {
    Invoke-CheckedGit -GitArguments @('submodule', 'sync', '--', 'PipePipeClient', 'PipePipeExtractor')
    foreach ($taskModule in @('PipePipeClient', 'PipePipeExtractor')) {
        $taskGitMarker = Join-Path $script:WorkspaceRoot "$taskModule/.git"
        if (!(Test-Path -LiteralPath $taskGitMarker)) {
            Invoke-CheckedGit -GitArguments @('submodule', 'update', '--init', '--', $taskModule)
        }
        $taskUpstream = "https://github.com/InfinityLoop1308/$taskModule.git"
        $taskRemotes = & git -C $taskModule remote
        if ($LASTEXITCODE -ne 0) { throw 'Impossible de lire les remotes.' }
        if ($taskRemotes -notcontains 'upstream') {
            Invoke-CheckedGit -GitArguments @('-C', $taskModule, 'remote', 'add', 'upstream', $taskUpstream)
        }
        $taskBranch = & git -C $taskModule symbolic-ref -q --short HEAD
        if (!$taskBranch) {
            # Preserve the pinned revision: do not jump to a possibly newer main branch.
            $taskRevision = & git -C $taskModule rev-parse HEAD
            $taskMain = & git -C $taskModule rev-parse --verify refs/heads/main 2>$null
            if ($LASTEXITCODE -eq 0 -and $taskMain -eq $taskRevision) {
                Invoke-CheckedGit -GitArguments @('-C', $taskModule, 'switch', 'main')
            } else {
                Invoke-CheckedGit -GitArguments @('-C', $taskModule, 'switch', '-c', "work/$($taskRevision.Substring(0, 12))")
            }
        }
    }
    $taskGradleDirectory = Join-Path $script:WorkspaceRoot 'PipePipeClient/.gradle'
    New-Item -ItemType Directory -Force -Path $taskGradleDirectory | Out-Null
    $taskJavaProperty = 'java.home=' + $env:JAVA_HOME.Replace('\', '/')
    $taskGradleProperties = Join-Path $taskGradleDirectory 'config.properties'
    $taskExistingProperties = if (Test-Path -LiteralPath $taskGradleProperties) {
        @(Get-Content -LiteralPath $taskGradleProperties | Where-Object { $_ -notmatch '^java\.home\s*=' })
    } else { @() }
    @($taskExistingProperties; $taskJavaProperty) | Set-Content -LiteralPath $taskGradleProperties -Encoding utf8
    Write-Host "Prêt. JAVA_HOME=$env:JAVA_HOME"
    Write-Host 'Ouvre PipePipeClient dans Android Studio, puis utilise scripts/build.ps1.'
} finally { Pop-Location }
