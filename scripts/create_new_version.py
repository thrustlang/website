from __future__ import annotations

import argparse
import shutil
import subprocess

from docs_common import (
    CONTENT_ROOT,
    DOCS_ROOT,
    STD_ROOT,
    build_all,
    build_version,
    copy_content,
    latest_version,
    load_versions,
    save_versions,
)

def commit_new_version(new_version: str) -> None:
    subprocess.run(["git", "add", "documentation"], check=True)

    result = subprocess.run(
        ["git", "diff", "--cached", "--quiet", "--", "documentation"],
        check=False,
    )

    if result.returncode == 0:
        print("no documentation changes to commit")
        return

    subprocess.run(["git", "commit", "-m", f"Create new version {new_version}"], check=True)


def create_new_version(new_version: str, source_version: str | None = None, commit: bool = True) -> None:
    versions = load_versions()

    original_versions = {
        "latest": versions.get("latest"),
        "versions": [dict(entry) for entry in versions.get("versions", [])],
        "defaultSection": versions.get("defaultSection"),
    }

    known = {entry["id"] for entry in versions.get("versions", [])}

    if new_version in known:
        raise SystemExit(f"version already exists: {new_version}")

    source = source_version or latest_version(versions)

    if source not in known:
        raise SystemExit(f"unknown source version: {source}")

    if not (STD_ROOT / new_version).exists():
        raise SystemExit(f"missing std sources for {new_version}: {STD_ROOT / new_version}")

    if not (CONTENT_ROOT / source / "compiler-command-line-reference.json").exists():
        raise SystemExit(
            f"missing compiler command line reference in source version: {source}"
        )

    copy_content(source, new_version)

    new_versions = []
    for entry in versions.get("versions", []):
        updated = dict(entry)
        updated["label"] = updated["id"]
        updated["status"] = "archived"
        new_versions.append(updated)

    new_versions.insert(
        0,
        {
            "id": new_version,
            "label": f"{new_version} (latest)",
            "status": "current",
        },
    )

    next_versions = dict(versions)
    next_versions["latest"] = new_version
    next_versions["versions"] = new_versions

    try:
        build_version(new_version, next_versions)
        save_versions(next_versions)
        build_all()
    except Exception:
        save_versions(original_versions)
        shutil.rmtree(CONTENT_ROOT / new_version, ignore_errors=True)
        shutil.rmtree(DOCS_ROOT / new_version, ignore_errors=True)
        raise

    if commit:
        commit_new_version(new_version)

    print(f"created {new_version} from {source}")

def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Create a new documentation version.",
        epilog=(
            "Examples:\n"
            "  python scripts/create_new_version.py --new-version v0.2.2\n"
            "  python scripts/create_new_version.py --from v0.2.1 --new-version v0.2.2\n"
            "  python scripts/create_new_version.py --new-version v0.2.2 --no-commit"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument("--new-version", required=True)
    parser.add_argument("--from", dest="from_version")
    parser.add_argument(
        "--no-commit",
        action="store_true",
        help="Generate the version files without creating the version commit.",
    )

    args = parser.parse_args(argv)

    create_new_version(args.new_version, args.from_version, not args.no_commit)


if __name__ == "__main__":
    main()
