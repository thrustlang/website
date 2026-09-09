<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Normalize Website Path For GH Pages

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

This guide explains how to normalize website paths for GitHub Pages subpath deployment with `scripts/normalize_website_path_for_gh_pages.py`.

## What It Does

`scripts/normalize_website_path_for_gh_pages.py` copies the website to an output directory and rewrites internal root-relative paths so the site can be served below a path such as `/website`.

The source checkout is not modified.

## Command Shape

```console
$ python scripts/normalize_website_path_for_gh_pages.py --base-path /website --output /tmp/thrust-website-build
```

## Flags

| Flag | Required | What It Means | Example |
| --- | --- | --- | --- |
| `--base-path` | yes | URL path where the copied site will be served | `/website` |
| `--output` | yes | Destination directory for the built copy | `/tmp/thrust-website-build` |
| `--source` | no | Website checkout to copy | `/path/to/website` |

## Rewritten Paths

- `/assets/...`
- `/documentation/...`
- `/en/...`
- `/es/...`

External URLs are not rewritten.

## Files It Changes

- the directory passed through `--output`

The script replaces an existing output directory.
