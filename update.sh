#!/usr/bin/env bash
set -euo pipefail

git remote add upstream https://github.com/harfbuzz/harfbuzz || true
git fetch upstream
git merge upstream/main --strategy ours
