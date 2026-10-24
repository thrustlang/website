from __future__ import annotations

import argparse
import re

from typing import Any
from pathlib import Path

ROOT: Path = Path(__file__).resolve().parent
REPO_ROOT: Path = ROOT.parent

PLATFORM_TAGS: dict[str, str] = {
    "windows": "thrustc-x86_64-windows-msvc-v{version}",
    "linux": "thrustc-x86_64-linux-ubuntu-v{version}",
    "macos_intel": "thrustc-x86_64-macos-v{version}",
    "macos_arm": "thrustc-aarch64-macos-v{version}",
}

VERSION_RE: re.Pattern[str] = re.compile(r"^\d+\.\d+\.\d+$")

def update_compiler_download(
    platform: str,
    version: str,
    root: Path,
    force: bool = False,
) -> None:
    if platform not in PLATFORM_TAGS:
        raise SystemExit(f"unknown platform '{platform}'")

    target: str = normalize_version(version)
    downloads_js: Path = root / "assets" / "js" / "downloads.js"
    html_files: list[Path] = [
        root / "en" / "index.html",
        root / "es" / "index.html",
        root / "en" / "downloads" / "index.html",
        root / "es" / "downloads" / "index.html",
    ]

    if not downloads_js.is_file():
        raise SystemExit(f"could not find {downloads_js}")

    text: str = downloads_js.read_text(encoding="utf-8")
    fallback: str = group_version(text)
    current: str = read_platform_version(text, platform, fallback)

    if version_key(target) < version_key(current) and not force:
        print(
            f"refusing to downgrade {platform} compiler download "
            f"from v{current} to v{target}; use --force to override."
        )
        return

    next_text, js_count = replace_platform_version(text, platform, target)
    changes: list[tuple[Path, str, str, int, str]] = []

    if next_text != text:
        changes.append((downloads_js, f"v{current}", f"v{target}", js_count, next_text))

    for path in html_files:
        if not path.is_file():
            raise SystemExit(f"could not find {path}")

        html_text: str = path.read_text(encoding="utf-8")
        next_html, html_count = replace_html_version(html_text, platform, target)

        if html_count != 1:
            raise SystemExit(
                f"expected exactly one compiler label for '{platform}' in {path}, found {html_count}"
            )

        if next_html != html_text:
            changes.append((path, f"v{current}", f"v{target}", html_count, next_html))

    print(f"Platform: {platform}")
    print(f"Current version: v{current}")
    print(f"Target version: v{target}")

    if not changes:
        print("No changes needed.")
        return

    print("\nFiles changed:")

    for path, before, after, count, next_content in changes:
        print(f"- {path.relative_to(root)}")
        print(f"  {before} -> {after}, {count} occurrence{'s' if count != 1 else ''}")

        path.write_text(next_content, encoding="utf-8")

def normalize_version(version: str) -> str:
    normalized: str = version.strip()

    if normalized.startswith("v"):
        normalized: str = normalized[1:]

    if not VERSION_RE.fullmatch(normalized):
        raise SystemExit(f"invalid version '{version}', expected X.Y.Z")

    return normalized

def version_key(version: str) -> tuple[int, int, int]:
    major, minor, patch = version.split(".")

    return int(major), int(minor), int(patch)

def group_version(text: str) -> str:
    match: re.Match[str] | None = re.search(r'compiler:\s*\{\s*version:\s*"([^"]+)"', text)

    if match is None:
        raise SystemExit("could not find the compiler fallback version in downloads.js")

    return normalize_version(match.group(1))

def platform_pattern(platform: str) -> re.Pattern[str]:
    tag: str = PLATFORM_TAGS[platform].replace("{version}", r"\{version\}")

    return re.compile(
        rf"(?P<prefix>{re.escape(platform)}: \{{\n)"
        rf"(?P<indent>[ \t]*)"
        rf"(?P<version_line>version: \"[^\"]*\",\n[ \t]*)?"
        rf"(?P<tag>tag: \"{tag}\")",
        re.MULTILINE,
    )


def read_platform_version(text: str, platform: str, fallback: str) -> str:
    pattern: re.Pattern[str] = platform_pattern(platform)
    matches: list[re.Match[str]] = list(pattern.finditer(text))

    if len(matches) != 1:
        raise SystemExit(
            f"expected exactly one compiler platform block for '{platform}', found {len(matches)}"
        )

    version_line: str | Any = matches[0].group("version_line")

    if version_line is None:
        return fallback

    match: re.Match[str] | None = re.search(r'version: "([^"]+)"', version_line)

    if match is None:
        raise SystemExit(f"could not read the version for platform '{platform}'")

    return normalize_version(match.group(1))

def replace_platform_version(text: str, platform: str, version: str) -> tuple[str, int]:
    pattern: re.Pattern[str] = platform_pattern(platform)
    matches: list[re.Match[str]] = list(pattern.finditer(text))

    if len(matches) != 1:
        raise SystemExit(
            f"expected exactly one compiler platform block for '{platform}', found {len(matches)}"
        )

    match: re.Match[str] = matches[0]
    replacement: str = (
        f'{match.group("prefix")}'
        f'{match.group("indent")}version: "{version}",\n'
        f'{match.group("indent")}{match.group("tag")}'
    )

    return text[: match.start()] + replacement + text[match.end() :], 1

def replace_html_version(text: str, platform: str, version: str) -> tuple[str, int]:
    pattern: re.Pattern[str] = re.compile(
        rf'(<span data-group="compiler" data-version="{re.escape(platform)}">)v[^<]*(</span>)'
    )

    return pattern.subn(rf"\g<1>v{version}\g<2>", text)

def main(argv= None) -> None:

    parser = argparse.ArgumentParser(
        description="Update one platform compiler download in the website.",
        epilog=(
            "Examples:\n"
            "  python scripts/update_compiler_download.py --platform linux --version 0.2.5\n"
            "  python scripts/update_compiler_download.py --platform windows --version v0.2.5"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--platform", required=True, choices=sorted(PLATFORM_TAGS))
    parser.add_argument("--version", required=True, help="New compiler version, with or without leading v.")
    parser.add_argument("--root", default=str(REPO_ROOT), help="Website repository root.")
    parser.add_argument("--force", action="store_true", help="Allow downgrading the platform version.")

    args: argparse.Namespace = parser.parse_args(argv)

    update_compiler_download(
        args.platform,
        args.version,
        Path(args.root).resolve(),
        args.force,
    )


if __name__ == "__main__":
    main()
