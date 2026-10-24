<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Deploy Website

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

> [!NOTE]
> `thrustc` automatically updates the compiler download versions and deploys the website at the end of every platform release.

This guide explains how to deploy the website manually with the platform-specific `scripts/deploy-website.*` scripts.

## What They Do

The deploy scripts trigger the `Deploy Website` GitHub Actions workflow. The workflow builds the site with `scripts/normalize_website_path_for_gh_pages.py` and publishes it through GitHub Pages.

## Requirements

- The GitHub CLI (`gh`) installed and authenticated with `gh auth login`.
- GitHub Pages configured to publish from **GitHub Actions** in the repository settings.
- The changes to deploy must already be committed and pushed to the target ref.

## Command Shape

```console
$ bash scripts/deploy-website.sh
```

```console
$ fish scripts/deploy-website.fish
```

```powershell
PS> powershell -ExecutionPolicy Bypass -File scripts/deploy-website.ps1
```

```console
> scripts\deploy-website.bat
```

## Environment Values

| Value | Default | What It Means |
| --- | --- | --- |
| `REPO` | Current repository | Repository in `owner/name` form |
| `WORKFLOW` | `deploy-pages.yml` | Workflow file to dispatch |
| `REF` | `master` | Ref to deploy |
| `WAIT` | `1` | Wait for the workflow to finish |
| `PLATFORM` | Unset | Compiler platform to update: `windows`, `linux`, `macos_intel`, or `macos_arm` |
| `VERSION` | Unset | Compiler version to write, with or without a leading `v` |

`PLATFORM` and `VERSION` must be provided together.

## Flow

1. Verifies that `gh` is installed and authenticated.
2. Resolves the repository and checks that the workflow exists.
3. Checks that GitHub Pages uses GitHub Actions.
4. Dispatches `deploy-pages.yml` with `gh workflow run`.
5. Prints the run URL.
6. When `WAIT=1`, waits for completion with `gh run watch`.

## Examples

Deploy the current `master` branch:

```console
$ bash scripts/deploy-website.sh
```

Dispatch without waiting:

```console
$ WAIT=0 bash scripts/deploy-website.sh
```

Update the Linux compiler download before deploying:

```console
$ PLATFORM=linux VERSION=0.2.5 bash scripts/deploy-website.sh
```

## Important

The workflow deploys the target ref, not the local working tree. Commit and push local changes before using these scripts.

The `BASE_PATH`, `PYTHON_BIN`, and `REMOTE_NAME` values are no longer used by the deploy scripts.

## Files It Changes

- Creates a GitHub Actions workflow run.
- When `PLATFORM` and `VERSION` are provided, updates `assets/js/downloads.js` and the visible fallback labels, then commits them to `master`.
- Publishes the generated Pages artifact.
- Does not create or modify the `gh-pages` branch.
- Does not rewrite the source checkout for a normal deployment.
