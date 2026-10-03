# Create Language Reference Page

```console
# Run from the website repository root in PowerShell.
# Provide:
# <version>  Documentation version id.
#            Example values: v0.2.2, v0.2.3
# <slug>     Page slug inside language-reference.
#            Example values: functions, types, deref, modules
# <title>    Public topic title.
#            Example values: Functions, Types, Deref and Pointers
# <summary>  Short topic summary.
#            Example values: Function declarations and calls., Pointer access and dereference operations.
# <source>   Source reference metadata.
#            Example values: syntax/function/function.md, syntax/types/primitives.md

py scripts\create_docs.py `
  --version <version> `
  --section language-reference `
  --slug <slug> `
  --title "<title>" `
  --summary "<summary>" `
  --source <source>
```
