#!/usr/bin/fish

function run
    $argv
    or exit 1
end

set SCRIPT_DIR (realpath (dirname (status filename)))
set PROJECT_DIR (realpath "$SCRIPT_DIR/..")

if not set -q REPO
    set REPO ""
end

if not set -q WORKFLOW
    set WORKFLOW "deploy-pages.yml"
end

if not set -q REF
    set REF "master"
end

if not set -q WAIT
    set WAIT "1"
end

if not set -q PLATFORM
    set PLATFORM ""
end

if not set -q VERSION
    set VERSION ""
end

run cd $PROJECT_DIR

if set -q BASE_PATH; or set -q PYTHON_BIN; or set -q REMOTE_NAME
    echo "warning: BASE_PATH, PYTHON_BIN and REMOTE_NAME are no longer used." >&2
end

if not command -q gh
    echo "error: the GitHub CLI (gh) is required." >&2
    exit 1
end

if not gh auth status >/dev/null 2>&1
    echo "error: gh is not authenticated. Run 'gh auth login' first." >&2
    exit 1
end

if test -z "$REPO"
    set REPO (gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)
end

if test -z "$REPO"
    echo "error: could not resolve the repository. Set REPO=owner/name." >&2
    exit 1
end

if not gh workflow view $WORKFLOW --repo $REPO >/dev/null 2>&1
    echo "error: workflow '$WORKFLOW' was not found in '$REPO'." >&2
    exit 1
end

set -l BUILD_TYPE (gh api "repos/$REPO/pages" --jq .build_type 2>/dev/null)

if test -z "$BUILD_TYPE"
    echo "warning: could not verify the GitHub Pages source for '$REPO'." >&2
else if test "$BUILD_TYPE" != "workflow"
    echo "error: GitHub Pages source is '$BUILD_TYPE'; configure it to use GitHub Actions." >&2
    exit 1
end

if test -n "$PLATFORM"; or test -n "$VERSION"
    if test -z "$PLATFORM"; or test -z "$VERSION"
        echo "error: PLATFORM and VERSION must be provided together." >&2
        exit 1
    end

    switch $PLATFORM
        case windows linux macos_intel macos_arm
        case '*'
            echo "error: unknown PLATFORM '$PLATFORM'." >&2
            exit 1
    end

    set VERSION (string replace -r '^v' '' -- $VERSION)
end

set -l DIRTY (git status --porcelain)

if test -n "$DIRTY"
    echo "warning: the working tree is not clean. The workflow deploys '$REF', not local changes." >&2
end

set -l ARGS workflow run $WORKFLOW --repo $REPO --ref $REF

if test -n "$PLATFORM"
    set -a ARGS -f platform=$PLATFORM -f version=$VERSION
end

set -l BEFORE_ID (gh run list --workflow $WORKFLOW --repo $REPO --branch $REF --event workflow_dispatch --limit 1 --jq '.[0].databaseId' 2>/dev/null)

run gh $ARGS

set -l RUN_ID ""
set -l RUN_URL ""

set -l ATTEMPT 0

while test $ATTEMPT -lt 30
    set ATTEMPT (math $ATTEMPT + 1)
    sleep 2

    set -l RUN_INFO (gh run list --workflow $WORKFLOW --repo $REPO --branch $REF --event workflow_dispatch --limit 1 --json databaseId,url --jq '.[0] | "\(.databaseId) \(.url)"' 2>/dev/null)

    if test -z "$RUN_INFO"
        continue
    end

    set -l PARTS (string split -m 1 ' ' -- $RUN_INFO)
    set RUN_ID $PARTS[1]
    set RUN_URL $PARTS[2]

    if test -n "$RUN_ID"; and test "$RUN_ID" != "$BEFORE_ID"
        break
    end
end

if test -z "$RUN_ID"
    echo "Deployment dispatched. Could not resolve the run URL; check the Actions tab." >&2
    exit 0
end

echo "Deployment run: $RUN_URL"

switch $WAIT
    case 1 true TRUE yes YES
        run gh run watch $RUN_ID --repo $REPO --exit-status
    case '*'
        echo "Not waiting for completion (WAIT=0)."
end
