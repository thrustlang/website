# Update Page List Field

```console
# Run from the website repository root.
# Provide:
# <version>    Documentation version id.
#              Example values: v0.2.2, v0.2.3
# <section>    std or language-reference.
#              Example values: std, language-reference
# <slug>       Existing page slug.
#              Example values: io, math, functions, modules
# <field>      Existing list field to replace.
#              Example values: overview, details, examples, notes, semantics
# <json-list>  JSON array of strings.
#              Example values: ["<first item>", "<second item>"]

python3 scripts/update_docs.py \
  --version <version> \
  --section <section> \
  --slug <slug> \
  --field <field> \
  --json-value '<json-list>'
```
