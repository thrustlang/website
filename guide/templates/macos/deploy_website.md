# Deploy Website

> `thrustc` releases normally trigger this deployment automatically. This command is for manual use only.

```console
# Run from the website repository root.
# Requires gh authenticated and GitHub Pages configured for GitHub Actions.
# Optional environment values:
# REPO      Repository in owner/name form.
# WORKFLOW  Workflow file. Default: deploy-pages.yml
# REF       Ref to deploy. Default: master
# WAIT      Wait for completion. Default: 1
# PLATFORM  Compiler platform: windows, linux, macos_intel, macos_arm
# VERSION   Compiler version, with or without leading v.

bash scripts/deploy-website.sh

# Dispatch without waiting.
WAIT=0 bash scripts/deploy-website.sh

# Update one compiler platform and deploy.
PLATFORM=macos_arm VERSION=0.2.5 bash scripts/deploy-website.sh
```
