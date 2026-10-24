# Update Downloads

> Compiler downloads update automatically per platform after a `thrustc` release. This command updates the package manager (`torio`) version.

```console
# Run from the website repository root.
# Provide:
# <current-version>  Version currently written in the website downloads.
#                    Example values: 0.1.4, v0.1.4
# <new-version>      Version to write into downloads.
#                    Example values: 0.1.5, v0.1.5

python3 scripts/update_downloads.py \
  --from-version <current-version> \
  --to-version <new-version>
```
