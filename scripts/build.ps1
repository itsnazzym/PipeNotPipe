param([switch] $Release, [switch] $SkipLint)
. "$PSScriptRoot/environment.ps1"
Initialize-BuildEnvironment
& "$PSScriptRoot/check-architecture.ps1"
if ($Release) {
    foreach ($taskSecret in @('KEY_PATH', 'KEY_STORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD')) {
        if (![Environment]::GetEnvironmentVariable($taskSecret)) { throw "Signature release : variable $taskSecret manquante." }
    }
}
$taskVariant = if ($Release) { 'Release' } else { 'Debug' }
$taskTasks = @(':core:cache:test', ':data:media:test', ":app:assemble$taskVariant")
if (!$SkipLint) { $taskTasks += ":app:lint$taskVariant" }
$taskWrapper = if ($env:OS -eq 'Windows_NT') { './gradlew.bat' } else { './gradlew' }
Push-Location (Join-Path $script:WorkspaceRoot 'PipePipeClient')
try {
    & $taskWrapper @taskTasks '--console=plain'
    if ($LASTEXITCODE -ne 0) { throw 'La validation Gradle a échoué.' }
} finally { Pop-Location }
$taskArtifacts = Join-Path $script:WorkspaceRoot 'artifacts'
New-Item -ItemType Directory -Force -Path $taskArtifacts | Out-Null
$taskOutput = Join-Path $script:WorkspaceRoot "PipePipeClient/app/build/outputs/apk/$($taskVariant.ToLowerInvariant())"
$taskApks = @(Get-ChildItem -LiteralPath $taskOutput -Filter '*.apk')
if (!$taskApks.Count) { throw 'Aucun APK produit.' }
$taskChecksums = foreach ($taskApk in $taskApks) {
    Copy-Item -LiteralPath $taskApk.FullName -Destination $taskArtifacts -Force
    $taskHash = Get-FileHash -LiteralPath $taskApk.FullName -Algorithm SHA256
    "$($taskHash.Hash.ToLowerInvariant())  $($taskApk.Name)"
}
$taskChecksums | Set-Content -LiteralPath (Join-Path $taskArtifacts "CHECKSUMS-$($taskVariant.ToLowerInvariant()).txt") -Encoding utf8
Write-Host "APKs et SHA-256 : $taskArtifacts"
