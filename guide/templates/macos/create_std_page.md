# Create Standard Library Page

```console
# Run from the website repository root.
# Provide:
# <version>      Documentation version id.
#                Example values: v0.2.2, v0.2.3
# <slug>         Page slug inside the std section.
#                Example values: io, math, collections/vector, ffi/c/int
# <title>        Public page title.
#                Example values: std::io, std::collections::vector
# <summary>      Short page summary.
#                Example values: Input and output APIs., Dynamic array container.
# <source-file>  File under thrustc/std/<version>/.
#                Example values: io.thrust, collections/vector.thrust

python3 scripts/create_docs.py \
  --version <version> \
  --section std \
  --slug <slug> \
  --title "<title>" \
  --summary "<summary>" \
  --source <source-file>
```
