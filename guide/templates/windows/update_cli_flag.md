# Update CLI Flag

```console
# Run from the website repository root in PowerShell.
# Provide:
# <version>   Documentation version id.
#             Example values: v0.2.2, v0.2.3
# <category>  CLI category slug.
#             Example values: general, compiler-flags, disable-flags
# <flag>      CLI flag name or alias.
#             Example values: -emit, -std-version, --disable-safe-math
# <field>     Existing flag field to replace.
#             Example values: description, details, examples, notes
# <value>     New plain text value.
#             Example values: Emit one selected compilation artifact., Updated flag note.

py scripts\update_docs.py `
  --version <version> `
  --section compiler-command-line-reference `
  --category <category> `
  --flag=<flag> `
  --field <field> `
  --value "<value>"
```
