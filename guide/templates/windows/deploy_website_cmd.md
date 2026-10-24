# Deploy Website With CMD

> `thrustc` releases normally trigger this deployment automatically. This command is for manual use only.

```console
REM Run from the website repository root in Command Prompt.
REM Requires gh authenticated and GitHub Pages configured for GitHub Actions.
REM Optional environment values:
REM REPO      Repository in owner/name form.
REM WORKFLOW  Workflow file. Default: deploy-pages.yml
REM REF       Ref to deploy. Default: master
REM WAIT      Wait for completion. Default: 1
REM PLATFORM  Compiler platform: windows, linux, macos_intel, macos_arm
REM VERSION   Compiler version, with or without leading v.

scripts\deploy-website.bat

REM Dispatch without waiting.
set WAIT=0
scripts\deploy-website.bat

REM Update one compiler platform and deploy.
set PLATFORM=windows
set VERSION=0.2.5
scripts\deploy-website.bat
```
