# Generate Standard Library Social Cards

```console
# Run from the website repository root.
# Provide:
# <version>  Documentation version id.
#            Example values: v0.2.2, v0.2.3
# <slug>     Existing std page slug.
#            Example values: io, math, collections/vector
# Remove the --slug line to generate every std card for the version.

python3 scripts/generate_std_social_cards.py \
  --version <version> \
  --slug <slug>
```
