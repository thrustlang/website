#!/usr/bin/fish

function run
    $argv
    or exit 1
end

set SCRIPT_DIR (realpath (dirname (status filename)))
set PROJECT_DIR (realpath "$SCRIPT_DIR/..")

if not set -q BASE_PATH
    set BASE_PATH "/website"
end

if not set -q PYTHON_BIN
    set PYTHON_BIN "python3"
end

set TEMP_SITE "/tmp/thrust-website-pages"
set PAGES_WORKTREE "/tmp/thrust-website-gh-pages"

run cd $PROJECT_DIR

if set -q REMOTE_NAME
    set REMOTE $REMOTE_NAME
else if git remote get-url origin >/dev/null 2>&1
    set REMOTE origin
else
    set REMOTES (git remote)
    set REMOTE $REMOTES[1]
end

if test -z "$REMOTE"
    echo "No git remote configured. Add one or set REMOTE_NAME." >&2
    exit 1
end

echo "Using project directory: $PROJECT_DIR"
echo "Using remote: $REMOTE"

if not git ls-remote --exit-code --heads $REMOTE gh-pages >/dev/null 2>&1
    echo "Branch 'gh-pages' not found on remote '$REMOTE'. Creating it from a temporary repository..."
    set TEMP_EMPTY (mktemp -d /tmp/thrust-website-empty-gh-pages.XXXXXX)
    run git -C $TEMP_EMPTY init
    run git -C $TEMP_EMPTY commit --allow-empty -m "Initial gh-pages commit"
    set REMOTE_URL (git remote get-url $REMOTE)
    run git -C $TEMP_EMPTY push $REMOTE_URL HEAD:gh-pages
    run rm -rf $TEMP_EMPTY
end

echo "Building website for $BASE_PATH..."
run rm -rf $TEMP_SITE
run $PYTHON_BIN scripts/normalize_website_path_for_gh_pages.py --base-path $BASE_PATH --output $TEMP_SITE

echo "Deploying website to GitHub Pages..."
run rm -rf $PAGES_WORKTREE
run git fetch $REMOTE gh-pages
run git worktree add --detach $PAGES_WORKTREE FETCH_HEAD

run pushd $PAGES_WORKTREE
    run find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf '{}' +
    run cp -r $TEMP_SITE/* ./
    run cp "$TEMP_SITE/.nojekyll" ./.nojekyll

    run git add -A
    if git diff-index --quiet HEAD --
        echo "No changes to website."
    else
        run git commit -m "Update website "(date '+%Y-%m-%d %H:%M')
        run git push $REMOTE HEAD:gh-pages
    end
run popd

run git worktree remove $PAGES_WORKTREE
run rm -rf $TEMP_SITE

echo "Done. Website updated successfully."
