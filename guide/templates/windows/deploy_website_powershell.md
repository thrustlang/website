# Deploy Website With PowerShell

> `thrustc` releases normally trigger this deployment automatically. This command is for manual use only.

```console
# Run from the website repository root in PowerShell.
# Requires gh authenticated and GitHub Pages configured for GitHub Actions.
# Optional environment values:
# REPO      Repository in owner/name form.
# WORKFLOW  Workflow file. Default: deploy-pages.yml
# REF       Ref to deploy. Default: master
# WAIT      Wait for completion. Default: 1
# PLATFORM  Compiler platform: windows, linux, macos_intel, macos_arm
# VERSION   Compiler version, with or without leading v.

powershell -ExecutionPolicy Bypass -File scripts\deploy-website.ps1

# Dispatch without waiting.
$env:WAIT = "0"
powershell -ExecutionPolicy Bypass -File scripts\deploy-website.ps1

# Update one compiler platform and deploy.
$env:PLATFORM = "windows"
$env:VERSION = "0.2.5"
powershell -ExecutionPolicy Bypass -File scripts\deploy-website.ps1
```
