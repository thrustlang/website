<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Build Documentation

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

`documentation/assets/build_docs.py` rebuilds the generated documentation output from the editable documentation source.

Use it after changing documentation JSON or the documentation renderer so the generated HTML, search indexes, and social cards match the source files.

## What It Does

The script calls `build_all()` from `scripts/docs_common.py`.

It reads:

- `documentation/versions.json`
- `documentation/content/<version>/pages.json`
- `documentation/content/<version>/compiler-command-line-reference.json`
- `thrustc/std/<version>/...` for standard library public signatures

It regenerates:

- `documentation/index.html`
- `documentation/<version>/**/*.html`
- `documentation/<version>/search-index.json`
- `documentation/<version>/social/std/*.png`

## When It Is Useful

Use it when:

- You edited `documentation/content/<version>/pages.json`.
- You edited `documentation/content/<version>/compiler-command-line-reference.json`.
- You changed examples, summaries, overview text, notes, CLI descriptions, or language reference text.
- You changed `documentation/versions.json`.
- You changed the documentation generator in `scripts/docs_common.py`.
- You want generated HTML and search data to match the editable JSON before committing.

Do not use it to create a new page or a new documentation version.

## Command

Run from the website repository root:

```console
$ python3 documentation/assets/build_docs.py
```