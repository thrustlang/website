# Create New Documentation Version

```console
# Run from the website repository root in PowerShell.
# Provide:
# <source-version>  Existing version to copy content from.
#                   Example values: v0.2.2, v0.2.3
# <new-version>     New documentation version id.
#                   Example values: v0.2.3, v0.2.4
# Remove the --from line if the current latest version should be used.

py scripts\create_new_version.py `
  --from <source-version> `
  --new-version <new-version>
```
