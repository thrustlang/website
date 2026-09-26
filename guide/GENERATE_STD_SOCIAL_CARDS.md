<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Generate Std Social Cards

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

This guide explains how to generate PNG Open Graph cards for standard library pages with `scripts/generate_std_social_cards.py`.

## What It Does

The script reads standard library page metadata from `documentation/content/<version>/pages.json` and generates social preview images under `documentation/<version>/social/std/`.

## Dependency

Install Python dependencies first:

```console
$ python -m pip install -r requirements.txt
```

The script requires `Pillow`.

## Command Shape

```console
$ python scripts/generate_std_social_cards.py [--version <version>] [--slug <std-slug>]
```

## Flags

| Flag | Required | What It Means | Example |
| --- | --- | --- | --- |
| `--version` | no | Documentation version to generate | `v0.2.1` |
| `--slug` | no | One standard library page slug | `mem` or `collections/vector` |

`--slug` requires `--version`.

## Examples

Generate all cards for all versions:

```console
$ python scripts/generate_std_social_cards.py
```

Generate one version:

```console
$ python scripts/generate_std_social_cards.py --version v0.2.1
```

Generate one module:

```console
$ python scripts/generate_std_social_cards.py --version v0.2.1 --slug mem
```

## Files It Changes

- `documentation/<version>/social/std/*.png`
