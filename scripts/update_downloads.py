from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT: Path = Path(__file__).resolve().parent
REPO_ROOT: Path = ROOT.parent
DOWNLOADS_JS: Path = REPO_ROOT / "assets" / "js" / "downloads.js"
DOWNLOAD_VERSION_RE = re.compile(r'(version:\s*")([^"]+)(")')

HTML_FILES = [
    REPO_ROOT / "en" / "index.html",
    REPO_ROOT / "es" / "index.html",
    REPO_ROOT / "en" / "downloads" / "index.html",
    REPO_ROOT / "es" / "downloads" / "index.html",
]


def normalize_version(version: str) -> str:
    normalized = version.strip()

    if normalized.startswith("v"):
        normalized = normalized[1:]

    if not normalized:
        raise SystemExit("version cannot be empty")

    return normalized


def display_version(version: str) -> str:
    return "v" + normalize_version(version)


def read_downloads_version(text: str) -> str:
    match = DOWNLOAD_VERSION_RE.search(text)

    if match is None:
        raise SystemExit(f"could not find downloads version in {DOWNLOADS_JS.relative_to(REPO_ROOT)}")

    return normalize_version(match.group(2))


def replace_downloads_js(text: str, to_version: str) -> tuple[str, int]:
    next_text, count = DOWNLOAD_VERSION_RE.subn(rf"\g<1>{to_version}\3", text, count=1)
    return next_text, count


def planned_change(path: Path, before: str, after: str, count: int) -> None:
    rel = path.relative_to(REPO_ROOT)
    print(f"- {rel}")
    print(f"  {before} -> {after}, {count} occurrence{'s' if count != 1 else ''}")


def update_downloads(from_version: str, to_version: str, test: bool = False) -> None:
    expected = normalize_version(from_version)
    target = normalize_version(to_version)
    expected_label = display_version(expected)
    target_label = display_version(target)

    downloads_text = DOWNLOADS_JS.read_text()
    current = read_downloads_version(downloads_text)

    if current != expected:
        raise SystemExit(f"expected current downloads version {expected}, found {current}")

    js_next, js_count = replace_downloads_js(downloads_text, target)
    changes: list[tuple[Path, str, str, int, str]] = []

    if js_next != downloads_text:
        changes.append((DOWNLOADS_JS, f'version: "{expected}"', f'version: "{target}"', js_count, js_next))

    for path in HTML_FILES:
        text = path.read_text()
        next_text = text.replace(expected_label, target_label)
        count = text.count(expected_label)

        if next_text != text:
            changes.append((path, expected_label, target_label, count, next_text))

    print(f"Current downloads version: {current}")
    print(f"Target downloads version: {target}")

    if not changes:
        print("No changes needed.")
        return

    if test:
        print("\nTest mode: no files will be changed.")
        print("\nFiles that would change:")
    else:
        print("\nFiles changed:")

    for path, before, after, count, next_text in changes:
        planned_change(path, before, after, count)

        if not test:
            path.write_text(next_text)

    if test:
        print("\nNo files changed.")


def main(argv=None) -> None:
    parser = argparse.ArgumentParser(
        description="Update website download links from one compiler version to another.",
        epilog=(
            "Examples:\n"
            "  python scripts/update_downloads.py --from-version 0.2.1 --to-version 0.2.2\n"
            "  python scripts/update_downloads.py --from-version v0.2.1 --to-version v0.2.2 --test"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--from-version", required=True, help="Current downloads version, with or without leading v.")
    parser.add_argument("--to-version", required=True, help="New downloads version, with or without leading v.")
    parser.add_argument("--test", action="store_true", help="Show planned changes without writing files.")

    args = parser.parse_args(argv)
    update_downloads(args.from_version, args.to_version, args.test)


if __name__ == "__main__":
    main()
