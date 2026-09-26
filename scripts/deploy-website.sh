#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_PATH="${BASE_PATH:-/website}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TEMP_SITE="/tmp/thrust-website-pages"
PAGES_WORKTREE="/tmp/thrust-website-gh-pages"

cd "$PROJECT_DIR"

if [ -n "${REMOTE_NAME:-}" ]; then
    REMOTE="$REMOTE_NAME"
elif git remote get-url origin >/dev/null 2>&1; then
    REMOTE="origin"
else
    REMOTE="$(git remote | sed -n '1p')"
fi

if [ -z "$REMOTE" ]; then
    echo "No git remote configured. Add one or set REMOTE_NAME." >&2
    exit 1
fi

echo "Using project directory: $PROJECT_DIR"
echo "Using remote: $REMOTE"

if ! git ls-remote --exit-code --heads "$REMOTE" gh-pages >/dev/null 2>&1; then
    echo "Branch 'gh-pages' not found on remote '$REMOTE'. Creating it from a temporary repository..."
    TEMP_EMPTY="$(mktemp -d /tmp/thrust-website-empty-gh-pages.XXXXXX)"
    git -C "$TEMP_EMPTY" init
    git -C "$TEMP_EMPTY" commit --allow-empty -m "Initial gh-pages commit"
    git -C "$TEMP_EMPTY" push "$(git remote get-url "$REMOTE")" HEAD:gh-pages
    rm -rf "$TEMP_EMPTY"
fi

echo "Building website for $BASE_PATH..."
rm -rf "$TEMP_SITE"
"$PYTHON_BIN" scripts/normalize_website_path_for_gh_pages.py --base-path "$BASE_PATH" --output "$TEMP_SITE"

echo "Deploying website to GitHub Pages..."
rm -rf "$PAGES_WORKTREE"
git fetch "$REMOTE" gh-pages >/dev/null 2>&1
git worktree add --detach "$PAGES_WORKTREE" FETCH_HEAD

pushd "$PAGES_WORKTREE" > /dev/null
    find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} +
    cp -r "$TEMP_SITE"/* ./
    cp "$TEMP_SITE/.nojekyll" ./.nojekyll

    git add -A
    if git diff-index --quiet HEAD --; then
        echo "No changes to website."
    else
        git commit -m "Update website $(date '+%Y-%m-%d %H:%M')"
        git push "$REMOTE" HEAD:gh-pages
    fi
popd > /dev/null

git worktree remove "$PAGES_WORKTREE"
rm -rf "$TEMP_SITE"

echo "Done. Website updated successfully."
