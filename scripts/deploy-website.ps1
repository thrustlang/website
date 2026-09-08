$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = (Get-Item (Join-Path $ScriptDir "..")).FullName
$BasePath = if ($env:BASE_PATH) { $env:BASE_PATH } else { "/website" }
$PythonBin = if ($env:PYTHON_BIN) { $env:PYTHON_BIN } else { "python" }
$TempSite = Join-Path $env:TEMP "thrust-website-pages"
$PagesWorktree = Join-Path $env:TEMP "thrust-website-gh-pages"

Set-Location $ProjectDir
Write-Host "Using project directory: $ProjectDir" -ForegroundColor Cyan

$remoteBranch = git ls-remote --heads origin gh-pages
if (-not $remoteBranch) {
    Write-Host "Branch 'gh-pages' not found. Creating orphan branch..." -ForegroundColor Yellow
    $currentBranch = git branch --show-current
    git checkout --orphan gh-pages
    git rm -rf .
    git commit --allow-empty -m "Initial gh-pages commit"
    git push origin gh-pages
    git checkout $currentBranch
}

Write-Host "Building website for $BasePath..."
if (Test-Path $TempSite) { Remove-Item -Recurse -Force $TempSite }
& $PythonBin "scripts/build_subpath.py" --base-path $BasePath --output $TempSite

Write-Host "Deploying website to GitHub Pages..."
if (Test-Path $PagesWorktree) { Remove-Item -Recurse -Force $PagesWorktree }

git fetch origin gh-pages
git worktree add $PagesWorktree gh-pages

Push-Location $PagesWorktree
    Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force
    Copy-Item -Path "$TempSite\*" -Destination "." -Recurse

    git add -A
    if (git diff-index --quiet HEAD --) {
        Write-Host "No changes to website."
    } else {
        $date = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Update website $date"
        git push origin gh-pages
    }
Pop-Location

git worktree remove $PagesWorktree
Remove-Item -Recurse -Force $TempSite

Write-Host "Done. Website updated successfully." -ForegroundColor Green
