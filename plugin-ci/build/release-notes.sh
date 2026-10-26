#!/usr/bin/env bash
# Generates release notes for the commit at HEAD.
#
# Full releases (vX.Y.Z) list changes since the previous full release on the
# same line of history. Pre-releases and untagged builds list changes since the
# previous tag of any kind. Only tags that are strict ancestors of HEAD are
# considered, so patch releases cut from release branches are compared against
# their own branch rather than whatever main has tagged since.
set -euo pipefail

OUTPUT=${OUTPUT:-dist/release-notes.md}
FULL_RELEASE_RE='^v[0-9]+\.[0-9]+\.[0-9]+$'

if [[ "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
  current_tag="$GITHUB_REF_NAME"
else
  current_tag=$(git describe --tags --exact-match HEAD 2>/dev/null || true)
fi

ancestor_tags() {
  # versionsort.suffix makes vX.Y.Z-rcN sort below vX.Y.Z
  git -c versionsort.suffix=-rc tag -l 'v*' --merged HEAD --no-contains HEAD --sort=-v:refname
}

if [[ "$current_tag" =~ $FULL_RELEASE_RE ]]; then
  base=$(ancestor_tags | grep -E "$FULL_RELEASE_RE" | head -n1 || true)
else
  base=$(ancestor_tags | head -n1)
fi

range="${base:+${base}..}HEAD"
echo "Release notes for ${current_tag:-HEAD} using range ${range}" >&2

printf "Supported Mattermost Server Versions: **%s+** \n## Enhancements\n\n## Fixes\n" "$(jq -r .min_server_version plugin.json)" >> "$OUTPUT"
git log --pretty='format:- %h %s' --abbrev-commit --no-decorate --no-color "$range" >> "$OUTPUT"
