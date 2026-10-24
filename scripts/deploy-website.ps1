$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = (Get-Item (Join-Path $ScriptDir "..")).FullName

$Repo = if ($env:REPO) { $env:REPO } else { "" }
$Workflow = if ($env:WORKFLOW) { $env:WORKFLOW } else { "deploy-pages.yml" }
$Ref = if ($env:REF) { $env:REF } else { "master" }
$Wait = if ($env:WAIT) { $env:WAIT } else { "1" }
$Platform = if ($env:PLATFORM) { $env:PLATFORM } else { "" }
$Version = if ($env:VERSION) { $env:VERSION } else { "" }

Set-Location $ProjectDir

if ($env:BASE_PATH -or $env:PYTHON_BIN -or $env:REMOTE_NAME) {
    Write-Warning "BASE_PATH, PYTHON_BIN and REMOTE_NAME are no longer used."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "The GitHub CLI (gh) is required."
}

gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "gh is not authenticated. Run 'gh auth login' first."
}

if (-not $Repo) {
    $Repo = gh repo view --json nameWithOwner --jq .nameWithOwner

    if ($LASTEXITCODE -ne 0 -or -not $Repo) {
        throw "Could not resolve the repository. Set REPO=owner/name."
    }
}

gh workflow view $Workflow --repo $Repo 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Workflow '$Workflow' was not found in '$Repo'."
}

$BuildType = gh api "repos/$Repo/pages" --jq .build_type 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Could not verify the GitHub Pages source for '$Repo'."
} elseif ($BuildType -ne "workflow") {
    throw "GitHub Pages source is '$BuildType'; configure it to use GitHub Actions."
}

if ($Platform -or $Version) {
    if (-not $Platform -or -not $Version) {
        throw "PLATFORM and VERSION must be provided together."
    }

    if ($Platform -notin @("windows", "linux", "macos_intel", "macos_arm")) {
        throw "Unknown PLATFORM '$Platform'."
    }

    $Version = $Version -replace "^v", ""
}

$Dirty = git status --porcelain
if ($Dirty) {
    Write-Warning "The working tree is not clean. The workflow deploys '$Ref', not local changes."
}

$BeforeId = gh run list --workflow $Workflow --repo $Repo --branch $Ref --event workflow_dispatch --limit 1 --jq ".[0].databaseId" 2>$null

if ($LASTEXITCODE -ne 0) {
    $BeforeId = ""
}

$Arguments = @("workflow", "run", $Workflow, "--repo", $Repo, "--ref", $Ref)

if ($Platform) {
    $Arguments += @("-f", "platform=$Platform", "-f", "version=$Version")
}

& gh @Arguments
if ($LASTEXITCODE -ne 0) {
    throw "Could not dispatch the deployment workflow."
}

$RunId = ""
$RunUrl = ""

for ($Attempt = 0; $Attempt -lt 30; $Attempt++) {
    Start-Sleep -Seconds 2

    $CandidateId = gh run list --workflow $Workflow --repo $Repo --branch $Ref --event workflow_dispatch --limit 1 --jq ".[0].databaseId" 2>$null
    $CandidateUrl = gh run list --workflow $Workflow --repo $Repo --branch $Ref --event workflow_dispatch --limit 1 --jq ".[0].url" 2>$null

    if ($LASTEXITCODE -eq 0 -and $CandidateId -and $CandidateId -ne $BeforeId) {
        $RunId = $CandidateId
        $RunUrl = $CandidateUrl
        break
    }
}

if (-not $RunId) {
    Write-Warning "Deployment dispatched. Could not resolve the run URL; check the Actions tab."
    return
}

Write-Host "Deployment run: $RunUrl" -ForegroundColor Cyan

if ($Wait -in @("1", "true", "TRUE", "yes", "YES")) {
    & gh run watch $RunId --repo $Repo --exit-status
    exit $LASTEXITCODE
}

Write-Host "Not waiting for completion (WAIT=0)." -ForegroundColor Yellow
