# Update Downloads

```console
# Run from the website repository root.
# Provide:
# <current-version>  Version currently written in the website downloads.
#                    Example values: 0.2.2, v0.2.2
# <new-version>      Version to write into downloads.
#                    Example values: 0.2.3, v0.2.3
# Add --test to preview changes without writing files.

python3 scripts/update_downloads.py \
  --from-version <current-version> \
  --to-version <new-version>
```
