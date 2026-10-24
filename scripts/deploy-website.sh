#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

REPO="${REPO:-}"
WORKFLOW="${WORKFLOW:-deploy-pages.yml}"
REF="${REF:-master}"
WAIT="${WAIT:-1}"
PLATFORM="${PLATFORM:-}"
VERSION="${VERSION:-}"

cd "$PROJECT_DIR"

if [ -n "${BASE_PATH:-}" ] || [ -n "${PYTHON_BIN:-}" ] || [ -n "${REMOTE_NAME:-}" ]; then
    echo "warning: BASE_PATH, PYTHON_BIN and REMOTE_NAME are no longer used." >&2
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "error: the GitHub CLI (gh) is required." >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "error: gh is not authenticated. Run 'gh auth login' first." >&2
    exit 1
fi

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"
fi

if [ -z "$REPO" ]; then
    echo "error: could not resolve the repository. Set REPO=owner/name." >&2
    exit 1
fi

if ! gh workflow view "$WORKFLOW" --repo "$REPO" >/dev/null 2>&1; then
    echo "error: workflow '$WORKFLOW' was not found in '$REPO'." >&2
    exit 1
fi

if ! BUILD_TYPE="$(gh api "repos/$REPO/pages" --jq .build_type 2>/dev/null)"; then
    echo "warning: could not verify the GitHub Pages source for '$REPO'." >&2
elif [ "$BUILD_TYPE" != "workflow" ]; then
    echo "error: GitHub Pages source is '$BUILD_TYPE'; configure it to use GitHub Actions." >&2
    exit 1
fi

if [ -n "$PLATFORM" ] || [ -n "$VERSION" ]; then
    if [ -z "$PLATFORM" ] || [ -z "$VERSION" ]; then
        echo "error: PLATFORM and VERSION must be provided together." >&2
        exit 1
    fi

    case "$PLATFORM" in
        windows|linux|macos_intel|macos_arm) ;;
        *)
            echo "error: unknown PLATFORM '$PLATFORM'." >&2
            exit 1
            ;;
    esac

    VERSION="${VERSION#v}"
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "warning: the working tree is not clean. The workflow deploys '$REF', not local changes." >&2
fi

ARGS=(workflow run "$WORKFLOW" --repo "$REPO" --ref "$REF")

if [ -n "$PLATFORM" ]; then
    ARGS+=(-f "platform=$PLATFORM" -f "version=$VERSION")
fi

BEFORE_ID="$(gh run list --workflow "$WORKFLOW" --repo "$REPO" --branch "$REF" --event workflow_dispatch --limit 1 --jq '.[0].databaseId' 2>/dev/null || true)"

gh "${ARGS[@]}"

RUN_ID=""
RUN_URL=""

for ((attempt = 0; attempt < 30; attempt++)); do
    sleep 2

    RUN_INFO="$(gh run list --workflow "$WORKFLOW" --repo "$REPO" --branch "$REF" --event workflow_dispatch --limit 1 --json databaseId,url --jq '.[0] | "\(.databaseId) \(.url)"' 2>/dev/null || true)"

    if [ -z "$RUN_INFO" ]; then
        continue
    fi

    RUN_ID="${RUN_INFO%% *}"
    RUN_URL="${RUN_INFO#* }"

    if [ -n "$RUN_ID" ] && [ "$RUN_ID" != "$BEFORE_ID" ]; then
        break
    fi
done

if [ -z "$RUN_ID" ]; then
    echo "Deployment dispatched. Could not resolve the run URL; check the Actions tab." >&2
    exit 0
fi

echo "Deployment run: $RUN_URL"

case "$WAIT" in
    1|true|TRUE|yes|YES)
        gh run watch "$RUN_ID" --repo "$REPO" --exit-status
        ;;
    *)
        echo "Not waiting for completion (WAIT=0)."
        ;;
esac
