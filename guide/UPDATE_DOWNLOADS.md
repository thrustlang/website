<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Update Downloads

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

This guide explains how to update the website download links from one compiler version to another with `scripts/update_downloads.py`.

## What It Does

`scripts/update_downloads.py` updates the downloads version used by the public pages.

The script changes the central downloads configuration in `assets/js/downloads.js` and also updates the visible fallback version labels in the English and Spanish pages.

## Command Shape

```console
$ python scripts/update_downloads.py --from-version <current-version> --to-version <new-version>
```

Versions can be passed with or without a leading `v`.

## Flags

| Flag | Required | What It Means | Example |
| --- | --- | --- | --- |
| `--from-version` | yes | Current downloads version expected in the site | `0.2.1` or `v0.2.1` |
| `--to-version` | yes | New downloads version to write | `0.2.2` or `v0.2.2` |
| `--test` | no | Print the planned changes without writing files | `--test` |

## Test Mode

Use `--test` when you want to confirm exactly what would change before editing files.

```console
$ python scripts/update_downloads.py --from-version 0.2.1 --to-version 0.2.2 --test
```

Example output:

```text
Current downloads version: 0.2.1
Target downloads version: 0.2.2

Test mode: no files will be changed.

Files that would change:
- assets/js/downloads.js
  version: "0.2.1" -> version: "0.2.2", 1 occurrence
- en/index.html
  v0.2.1 -> v0.2.2, 4 occurrences

No files changed.
```

## Examples

Update downloads from `0.2.1` to `0.2.2`:

```console
$ python scripts/update_downloads.py --from-version 0.2.1 --to-version 0.2.2
```

Run the same update as a test first:

```console
$ python scripts/update_downloads.py --from-version v0.2.1 --to-version v0.2.2 --test
```

## Files It Changes

- `assets/js/downloads.js`
- `en/index.html`
- `es/index.html`
- `en/downloads/index.html`
- `es/downloads/index.html`

## Common Mistakes

- passing a `--from-version` that does not match the current version in `assets/js/downloads.js`
- assuming `--test` writes files
- updating downloads before the matching GitHub Release assets exist
