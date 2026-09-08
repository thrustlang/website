@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%.."
set "PROJECT_DIR=%cd%"

if not defined BASE_PATH set "BASE_PATH=/website"
if not defined PYTHON_BIN set "PYTHON_BIN=python"

set "TEMP_SITE=%TEMP%\thrust-website-pages"
set "PAGES_WORKTREE=%TEMP%\thrust-website-gh-pages"

if defined REMOTE_NAME (
    set "REMOTE=%REMOTE_NAME%"
) else (
    git remote get-url origin >nul 2>&1
    if !errorlevel! equ 0 (
        set "REMOTE=origin"
    ) else (
        for /f "tokens=*" %%i in ('git remote') do if not defined REMOTE set "REMOTE=%%i"
    )
)

if not defined REMOTE (
    echo No git remote configured. Add one or set REMOTE_NAME. 1>&2
    exit /b 1
)

echo Using project directory: %PROJECT_DIR%
echo Using remote: %REMOTE%

git ls-remote --exit-code --heads "%REMOTE%" gh-pages >nul 2>&1
if %errorlevel% neq 0 (
    echo Branch 'gh-pages' not found on remote '%REMOTE%'. Creating it from a temporary repository...
    set "TEMP_EMPTY=%TEMP%\thrust-website-empty-gh-pages-%RANDOM%%RANDOM%"
    mkdir "%TEMP_EMPTY%"
    git -C "%TEMP_EMPTY%" init
    git -C "%TEMP_EMPTY%" commit --allow-empty -m "Initial gh-pages commit"
    for /f "tokens=*" %%i in ('git remote get-url "%REMOTE%"') do set "REMOTE_URL=%%i"
    git -C "%TEMP_EMPTY%" push "%REMOTE_URL%" HEAD:gh-pages
    if errorlevel 1 exit /b 1
    rd /s /q "%TEMP_EMPTY%"
)

echo Building website for %BASE_PATH%...
if exist "%TEMP_SITE%" rd /s /q "%TEMP_SITE%"
"%PYTHON_BIN%" scripts\build_subpath.py --base-path "%BASE_PATH%" --output "%TEMP_SITE%"
if errorlevel 1 exit /b 1

echo Deploying website to GitHub Pages...
if exist "%PAGES_WORKTREE%" rd /s /q "%PAGES_WORKTREE%"
git fetch "%REMOTE%" gh-pages
if errorlevel 1 exit /b 1
git worktree add --detach "%PAGES_WORKTREE%" FETCH_HEAD
if errorlevel 1 exit /b 1

pushd "%PAGES_WORKTREE%"
    for /f "delims=" %%i in ('dir /b') do (
        if not "%%i"==".git" (
            if exist "%%i\" (rd /s /q "%%i") else (del /q "%%i")
        )
    )

    xcopy /e /i /y "%TEMP_SITE%\*" "."
    if errorlevel 1 exit /b 1

    git add -A
    git diff-index --quiet HEAD --
    if !errorlevel! equ 0 (
        echo No changes to website.
    ) else (
        git commit -m "Update website %date% %time%"
        if errorlevel 1 exit /b 1
        git push "%REMOTE%" HEAD:gh-pages
        if errorlevel 1 exit /b 1
    )
popd

git worktree remove "%PAGES_WORKTREE%"
if exist "%TEMP_SITE%" rd /s /q "%TEMP_SITE%"

echo Done. Website updated successfully.
