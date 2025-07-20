#!/bin/sh

set -e

# Construct the full Docker image name from version
DATASURFACE_VERSION=${DATASURFACE_VERSION:-"latest"}
DOCKER_IMAGE="datasurface/datasurface:${DATASURFACE_VERSION}"
MAIN_BRANCH=${MAIN_BRANCH:-"main"}

echo "🔍 DataSurface Model Validator"
echo "Using DataSurface image: $DOCKER_IMAGE (version: $DATASURFACE_VERSION)"
echo "Comparing against branch: $MAIN_BRANCH"
echo ""

# Create workspace directories
mkdir -p /tmp/workspace/main
mkdir -p /tmp/workspace/pr

echo "📥 Checking out main branch..."
# Checkout main branch
git clone --depth=1 --branch="$MAIN_BRANCH" "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" /tmp/workspace/main || {
    echo "⚠️  Warning: Could not checkout main branch (might be initial commit)"
    mkdir -p /tmp/workspace/main
}

echo "📥 Checking out PR code..."
# Checkout PR code
git clone --depth=1 "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY" /tmp/workspace/pr
cd /tmp/workspace/pr
git fetch origin "pull/$GITHUB_EVENT_PULL_REQUEST_NUMBER/head:pr-branch"
git checkout pr-branch

echo ""
echo "🚀 Running DataSurface model validation..."
echo "Docker command: docker run --rm datasurface/datasurface:${DATASURFACE_VERSION} python -m datasurface.handler.action"
echo ""

# Run DataSurface validation
docker run --rm \
  -v /tmp/workspace/main:/workspace/main \
  -v /tmp/workspace/pr:/workspace/pr \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e BASE_REPOSITORY="$GITHUB_REPOSITORY" \
  -e HEAD_REPOSITORY="$GITHUB_EVENT_PULL_REQUEST_HEAD_REPO_FULL_NAME" \
  -e HEAD_BRANCH="$GITHUB_EVENT_PULL_REQUEST_HEAD_REF" \
  "$DOCKER_IMAGE" \
  python -m datasurface.handler.action /workspace/main /workspace/pr

echo ""
echo "✅ DataSurface validation completed successfully!" 