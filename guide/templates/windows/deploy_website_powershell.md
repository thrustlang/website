# Deploy Website With PowerShell

```console
# Run from the website repository root in PowerShell.
# This builds the website for the configured base path and pushes gh-pages.
# Optional environment values:
# BASE_PATH   Deployment base path.
#             Example values: /website, /
# PYTHON_BIN  Python executable.
#             Example values: py, python

powershell -ExecutionPolicy Bypass -File scripts\deploy-website.ps1
```
