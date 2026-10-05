$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskClient = Join-Path $taskRoot 'PipePipeClient'
$taskFailures = @()
foreach ($taskModule in @('core/cache', 'data/media')) {
    $taskSources = Join-Path $taskClient "$taskModule/src/main/java"
    foreach ($taskFile in Get-ChildItem -LiteralPath $taskSources -Recurse -File -Filter '*.java') {
        $taskSource = Get-Content -LiteralPath $taskFile.FullName -Raw
        if ($taskSource -match '(?m)^import\s+(android\.|androidx\.|org\.schabi\.newpipe\.(?!extractor\.))') {
            $taskFailures += "Dépendance Android/UI interdite : $($taskFile.FullName)"
        }
    }
    $taskBuild = Get-Content -LiteralPath (Join-Path $taskClient "$taskModule/build.gradle") -Raw
    if ($taskBuild -match 'project\([''"]:app[''"]\)') {
        $taskFailures += "$taskModule dépend de :app"
    }
}
if ($taskFailures.Count) { throw ($taskFailures -join [Environment]::NewLine) }
Write-Host "Architecture verifiee : core et data restent independants d'Android et de l'interface."
