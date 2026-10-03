<img src= "https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt= "logo" style= "width: 80%; height: 80%;"></img>

# Create New Documentation Version

<img src= "https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt= "standard-separator" style= "width: 1hv;"> </img>

`scripts/create_new_version.py` creates a new documentation version from an existing content version, promotes it to the latest public version, regenerates the published output, and creates the version commit.

> [!IMPORTANT]
> The new version must already exist in `thrustc/std/<new-version>/` before this script is run.

## What The Script Does

The script:

1. Checks that the new version does not already exist.
2. Resolves the source version.
3. Verifies that the matching `std` sources exist.
4. Copies `documentation/content/<source-version>/` to the new version.
5. Builds the new generated documentation.
6. Updates `documentation/versions.json`.
7. Rebuilds the full documentation hub and output.
8. Creates a git commit named `Create new version <new-version>` unless `--no-commit` is passed.

## Command Syntax

```console
$ python scripts/create_new_version.py --new-version v0.2.2
```

## Parameters

- `--new-version`: new documentation version to publish
- `--from`: optional source version used as the base content
- `--no-commit`: generate files without creating the version commit

## Examples

### Create From The Current Latest Version

```console
$ python scripts/create_new_version.py --new-version v0.2.2
```

### Create From A Specific Existing Version

```console
$ python scripts/create_new_version.py --from v0.2.1 --new-version v0.2.2
```

## Files Touched

The script may update:

- `documentation/content/<new-version>/pages.json`
- `documentation/versions.json`
- `documentation/<new-version>/...`
- `documentation/index.html`

## Deployment Trigger

`.github/workflows/deploy-pages.yml` deploys after the version commit is pushed. The workflow requires both conditions:

- `documentation/versions.json` changed in the pushed commit
- the commit message starts with `Create new version `

Use `--no-commit` only when you plan to commit manually with the same message shape or deploy manually.

This trigger is not based on a file that must be deleted later. A later normal commit does not deploy just because version files already exist. Accidental deployment requires both a change to `documentation/versions.json` and a commit message that starts with `Create new version `.

## Failure Behavior

> [!NOTE]
> The current implementation performs a partial rollback if the new version cannot be built after the content copy step.

That rollback restores:

- `documentation/versions.json`
- `documentation/content/<new-version>/`
- `documentation/<new-version>/`

## Common Errors

### Version Already Exists

The requested version is already present in `documentation/versions.json` or in the content tree.

### Unknown Source Version

The version passed through `--from` is not known by the documentation system.

### Missing Std Sources

The script could not find the matching directory in `thrustc/std/<new-version>/`.

## Notes

> [!WARNING]
> Create a new documentation version only after the corresponding compiler-side `std` version is already present and stable enough to publish.
