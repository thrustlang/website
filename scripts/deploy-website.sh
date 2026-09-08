#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_PATH="${BASE_PATH:-/website}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TEMP_SITE="/tmp/thrust-website-pages"
PAGES_WORKTREE="/tmp/thrust-website-gh-pages"

cd "$PROJECT_DIR"

echo "Using project directory: $PROJECT_DIR"

if ! git rev-parse --verify origin/gh-pages >/dev/null 2>&1; then
    echo "Branch 'gh-pages' not found on remote. Creating orphan branch..."
    CURRENT_BRANCH=$(git branch --show-current)
    git checkout --orphan gh-pages
    git rm -rf . >/dev/null
    git commit --allow-empty -m "Initial gh-pages commit"
    git push origin gh-pages
    git checkout "$CURRENT_BRANCH"
fi

echo "Building website for $BASE_PATH..."
rm -rf "$TEMP_SITE"
"$PYTHON_BIN" scripts/build_subpath.py --base-path "$BASE_PATH" --output "$TEMP_SITE"

echo "Deploying website to GitHub Pages..."
rm -rf "$PAGES_WORKTREE"
git fetch origin gh-pages >/dev/null 2>&1
git worktree add "$PAGES_WORKTREE" gh-pages

pushd "$PAGES_WORKTREE" > /dev/null
    find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} +
    cp -r "$TEMP_SITE"/* ./

    git add -A
    if git diff-index --quiet HEAD --; then
        echo "No changes to website."
    else
        git commit -m "Update website $(date '+%Y-%m-%d %H:%M')"
        git push origin gh-pages
    fi
popd > /dev/null

git worktree remove "$PAGES_WORKTREE"
rm -rf "$TEMP_SITE"

echo "Done. Website updated successfully."
