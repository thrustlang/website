$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = (Get-Item (Join-Path $ScriptDir "..")).FullName
$BasePath = if ($env:BASE_PATH) { $env:BASE_PATH } else { "/website" }
$PythonBin = if ($env:PYTHON_BIN) { $env:PYTHON_BIN } else { "python" }
$TempSite = Join-Path $env:TEMP "thrust-website-pages"
$PagesWorktree = Join-Path $env:TEMP "thrust-website-gh-pages"

Set-Location $ProjectDir

if ($env:REMOTE_NAME) {
    $Remote = $env:REMOTE_NAME
} elseif (git remote get-url origin 2>$null) {
    $Remote = "origin"
} else {
    $Remote = (git remote | Select-Object -First 1)
}

if (-not $Remote) {
    throw "No git remote configured. Add one or set REMOTE_NAME."
}

Write-Host "Using project directory: $ProjectDir" -ForegroundColor Cyan
Write-Host "Using remote: $Remote" -ForegroundColor Cyan

$remoteBranch = git ls-remote --heads $Remote gh-pages
if (-not $remoteBranch) {
    Write-Host "Branch 'gh-pages' not found on remote '$Remote'. Creating it from a temporary repository..." -ForegroundColor Yellow
    $TempEmpty = Join-Path $env:TEMP ("thrust-website-empty-gh-pages-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $TempEmpty | Out-Null
    git -C $TempEmpty init
    git -C $TempEmpty commit --allow-empty -m "Initial gh-pages commit"
    $RemoteUrl = git remote get-url $Remote
    git -C $TempEmpty push $RemoteUrl HEAD:gh-pages
    Remove-Item -Recurse -Force $TempEmpty
}

Write-Host "Building website for $BasePath..."
if (Test-Path $TempSite) { Remove-Item -Recurse -Force $TempSite }
& $PythonBin "scripts/build_subpath.py" --base-path $BasePath --output $TempSite

Write-Host "Deploying website to GitHub Pages..."
if (Test-Path $PagesWorktree) { Remove-Item -Recurse -Force $PagesWorktree }
git fetch $Remote gh-pages
git worktree add --detach $PagesWorktree FETCH_HEAD

Push-Location $PagesWorktree
    Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force
    Copy-Item -Path "$TempSite\*" -Destination "." -Recurse -Force
    Copy-Item -Path (Join-Path $TempSite ".nojekyll") -Destination ".nojekyll" -Force

    git add -A
    if (git diff-index --quiet HEAD --) {
        Write-Host "No changes to website."
    } else {
        $date = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Update website $date"
        git push $Remote HEAD:gh-pages
    }
Pop-Location

git worktree remove $PagesWorktree
if (Test-Path $TempSite) { Remove-Item -Recurse -Force $TempSite }

Write-Host "Done. Website updated successfully." -ForegroundColor Green
