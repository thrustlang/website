<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Deploy Website

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

This guide explains how to deploy the website manually with the platform-specific `scripts/deploy-website.*` scripts.

## What They Do

The deploy scripts build the website for the configured subpath and publish the result to the `gh-pages` branch.

The Bash, fish, PowerShell, and batch scripts perform the same deployment flow for different shells.

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

## Flow

1. Checks whether `origin/gh-pages` exists and creates it if needed.
2. Runs `scripts/normalize_website_path_for_gh_pages.py --base-path /website` into a temporary directory.
3. Uses a temporary worktree for `gh-pages`.
4. Replaces the branch contents with the built website.
5. Commits and pushes only when files changed.

## Environment Overrides

| Variable | What It Means | Default |
| --- | --- | --- |
| `BASE_PATH` | Deployment base path | `/website` |
| `PYTHON_BIN` | Python executable | `python3` on Unix shells, `python` on Windows |

## Files It Changes

- temporary build directories
- the `gh-pages` branch when deployment content changed

The source checkout is not rewritten by these scripts.
