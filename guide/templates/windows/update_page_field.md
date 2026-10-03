# Update Page Field

```console
# Run from the website repository root in PowerShell.
# Provide:
# <version>  Documentation version id.
#            Example values: v0.2.2, v0.2.3
# <section>  std or language-reference.
#            Example values: std, language-reference
# <slug>     Existing page slug.
#            Example values: io, collections/vector, functions, deref
# <field>    Existing field to replace.
#            Example values: summary, overview, details, notes, semantics
# <value>    New plain text value.
#            Example values: Short replacement text., Updated behavior note.

py scripts\update_docs.py `
  --version <version> `
  --section <section> `
  --slug <slug> `
  --field <field> `
  --value "<value>"
```
