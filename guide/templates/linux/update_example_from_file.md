# Update Example From File

```console
# Run from the website repository root.
# Provide:
# <version>       Documentation version id.
#                 Example values: v0.2.2, v0.2.3
# <section>       std or language-reference.
#                 Example values: std, language-reference
# <slug>          Existing page slug.
#                 Example values: io, collections/vector, functions, deref
# <example-file>  Path to the file containing the new example text.
#                 Example values: ./tmp/example.thrust, /tmp/example.thrust

python3 scripts/update_docs.py \
  --version <version> \
  --section <section> \
  --slug <slug> \
  --field example \
  --input-file <example-file>
```
