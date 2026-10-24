@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%.."

if not defined WORKFLOW set "WORKFLOW=deploy-pages.yml"
if not defined REF set "REF=master"
if not defined WAIT set "WAIT=1"

if defined BASE_PATH echo warning: BASE_PATH is no longer used. 1>&2
if defined PYTHON_BIN echo warning: PYTHON_BIN is no longer used. 1>&2
if defined REMOTE_NAME echo warning: REMOTE_NAME is no longer used. 1>&2

where gh >nul 2>&1
if errorlevel 1 (
    echo error: the GitHub CLI ^(gh^) is required. 1>&2
    exit /b 1
)

gh auth status >nul 2>&1
if errorlevel 1 (
    echo error: gh is not authenticated. Run 'gh auth login' first. 1>&2
    exit /b 1
)

if not defined REPO (
    for /f "tokens=*" %%i in ('gh repo view --json nameWithOwner --jq .nameWithOwner 2^>nul') do set "REPO=%%i"
)

if not defined REPO (
    echo error: could not resolve the repository. Set REPO=owner/name. 1>&2
    exit /b 1
)

gh workflow view "%WORKFLOW%" --repo "%REPO%" >nul 2>&1
if errorlevel 1 (
    echo error: workflow '%WORKFLOW%' was not found in '%REPO%'. 1>&2
    exit /b 1
)

set "BUILD_TYPE="
for /f "tokens=*" %%i in ('gh api "repos/%REPO%/pages" --jq .build_type 2^>nul') do set "BUILD_TYPE=%%i"

if not defined BUILD_TYPE (
    echo warning: could not verify the GitHub Pages source for '%REPO%'. 1>&2
) else if not "%BUILD_TYPE%"=="workflow" (
    echo error: GitHub Pages source is '%BUILD_TYPE%'; configure it to use GitHub Actions. 1>&2
    exit /b 1
)

if defined PLATFORM if not defined VERSION (
    echo error: PLATFORM and VERSION must be provided together. 1>&2
    exit /b 1
)

if not defined PLATFORM if defined VERSION (
    echo error: PLATFORM and VERSION must be provided together. 1>&2
    exit /b 1
)

if defined PLATFORM (
    if /i not "%PLATFORM%"=="windows" if /i not "%PLATFORM%"=="linux" if /i not "%PLATFORM%"=="macos_intel" if /i not "%PLATFORM%"=="macos_arm" (
        echo error: unknown PLATFORM '%PLATFORM%'. 1>&2
        exit /b 1
    )

    if /i "!VERSION:~0,1!"=="v" set "VERSION=!VERSION:~1!"
)

set "DIRTY="
for /f "delims=" %%i in ('git status --porcelain 2^>nul') do set "DIRTY=1"
if defined DIRTY echo warning: the working tree is not clean. The workflow deploys '%REF%', not local changes. 1>&2

set "GH_ARGS=workflow run %WORKFLOW% --repo %REPO% --ref %REF%"

if defined PLATFORM set "GH_ARGS=%GH_ARGS% -f platform=%PLATFORM% -f version=%VERSION%"

set "BEFORE_ID="
for /f "tokens=*" %%i in ('gh run list --workflow "%WORKFLOW%" --repo "%REPO%" --branch "%REF%" --event workflow_dispatch --limit 1 --jq ".[0].databaseId" 2^>nul') do set "BEFORE_ID=%%i"

gh %GH_ARGS%
if errorlevel 1 exit /b 1

set "RUN_ID="
set "RUN_URL="

for /l %%N in (1,1,30) do (
    if not defined RUN_ID (
        timeout /t 2 /nobreak >nul

        set "CANDIDATE_ID="
        set "CANDIDATE_URL="

        for /f "tokens=*" %%i in ('gh run list --workflow "%WORKFLOW%" --repo "%REPO%" --branch "%REF%" --event workflow_dispatch --limit 1 --jq ".[0].databaseId" 2^>nul') do set "CANDIDATE_ID=%%i"
        for /f "tokens=*" %%i in ('gh run list --workflow "%WORKFLOW%" --repo "%REPO%" --branch "%REF%" --event workflow_dispatch --limit 1 --jq ".[0].url" 2^>nul') do set "CANDIDATE_URL=%%i"

        if defined CANDIDATE_ID if not "!CANDIDATE_ID!"=="!BEFORE_ID!" (
            set "RUN_ID=!CANDIDATE_ID!"
            set "RUN_URL=!CANDIDATE_URL!"
        )
    )
)

if not defined RUN_ID (
    echo Deployment dispatched. Could not resolve the run URL; check the Actions tab. 1>&2
    exit /b 0
)

echo Deployment run: %RUN_URL%

if /i "%WAIT%"=="1" (
    gh run watch "%RUN_ID%" --repo "%REPO%" --exit-status
    exit /b !errorlevel!
)

if /i "%WAIT%"=="true" (
    gh run watch "%RUN_ID%" --repo "%REPO%" --exit-status
    exit /b !errorlevel!
)

echo Not waiting for completion (WAIT=0).
exit /b 0
