<img src="https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt="logo" style="width: 80%; height: 80%;"></img>

# Update Downloads

<img src="https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt="standard-separator" style="width: 1hv;"></img>

> [!NOTE]
> Compiler download versions are updated automatically per platform when a `thrustc` release workflow finishes. The manual commands below are only for recovery or forced updates.

This guide explains how to update the download versions used by the public pages.

## Compiler Downloads

Compiler versions are stored per platform in `assets/js/downloads.js`. Each platform can point to a different compiler version, so a partial release does not break the other platforms.

Use `scripts/update_compiler_download.py` for manual updates.

### Command Shape

```console
$ python scripts/update_compiler_download.py --platform <platform> --version <version>
```

### Flags

| Flag | Required | What It Means | Example |
| --- | --- | --- | --- |
| `--platform` | yes | Platform to update | `windows`, `linux`, `macos_intel`, `macos_arm` |
| `--version` | yes | Compiler version, with or without leading `v` | `0.2.5` or `v0.2.5` |
| `--root` | no | Website repository root | `.` |
| `--force` | no | Allow downgrading the platform version | `--force` |

### Platform Tags

| Platform | Release tag |
| --- | --- |
| `windows` | `thrustc-x86_64-windows-msvc-v{version}` |
| `linux` | `thrustc-x86_64-linux-ubuntu-v{version}` |
| `macos_intel` | `thrustc-x86_64-macos-v{version}` |
| `macos_arm` | `thrustc-aarch64-macos-v{version}` |

### Examples

Update the Linux compiler download:

```console
$ python scripts/update_compiler_download.py --platform linux --version 0.2.5
```

Allow a downgrade:

```console
$ python scripts/update_compiler_download.py --platform linux --version 0.2.4 --force
```

## Package Manager Downloads

The package manager (`torio`) use `scripts/update_downloads.py`.

```console
$ python scripts/update_downloads.py --from-version <current-version> --to-version <new-version>
```

Versions can be passed with or without a leading `v`.

| Flag | Required | What It Means | Example |
| --- | --- | --- | --- |
| `--from-version` | yes | Current package manager version | `0.1.4` |
| `--to-version` | yes | New package manager version | `0.1.5` |
