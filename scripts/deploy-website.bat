@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%.."
set "PROJECT_DIR=%cd%"

if not defined BASE_PATH set "BASE_PATH=/website"
if not defined PYTHON_BIN set "PYTHON_BIN=python"

set "TEMP_SITE=%TEMP%\thrust-website-pages"
set "PAGES_WORKTREE=%TEMP%\thrust-website-gh-pages"

echo Using project directory: %PROJECT_DIR%

git rev-parse --verify origin/gh-pages >nul 2>&1
if %errorlevel% neq 0 (
    echo Branch 'gh-pages' not found. Creating orphan branch...
    for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
    git checkout --orphan gh-pages
    git rm -rf .
    git commit --allow-empty -m "Initial gh-pages commit"
    git push origin gh-pages
    git checkout !CURRENT_BRANCH!
)

echo Building website for %BASE_PATH%...
if exist "%TEMP_SITE%" rd /s /q "%TEMP_SITE%"
"%PYTHON_BIN%" scripts\build_subpath.py --base-path "%BASE_PATH%" --output "%TEMP_SITE%"

echo Deploying website to GitHub Pages...
if exist "%PAGES_WORKTREE%" rd /s /q "%PAGES_WORKTREE%"

git fetch origin gh-pages
git worktree add "%PAGES_WORKTREE%" gh-pages

pushd "%PAGES_WORKTREE%"
    for /f "delims=" %%i in ('dir /b') do (
        if not "%%i"==".git" (
            if exist "%%i\" (rd /s /q "%%i") else (del /q "%%i")
        )
    )

    xcopy /e /i /y "%TEMP_SITE%\*" "."

    git add -A
    git diff-index --quiet HEAD --
    if %errorlevel% equ 0 (
        echo No changes to website.
    ) else (
        git commit -m "Update website %date% %time%"
        git push origin gh-pages
    )
popd

git worktree remove "%PAGES_WORKTREE%"
rd /s /q "%TEMP_SITE%"

echo Done. Website updated successfully.
