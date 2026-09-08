<img src= "https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt= "logo" style= "width: 80%; height: 80%;"></img>

# Thrust Website Documentation Workflow

<img src= "https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt= "standard-separator" style= "width: 1hv;"> </img>

This guide explains how the website documentation system is organized, where the editable content lives, and how to update, release, and archive versioned documentation.

> [!IMPORTANT]
> The editable source of the website documentation lives under `documentation/content/`. The HTML files under `documentation/<version>/` are generated output.

## Overview

The website repository contains the official public pages and the official documentation for the Thrust Programming Language.

The documentation system is versioned. Each version has editable content, generated HTML output, a search index, and a public status in `documentation/versions.json`.

## Source Of Truth

The main inputs are:

- `documentation/content/<version>/pages.json`
- `documentation/content/<version>/compiler-command-line-reference.json`
- `documentation/versions.json`
- `thrustc/std/<version>/...`

`pages.json` stores the editable text, examples, summaries, and structured page content.

`versions.json` stores the version list, the current latest version, and the public status shown in the documentation hub.

The `thrustc/std/<version>/...` tree is used to extract public signatures for standard library pages.

## Generated Output

The generated output lives under `documentation/<version>/`.

That output includes:

- `documentation/<version>/index.html`
- `documentation/<version>/std/...`
- `documentation/<version>/language-reference/...`
- `documentation/<version>/search-index.json`

The documentation hub itself is regenerated at `documentation/index.html`.

## Maintenance Scripts

The repository contains four maintenance scripts under `scripts/`:

- `create_docs.py`
- `update_docs.py`
- `release_docs.py`
- `archive_docs.py`

These scripts rebuild the documentation after changing the editable state.

## Recommended Workflow

1. Create a new page scaffold with `scripts/create_docs.py` when a section needs a new page.
2. Update existing content with `scripts/update_docs.py`.
3. Publish a new documentation version with `scripts/release_docs.py`.
4. Mark older versions as archived with `scripts/archive_docs.py`.

## Related Guides

- [Scripts Reference](./DOCS_SCRIPTS_REFERENCE.md)
- [Update Docs](./UPDATE_DOCS.md)
- [Create Docs](./CREATE_DOCS.md)
- [Release Docs](./RELEASE_DOCS.md)
- [Archive Docs](./ARCHIVE_DOCS.md)

## Notes And Limitations

> [!NOTE]
> The documentation generator is intentionally simple. The editable content is stored in JSON and the generated HTML is treated as build output.

> [!NOTE]
> `scripts/update_docs.py` edits existing page fields. Use `scripts/create_docs.py` first when a page does not exist yet.

> [!WARNING]
> Releasing a new documentation version requires matching `std` sources in `thrustc/std/<new-version>/`.
